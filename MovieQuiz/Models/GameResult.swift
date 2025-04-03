import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func correctBest (_ result: GameResult) -> Bool {
        correct > result.correct
    }
}
