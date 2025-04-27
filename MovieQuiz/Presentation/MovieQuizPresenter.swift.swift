import UIKit

final class MovieQuizPresenter {
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepModel {
        let questionStep = QuizStepModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    func yesButtonClicked() {
        guard let currentQuestion else {return}
        let result = true
        viewController?.showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
        viewController?.ButtonTapped(isEnabled: false)
    }
    func noButtonClicked() {
        guard let currentQuestion else {return}
        let result = false
        viewController?.showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
        viewController?.ButtonTapped(isEnabled: false)
        
    }
    
}
