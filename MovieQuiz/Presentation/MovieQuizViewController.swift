import UIKit

final class MovieQuizViewController: UIViewController {
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private let questions: [QuizQuestion] = [QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    //MARK: IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentQuestion = questions[currentQuestionIndex]
        let currentStepViewMode = convert(model: currentQuestion)
        show(quiz: currentStepViewMode)
        
    }
    
    //MARK: IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let answer = false
        showAnswerResult(isCorrect: answer == questions[currentQuestionIndex].correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let answer = true
        showAnswerResult(isCorrect: answer == questions[currentQuestionIndex].correctAnswer)
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0
            self.buttons.forEach {
                $0.isEnabled = true
            }
            self.showNextQuestionOrResults()
        }
        
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return quizStepViewModel
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let firstViewModel = self.convert(model: firstQuestion)
            self.show(quiz: firstViewModel)
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let resultViewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text:  "Ваш результат \(correctAnswers)/\(questions.count)", buttonText: "Сыграть еще раз")
            show(quiz: resultViewModel)
        }else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let nextStepViewModel = convert(model: nextQuestion)
            show(quiz: nextStepViewModel)
        }
    }
    
}

