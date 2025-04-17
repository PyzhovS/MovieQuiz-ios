import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var buttonYes: UIButton!
    @IBOutlet private var buttonNo: UIButton!
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory.delegate = self
        questionFactory.loadData()
        self.questionFactory = questionFactory
        let alertPresenter = AlertPresenter()
        alertPresenter.viewController = self
        self.alertPresenter = alertPresenter
        let statisticService = StatisticServiceImplementation()
        self.statisticService = statisticService
        showLoadingIndicator()
        ActivityIndicator.hidesWhenStopped = true
        viewNext()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
        
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message:error.localizedDescription)
        
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Setup Methods
    private func showLoadingIndicator() {
        ActivityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        ActivityIndicator.stopAnimating()
    }
    
    private func viewNext () {
        questionFactory?.requestNextQuestion()
        imageView.layer.borderColor = UIColor.clear.cgColor
        
    }
    private func convert(model: QuizQuestion) -> QuizStepModel {
        let questionStep = QuizStepModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        stopButtonTapped(isEnabled: true)
        hideLoadingIndicator()
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
            showNextQuestionOrResults()
        }
    }
    
    // Добавил функцию, которая исключает лишнее нажатие на кнопки(при быстром нажатие), что приводила к неверному результату в конце.
    private func stopButtonTapped(isEnabled: Bool) {
        
        buttonNo.isEnabled = isEnabled
        buttonYes.isEnabled = isEnabled
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let statisticService else { return }
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount )
            Количество сыграных квизов:\(statisticService.gamesCount)
            Рекорд:\(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность:\(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let resultsModel = QuizResultsModel(title: "Этот раунд окончен!" ,
                                                text: text,
                                                buttonText:"Сыграть ещё раз")
            
            showAlert(model: resultsModel)
            
            func showAlert ( model: QuizResultsModel){
                let final = AlertModel (title:model.title,
                                        message: model.text,
                                        buttonText: model.buttonText,
                                        completion: {[weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.viewNext()
                    stopButtonTapped(isEnabled: true)
                })
                
                self.alertPresenter?.show(quiz: final)
            }
        } else { currentQuestionIndex += 1
            
            self.viewNext()
            showLoadingIndicator()
            
        }
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertErorr = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз",
                                    completion: { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.viewNext()
            stopButtonTapped(isEnabled: true)
            
            //добавил, что бы при нажати на Попробуй еще раз, была повторная поытка подключения, а не просто белый экран.
            questionFactory?.loadData()
        })
        alertPresenter?.show(quiz: alertErorr)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {return}
        let result = true
        showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
        stopButtonTapped(isEnabled: false)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {return}
        let result = false
        showAnswerResult(isCorrect: result == currentQuestion.correctAnswer)
        stopButtonTapped(isEnabled: false)
    }
}
