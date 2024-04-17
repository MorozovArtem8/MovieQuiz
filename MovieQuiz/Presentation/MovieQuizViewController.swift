import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet  weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        activityIndicator.style = .large
    }
    
    
    //MARK: IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        
    }
    
    //MARK: func
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.yGreen.cgColor : UIColor.yRed.cgColor
        buttons.forEach {
            $0.isEnabled = false
        }
        
    }
    
    func show(quiz step: QuizStepViewModel) {
        buttons.forEach {
            $0.isEnabled = true
        }
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultMessage()
        
        let alert = UIAlertController (title: result.title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.presenter.restartGame()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что то пошло не так",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            
            guard let self else {return}
            self.presenter.reloadingDataFromServer()
            showLoadingIndicator()
        }
        let alertPresenter = AlertPresenter(viewController: self)
        alertPresenter.show(alertModel: alertModel)
    }
    
    func showLoadImageError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что то пошло не так",
            message: "Невозможно загрузить куартинку",
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            
            guard let self else {return}
            self.presenter.reloadingImage()
            showLoadingIndicator()
        }
        let alertPresenter = AlertPresenter(viewController: self)
        alertPresenter.show(alertModel: alertModel)
    }
}

