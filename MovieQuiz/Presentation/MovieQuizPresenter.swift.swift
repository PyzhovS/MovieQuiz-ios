import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
   
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message:error.localizedDescription)
        
    }
    
    func showNetworkError(message: String) {
        viewController?.showNetworkError(message: message)
    }
    
    // MARK: - Properties
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var statisticService: StatisticServiceProtocol?
    var questionFactory: QuestionFactoryProtocol?
    
    init() {
        statisticService = StatisticService()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }
    
    var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var correctAnswers = 0
    
    
    // MARK: - Setup Methods
    
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
    didAnswer(isYes: true)
    }
    func noButtonClicked() {
    didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes:Bool) {
        guard let currentQuestion else {return}
        let result = isYes
        viewController?.showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
        viewController?.ButtonTapped(isEnabled: false)
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
         guard let question else {
             return
         }
         
         currentQuestion = question
         let viewModel = convert(model: question)
         DispatchQueue.main.async { [weak self] in
             self?.viewController?.show(quiz: viewModel)
         }
     }
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let statisticService else { return }
            let text = """
             Ваш результат: \(correctAnswers)/\( questionsAmount )
             Количество сыграных квизов:\(statisticService.gamesCount)
             Рекорд:\(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
             Средняя точность:\(String(format: "%.2f", statisticService.totalAccuracy))%
             """
            
            let resultsModel = QuizResultsModel(title: "Этот раунд окончен!" ,
                                                text: text,
                                                buttonText:"Сыграть ещё раз")
            
                viewController?.showAlert(model: resultsModel)
        
            
         } else { switchToNextQuestion()
             
             self.viewController?.viewNext()
                 viewController?.showLoadingIndicator()
         }
     }
    
}
