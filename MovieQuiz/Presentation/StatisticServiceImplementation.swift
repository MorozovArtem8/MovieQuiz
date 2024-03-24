import UIKit

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
            // если пытаемся получить значение которого нет - запишется и вернется 0
            guard let gameInt = userDefaults.object(forKey: Keys.gamesCount.rawValue) else {
                userDefaults.set(0, forKey: Keys.gamesCount.rawValue)
                return 0
            }
            return gameInt as! Int
        }
        
        set {
            //устанавливаем новое значение
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
            print("сохранил \(data)")
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
        // Добавляем  + 1 к количеству игру
        gamesCount += 1
        // Создаем новый экземпляр GameRecord и сравнием с сохраненным
        let record = GameRecord(correct: count, total: amount, date: Date())
        if !bestGame.isBetterThan(record) {
            bestGame = record
            
        }
        
    }
    
}
