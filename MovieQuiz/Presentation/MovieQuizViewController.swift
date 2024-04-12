import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    
    //MARK: IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
        activityIndicator.style = .large
    }
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
        print(error.localizedDescription)
    }
    
    func didFailToLoadImage(with error: any Error) {
        showLoadImageError(message: error.localizedDescription)
    }
    
    //MARK: IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let answer = false
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let answer = true
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
        
    }
    
    //MARK: func
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
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
            self.showNextQuestionOrResults()
        }
        
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
        )
        
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: questionAmount)
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
                completion: {
                    self.correctAnswers = 0
                    self.currentQuestionIndex = 0
                    self.questionFactory?.requestNextQuestion()
                })
            
            let alertPresentor = AlertPresenter(viewController: self)
            alertPresentor.show(alertModel: alertModel)
        }
        
    }
    
    private func showNextQuestionOrResults() {
        showLoadingIndicator()
        if currentQuestionIndex == questionAmount - 1 {
            let text = correctAnswers == questionAmount ? "Поздравляем, вы ответили на 10 из 10!" :  "Ваш результат \(correctAnswers)/10"
            let resultViewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text:  text, buttonText: "Сыграть еще раз")
            show(quiz: resultViewModel)
        }else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что то пошло не так",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            
            guard let self else {return}
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.loadData()
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
            self.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = AlertPresenter(viewController: self)
        alertPresenter.show(alertModel: alertModel)
    }
}

