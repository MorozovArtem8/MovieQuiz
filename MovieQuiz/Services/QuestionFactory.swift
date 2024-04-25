import UIKit

class QuestionFactory: QuestionFactoryProtocol {
    
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData(){
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0...self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else {return}
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizeImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadImage(with: error)
                    return
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let intRating = Int(rating)
            let raitingForQuestion: Int = (intRating...intRating + 1).randomElement() ?? intRating
            let text = "Рейтинг этого фильма больше чем \(raitingForQuestion)?"
            let correctAnswer = rating >= Float(raitingForQuestion)
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}

