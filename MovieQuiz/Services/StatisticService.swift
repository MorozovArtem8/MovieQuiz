import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
        guard let totalCorrect = userDefaults.object(forKey: Keys.correct.rawValue) as? Double, let totalQuestions = userDefaults.object(forKey: Keys.total.rawValue) as? Double else {return 0}
        return (totalCorrect / totalQuestions) * 100
    }
    
    var gamesCount: Int {
        
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
            
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        // При вызове функции сохраняем количество правильных ответов и общее количество вопросов, если ранее уже сохраняли - прибавляем уже к сохраненным значениям
        if let currentCount =  userDefaults.object(forKey: Keys.correct.rawValue) as? Double, let currentAmount = userDefaults.object(forKey: Keys.total.rawValue) as? Double {
            userDefaults.set(Double(count) + currentCount, forKey: Keys.correct.rawValue)
            userDefaults.set(Double(amount) + currentAmount, forKey: Keys.total.rawValue)
        }else {
            userDefaults.set(Double(count), forKey: Keys.correct.rawValue)
            userDefaults.set(Double(amount), forKey: Keys.total.rawValue)
        }
        gamesCount += 1
        let record = GameRecord(correct: count, total: amount, date: Date())
        if !bestGame.isBetterThan(record) {
            bestGame = record
            
        }
        
    }
    
}
