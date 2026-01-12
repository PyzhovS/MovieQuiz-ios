import UIKit
class QuestionFactory:QuestionFactoryProtocol {
    
    enum Rating: String {
        case more = "Рейтинг этого фильма больше чем"
        case less = "Рейтинг этого фильма меньше чем"
    }
    
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
            guard let movie = self.movies.randomElement() else { return }
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {[weak self] in
                    guard let self else { return }
                    self.delegate?.showNetworkError(message: "Failed to load image")
                }
            }
            
            let askIfMore = Bool.random()
            let ratingText = 6...9
            let randomRating = Int.random(in: ratingText)
            guard let rating = Float(movie.rating) else {
                return
            }
            let text = askIfMore ? "\(Rating.more.rawValue) \(randomRating)?" : "\(Rating.less.rawValue) \(randomRating)?"
            let randomRatingText = Float(randomRating)
            let correctAnswerMore = rating > randomRatingText
            let correctAnswerLess = rating < randomRatingText
            let correctAnswer = askIfMore ? correctAnswerMore : correctAnswerLess
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
