
import UIKit

struct LayoutParams {
    let columnCount: Int = 2
    let interItemSpacing: CGFloat = 7
    let leftInset: CGFloat = 16
    let rightInset: CGFloat = 16
    
    var totalInsetWidth: CGFloat {
        leftInset + rightInset + interItemSpacing * (CGFloat(columnCount) - 1)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            print("\(#file):\(#line)] \(#function) Ошибка приведения типа ячейки")
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = isTrackerCompleted(tracker, date: currentDate)
        let completedCount = countCompletedDays(for: tracker)
        
        cell.configure(
            with: tracker,
            currentDate: currentDate,
            completedDaysCount: completedCount,
            isCompleted: isCompleted
        )
        
        cell.configureCompletionHandler(tracker: tracker, isCompleted: isCompleted) { [weak self] in
            guard let self = self else { return }
            if isCompleted {
                self.removeTrackerRecord(tracker, date: self.currentDate)
            } else {
                self.addTrackerRecord(tracker, date: self.currentDate)
            }
        }
        return cell
    }
    
    func toggleTracker(_ tracker: Tracker) {
        let completedID = CompletedTrackerID(id: tracker.id, date: currentDate)
        
        if completedTrackers.contains(completedID) {
            completedTrackers.remove(completedID)
        } else {
            completedTrackers.insert(completedID)
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? SupplementaryView else {
                print("\(#file):\(#line)] \(#function) Ошибка приведения типа header view")
                return UICollectionReusableView()
            }
            
            let title = filteredCategories[indexPath.section].title
            view.configure(with: title)
            return view
            
        case UICollectionView.elementKindSectionFooter:
            return UICollectionReusableView()
            
        default:
            print("\(#file):\(#line)] \(#function) Запрошен неизвестный тип supplementary view: \(kind)")
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - (layoutParams.leftInset + layoutParams.rightInset)
        let cellWidth = (availableWidth - layoutParams.interItemSpacing) / CGFloat(layoutParams.columnCount)
        return CGSize(width: cellWidth, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       insetForSectionAt section: Int) -> UIEdgeInsets {
        let isLastSection = section == filteredCategories.count - 1
        return UIEdgeInsets(top: 8, left: 16, bottom: isLastSection ? bottomInset : 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: collectionView.frame.width, height: 18)
        return size
    }
}
