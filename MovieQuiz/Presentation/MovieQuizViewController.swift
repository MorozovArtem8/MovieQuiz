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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
// Удаление сохраненных данных для тестирования
//        UserDefaults.standard.removeObject(forKey: "gamesCount")
//        UserDefaults.standard.removeObject(forKey: "bestGame")
//        UserDefaults.standard.removeObject(forKey: "total")
//        UserDefaults.standard.removeObject(forKey: "correct")
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
        
    }
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self]  in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.buttons.forEach {
                $0.isEnabled = true
            }
            self.showNextQuestionOrResults()
        }
        
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return quizStepViewModel
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: questionAmount)
        // Через конструкцию if let пытаемся вытащить все данные из statisticService
        if let bestGame = statisticService?.bestGame.correct, let date = statisticService?.bestGame.date, let gamesCount = statisticService?.gamesCount, let totalAccuracy = statisticService?.totalAccuracy {
            // Если все данные удалось извлечь создаем новый текст в алерте
            let newText = "\(result.text) \n Количество сыгранных квизов: \(gamesCount) \n Рекорд \(bestGame)/10 \(date.dateTimeString) \n Средняя точность: \(String(format: "%.2f", totalAccuracy))%"
            
            let alertModel = AlertModel(title: result.title, message: newText, buttonText: result.buttonText, completion: {
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            })
            
            let alertPresentor = AlertPresenter(viewController: self)
            alertPresentor.showResultAlert(alertModel: alertModel)
        }
        
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            let text = correctAnswers == questionAmount ? "Поздравляем, вы ответили на 10 из 10!" :  "Ваш результат \(correctAnswers)/10"
            let resultViewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text:  text, buttonText: "Сыграть еще раз")
            show(quiz: resultViewModel)
        }else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
}

