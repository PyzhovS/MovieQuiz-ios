import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
   
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewNext()
    }
    
    private func viewNext () {
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
        imageView.layer.borderColor = UIColor.ypWhite.cgColor
        
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
        
    }
  
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
  
    }
   
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 6
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 6
      
        if isCorrect == true {imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        }
        else {imageView.layer.borderColor = UIColor.ypRed.cgColor}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextQuestionOrResults()
            
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let resultFinal = "Ваш результат: \(correctAnswers) / \(questions.count)"
            let final = QuizResultsViewModel(title: "Этот раунд окончен!" ,
                                             text: resultFinal,
                                             buttonText:"Сыграть ещё раз" )
            show(quiz: final)
            
        } else { currentQuestionIndex += 1
            viewNext()
            }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
               self.currentQuestionIndex = 0
               self.correctAnswers = 0
               self.viewNext()
        }
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
        
    }
    
   
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let result = true
    showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
        
       
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let result = false
        showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
}
