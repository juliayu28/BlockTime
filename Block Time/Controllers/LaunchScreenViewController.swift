import UIKit

class LaunchScreenViewController: UIViewController {
    private let logoImageView = UIImageView()
    private let loadingBar = UIProgressView()
    private let loadingLabel = UILabel()
    
    private var progress: Float = 0.0
    private var timer: Timer?
    
    // Array of loading messages to display
    private let loadingMessages = [
        "Seizing the day...",
        "One small block for man...one giant block for mankind",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startLoading()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup logo
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "LaunchScreenLogo")
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        // Setup loading bar
        loadingBar.progressTintColor = UIColor(named: "BrandBlue")
        loadingBar.trackTintColor = .lightGray
        loadingBar.progress = 0.0
        loadingBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingBar)
        
        // Setup loading label
        loadingLabel.text = loadingMessages[0]
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 14)
        loadingLabel.textColor = .darkGray
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.numberOfLines = 0 // Allow multiple lines
        view.addSubview(loadingLabel)
        
        // Constraints for logo
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            logoImageView.widthAnchor.constraint(equalToConstant: 384),
            logoImageView.heightAnchor.constraint(equalToConstant: 216)
        ])
        
        // Constraints for loading bar
        NSLayoutConstraint.activate([
            loadingBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingBar.topAnchor.constraint(equalTo: logoImageView.bottomAnchor),
            loadingBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
        ])
        
        // Constraints for loading label
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: loadingBar.bottomAnchor, constant: 10),
            loadingLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8) // Control the width
        ])
    }
    
    private func startLoading() {
        // Simulate loading process
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc private func updateProgress() {
        // Update progress
        progress += 0.01
        loadingBar.setProgress(progress, animated: true)
        
        // Update the loading message based on progress
        updateLoadingMessage()
        
        // When loading is complete
        if progress >= 1.0 {
            timer?.invalidate()
            timer = nil
            
            // Navigate to main app after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigateToMainApp()
            }
        }
    }
    
    private func updateLoadingMessage() {
        // Change the message at different progress points
        if progress < 0.5 {
            loadingLabel.text = loadingMessages[0]
        } else {
            loadingLabel.text = loadingMessages[1]
        }
    }
    
    private func navigateToMainApp() {
        let mainViewController = CalendarDayViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        self.present(navigationController, animated: true, completion: nil)
    }
}
