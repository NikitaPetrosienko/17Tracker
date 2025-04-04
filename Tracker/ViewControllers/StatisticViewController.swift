
import UIKit

final class StatisticViewController: UIViewController {
    
    var rectangleViews: [UIView] = []
    private var values: [String] = []
    private let bottomText = ["Лучший период", "Идеальные дни", "Трекеров завершено", "Среднее значение"]
    private let topPaddingForTitle: CGFloat = 88
    private let verticalSpacingBetweenTitleAndRectangles: CGFloat = 77
    private let rectangleHeight: CGFloat = 90
    private let horizontalSpacing: CGFloat = 12
    private let screenLeftPadding: CGFloat = 16
    private let rectangleWidth: CGFloat = UIScreen.main.bounds.width - 32
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "categoryTextColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "NothingNotFound")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "categoryTextColor")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "background")
        self.view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: topPaddingForTitle),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: screenLeftPadding),
        ])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatistics),
            name: NSNotification.Name("StatisticsDataDidChange"),
            object: nil
        )
        
        fetchAndUpdateStatistics()
    }
    
    @objc private func updateStatistics() {
        print("\(#file):\(#line)] \(#function) Обновление статистики")
        fetchAndUpdateStatistics()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func fetchAndUpdateStatistics() {
        let statistics = StatisticStore.shared.fetchStatistics()
        
        values = [
            "\(statistics.bestStreak)",
            "\(statistics.idealDays)",
            "\(statistics.completedTrackers)",
            "\(statistics.averageCompletion)%"
        ]
        
        createRectangles()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "background")
        
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        updatePlaceholderVisibility(false)
    }
    
    private func updatePlaceholderVisibility(_ hasData: Bool) {
        placeholderImageView.isHidden = hasData
        placeholderLabel.isHidden = hasData
    }

    func createRectangles() {
        let verticalSpacing = topPaddingForTitle + verticalSpacingBetweenTitleAndRectangles
        
        for i in 0..<4 {
            let rectangleView = UIView()
            
            rectangleView.frame = CGRect(
                x: screenLeftPadding,
                y: verticalSpacing + CGFloat(i) * (rectangleHeight + horizontalSpacing),
                width: rectangleWidth,
                height: rectangleHeight
            )
            rectangleView.backgroundColor = UIColor(named: "background")
            rectangleView.layer.cornerRadius = 16
            self.view.addSubview(rectangleView)
            addGradientBorder(to: rectangleView)
            addValueLabel(to: rectangleView, with: values[i], at: i)
            addBottomText(to: rectangleView, with: bottomText[i])
            rectangleViews.append(rectangleView)
        }
    }
    
    func addGradientBorder(to view: UIView) {
        let gradientLayer = CAGradientLayer()

        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.yellow.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let borderFrame = CGRect(
            x: view.frame.origin.x - 1,
            y: view.frame.origin.y - 1,
            width: view.frame.size.width + 2,
            height: view.frame.size.height + 2
        )
        
        gradientLayer.frame = borderFrame
        gradientLayer.cornerRadius = view.layer.cornerRadius
        gradientLayer.masksToBounds = true

        self.view.layer.insertSublayer(gradientLayer, below: view.layer)
    }
    
    func addValueLabel(to view: UIView, with text: String, at index: Int) {
        let valueLabel = UILabel()
        valueLabel.text = text
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = UIColor(named: "categoryTextColor")
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(valueLabel)
       
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            valueLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
        ])
    }
    
    func addBottomText(to view: UIView, with text: String) {
        let bottomTextLabel = UILabel()
        bottomTextLabel.text = text
        bottomTextLabel.font = .systemFont(ofSize: 12)
        bottomTextLabel.textColor = UIColor(named: "categoryTextColor")
        bottomTextLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bottomTextLabel)
        
        NSLayoutConstraint.activate([
            bottomTextLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            bottomTextLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
        ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateRectangleColors()
        }
    }
    
    func updateRectangleColors() {
        let dynamicColor = UIColor(named: "background")
        for view in rectangleViews {
            view.backgroundColor = dynamicColor
        }
    }
}
