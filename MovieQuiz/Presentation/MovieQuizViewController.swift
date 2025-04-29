import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak private var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var buttonYes: UIButton!
    @IBOutlet private var buttonNo: UIButton!
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.viewController = self
        self.alertPresenter = alertPresenter
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        ActivityIndicator.hidesWhenStopped = true
        borderColorClear()
    }
    
    // MARK: - Setup Methods
    func showLoadingIndicator() {
        ActivityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        ActivityIndicator.stopAnimating()
    }
    
    func borderColorClear () {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func show(quiz step: QuizStepModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        ButtonTapped(isEnabled: true)
        hideLoadingIndicator()
    }
    
    func showAnswerBorderColor(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor: UIColor.ypRed.cgColor
    }
    
    func ButtonTapped(isEnabled: Bool) {
        buttonNo.isEnabled = isEnabled
        buttonYes.isEnabled = isEnabled
    }
    
    func showAlert ( model: QuizResultsModel){
        let final = AlertModel (title:model.title,
                                message: model.text,
                                buttonText: model.buttonText,
                                completion: {[weak self] in
            guard let self else { return }
            self.presenter.restartGame()
            borderColorClear()
            ButtonTapped(isEnabled: true)
        })
        
        self.alertPresenter?.show(quiz: final)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertErorr = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз",
                                    completion: { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
            borderColorClear()
            ButtonTapped(isEnabled: true)
            presenter.questionFactory?.loadData()
        })
        alertPresenter?.show(quiz: alertErorr)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
