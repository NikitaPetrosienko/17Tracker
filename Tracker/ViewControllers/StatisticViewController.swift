import UIKit

final class StatisticViewController: UIViewController {
    
    // Массив для хранения созданных прямоугольников
    var rectangleViews: [UIView] = []
    // Значения статистики, которые будут отображаться
    private var values: [String] = []
    // Текст для нижней подписи прямоугольников
    private let bottomText = ["Лучший период", "Идеальные дни", "Трекеров завершено", "Среднее значение"]
    
    // Константы отступов и размеров
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
        imageView.image = UIImage(named: "sad")
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
        
        // Устанавливаем все UI элементы
        setupViews()
        
        // Регистрируем уведомление об изменении статистики
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatistics),
            name: NSNotification.Name("StatisticsDataDidChange"),
            object: nil
        )
        
        // Для тестирования очищаем статистику, затем обновляем её
//        StatisticStore.shared.clearStatistics()
        fetchAndUpdateStatistics()
    }
    
    @objc private func updateStatistics() {
        print("\(#file):\(#line)] \(#function) Обновление статистики")
        fetchAndUpdateStatistics()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        // Добавляем titleLabel и placeholder-элементы
        view.addSubview(titleLabel)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            // TitleLabel
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: topPaddingForTitle),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: screenLeftPadding),
            
            // PlaceholderImageView
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // PlaceholderLabel
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Изначально скрываем прямоугольники (placeholder будет показан, если данных нет)
        updatePlaceholderVisibility(false)
        // Делаем placeholder видимым поверх других элементов (если потребуется)
        view.bringSubviewToFront(placeholderImageView)
        view.bringSubviewToFront(placeholderLabel)
    }
    
    // Скрывает или показывает placeholder в зависимости от наличия данных
    private func updatePlaceholderVisibility(_ hasData: Bool) {
        placeholderImageView.isHidden = hasData
        placeholderLabel.isHidden = hasData
    }
    
    // Удаляет ранее созданные прямоугольники, чтобы не накапливать их
    private func removeExistingRectangles() {
        for rect in rectangleViews {
            rect.removeFromSuperview()
        }
        rectangleViews.removeAll()
    }
    
    // Получает статистику и обновляет UI: если есть данные – создаёт прямоугольники, иначе показывает placeholder
    private func fetchAndUpdateStatistics() {
        let statistics = StatisticStore.shared.fetchStatistics()
        
        values = [
            "\(statistics.bestStreak)",
            "\(statistics.idealDays)",
            "\(statistics.completedTrackers)",
            "\(statistics.averageCompletion)%"
        ]
        
        // Проверяем, есть ли ненулевые данные
        let hasData = statistics.bestStreak != 0 ||
                      statistics.idealDays != 0 ||
                      statistics.completedTrackers != 0 ||
                      statistics.averageCompletion != 0
        
        // Удаляем предыдущие прямоугольники
        removeExistingRectangles()
        
        if hasData {
            updatePlaceholderVisibility(true)
            createRectangles()
        } else {
            updatePlaceholderVisibility(false)
        }
    }
    
    // MARK: - Создание UI для статистики
    
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
            valueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
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
            bottomTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
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
