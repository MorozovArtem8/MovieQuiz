import Foundation

extension Date {
    static var dateTimeString: String {
        DateFormatter.defaultDateTime.string(from: Date())
    }
    
}

private extension DateFormatter {
    static let defaultDateTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY hh:mm"
        return dateFormatter
    }()
}

