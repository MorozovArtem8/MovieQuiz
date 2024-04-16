import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    //private var correctAnswers = 0
    
    
//    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private var presenter: MovieQuizPresenter!
    
    //MARK: IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        
        
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        activityIndicator.style = .large
    }
    
//    //MARK: - QuestionFactoryDelegate
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        hideLoadingIndicator()
//        presenter.didReceiveNextQuestion(question: question)
//    }
//    
//    func didLoadDataFromServer() {
//        questionFactory?.requestNextQuestion()
//    }
//    
//    func didFailToLoadData(with error: any Error) {
//        showNetworkError(message: error.localizedDescription)
//        print(error.localizedDescription)
//    }
//    
//    func didFailToLoadImage(with error: any Error) {
//        showLoadImageError(message: error.localizedDescription)
//    }
    
    //MARK: IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        
    }
    
    //MARK: func
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.yGreen.cgColor : UIColor.yRed.cgColor
        buttons.forEach {
            
            $0.isEnabled = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self]  in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.buttons.forEach {
                $0.isEnabled = true
            }
            
            self.presenter.showNextQuestionOrResults()
        }
        
    }
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        
//        QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
//        )
//        
//    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        if let bestGame = statisticService?.bestGame.correct,
           let date = statisticService?.bestGame.date,
           let gamesCount = statisticService?.gamesCount,
           let totalAccuracy = statisticService?.totalAccuracy {
            
            let newText = """
            \(result.text)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд \(bestGame)/10 (\(date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
            let alertModel = AlertModel(
                title: result.title,
                message: newText,
                buttonText: result.buttonText,
                completion: { [weak self] in
                    self?.presenter.restartGame()
                    
                })
            
            let alertPresenter = AlertPresenter(viewController: self)
            alertPresenter.show(alertModel: alertModel)
        }
        
    }
    
//    private func showNextQuestionOrResults() {
//        showLoadingIndicator()
//        if presenter.isLastQuestion() {
//            let text = correctAnswers == presenter.questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" :  "Ваш результат \(correctAnswers)/10"
//            let resultViewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text:  text, buttonText: "Сыграть еще раз")
//            show(quiz: resultViewModel)
//        }else {
//            presenter.switchToNextQuestion()
//            questionFactory?.requestNextQuestion()
//        }
//    }
    
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
            self.presenter.restartGame()
            showLoadingIndicator()
        }
        let alertPresenter = AlertPresenter(viewController: self)
        alertPresenter.show(alertModel: alertModel)
    }
    
    private func showLoadImageError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что то пошло не так",
            message: "Невозможно загрузить куартинку",
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            
            guard let self else {return}
            //self.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = AlertPresenter(viewController: self)
        alertPresenter.show(alertModel: alertModel)
    }
}

