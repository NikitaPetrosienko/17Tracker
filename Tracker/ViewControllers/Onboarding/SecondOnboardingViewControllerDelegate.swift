
import UIKit

final class SecondOnboardingViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "onboardingScreen2") {
            imageView.image = image
        } else {
            print("\(#file):\(#line)] \(#function) Ошибка загрузки изображения onboardingScreen2")
        }
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Даже если это\nне литры воды и йога"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var wowTechnologyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.backgroundColor = .blackYPBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(wowTechnologyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        print("\(#file):\(#line)] \(#function) Второй экран онбординга загружен")
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(wowTechnologyButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            
            wowTechnologyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wowTechnologyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            wowTechnologyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            wowTechnologyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func wowTechnologyButtonTapped() {
          AppNavigationService.shared.completeOnboarding()
          let tabBarController = TabBarController()
          tabBarController.modalPresentationStyle = .fullScreen
          present(tabBarController, animated: true)
      }
  }
