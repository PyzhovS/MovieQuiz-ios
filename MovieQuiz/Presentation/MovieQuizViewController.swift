import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
  
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    //private let questions: [QuizQuestion] = QuestionFactory.questions
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewNext()
    }
    
    // MARK: - Setup Methods
    
    private func viewNext () {
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion )
            show(quiz: viewModel)
            
        }
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    private func convert(model: QuizQuestion) -> QuizStepModel {
        let questionStep = QuizStepModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
  
    private func show(quiz step: QuizStepModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
   
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
      
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    
    // Добавил функцию, которая исключает лишнее нажатие на кнопки(при быстром нажатие), что приводила к неверному результату в конце.
    private func stopButtonTapped(sender: UIButton) {
            sender.isEnabled = false
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0) {
                sender.isEnabled = true
            }
        }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                        "Поздравляем, вы ответили на 10 из 10!" :
                        "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let final = QuizResultsModel(title: "Этот раунд окончен!" ,
                                         text: text,
                                         buttonText:"Сыграть ещё раз" )
            show(quiz: final)
            
        } else { currentQuestionIndex += 1
            viewNext()
            }
    }
  
    private func show(quiz result: QuizResultsModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else {return}
               self.currentQuestionIndex = 0
               self.correctAnswers = 0
               self.viewNext()
        }
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {return}
        let result = true
    showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
        stopButtonTapped(sender: sender)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {return}
        let result = false
        showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
        stopButtonTapped(sender: sender)
    }
}
