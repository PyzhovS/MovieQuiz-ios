protocol MovieQuizViewControllerProtocol: AnyObject {
  
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func borderColorClear ()
    func buttonTapped(isEnabled: Bool)
    func show(quiz step: QuizStepModel)
    func showAnswerBorderColor(isCorrect: Bool)
    func showAlert ( model: QuizResultsModel)
    func showNetworkError(message: String)
}
