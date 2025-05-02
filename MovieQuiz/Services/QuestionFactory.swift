import UIKit
class QuestionFactory:QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
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
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {[weak self] in
                    guard let self else { return }
                    delegate?.showNetworkError(message: "Failed to load image")
                }
                
            }
            // реализовал логику вопросов
            
            let randomIndex = (1...2).randomElement() ?? 0
            let randomRating = (6...9).randomElement() ?? 0
            let rating = Float(movie.rating) ?? 0
            var text = String()
            let textMore = "Рейтинг этого фильма больше чем \(randomRating)?"
            let textLess = "Рейтинг этого фильма меньше чем \(randomRating)?"
            let correctAnswerMore = rating > Float(randomRating)
            let correctAnswerLess = rating < Float(randomRating)
            var correctAnswer = Bool()
            if randomIndex == 1 {
                text = textMore
                correctAnswer = correctAnswerMore
            } else {
                text = textLess
                correctAnswer = correctAnswerLess
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
                
            }
        }
    }
}
