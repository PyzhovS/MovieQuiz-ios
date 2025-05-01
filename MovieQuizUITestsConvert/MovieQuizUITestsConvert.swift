import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func showLoadingIndicator(){}
    func hideLoadingIndicator(){}
    func borderColorClear () {}
    func buttonTapped(isEnabled: Bool) {}
    func show(quiz step: QuizStepModel){}
    func showAnswerBorderColor(isCorrect: Bool){}
    func showAlert ( model: QuizResultsModel){}
    func showNetworkError(message: String){}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController:viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    // Добавил еще пару проверок
    
    func testRestartGame() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController:viewControllerMock)
        
        sut.currentQuestionIndex = 3
        sut.correctAnswers = 4
        
        
        sut.restartGame()
        XCTAssertEqual(sut.currentQuestionIndex, 0 )
        XCTAssertEqual(sut.correctAnswers, 0)
    }
   
    func testShowAnswer() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController:viewControllerMock)
        
        sut.correctAnswers = 1
        sut.showAnswer(isCorrect: true)
       
        XCTAssertEqual(sut.correctAnswers, 2)
    }
}
