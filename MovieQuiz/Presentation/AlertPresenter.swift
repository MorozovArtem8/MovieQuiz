import UIKit

class AlertPresenter {
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func showResultAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default, handler: {_ in
            alertModel.completion()
        })
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
