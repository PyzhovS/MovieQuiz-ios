import UIKit

class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case total
        case date
        case answers
    }
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {storage.integer(forKey: Keys.gamesCount.rawValue)}
        set {storage.set(newValue , forKey: Keys.gamesCount.rawValue)}
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    var totalAccuracy: Double {
        guard gamesCount > 0 else { return 0}
        
        let result = Double(correctAnswers/gamesCount * 10)
        return result
    }
    
    var correctAnswers: Int{
        get {storage.integer(forKey: Keys.answers.rawValue)}
        set {storage.set(newValue , forKey: Keys.answers.rawValue)}
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.correct > bestGame.correct {
            bestGame = newGameResult
        }
        correctAnswers += count
    }
    
}

