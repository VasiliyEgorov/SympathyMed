//
//  RegistrationViewController.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 02.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var titleLabel: RegistrationTitleLabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var registerBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    private var dimView : IndicatorDimView?
    private var codeHandler = CodeRegistrationFromVcHelper()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeOnNotifications()
        self.registerButton.alpha = 0
        changeConstraints()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        codeTextField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }

    func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(UITextFieldTextDidChange(notification:)), name: .UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIKeyboardDidShow(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIKeyboardDidHide(notification:)), name: .UIKeyboardDidHide, object: nil)
    }
    
    func changeConstraints() {
        let device = Device.init(rawValue: UIScreen.main.bounds.height)
        switch device {
            case .Iphone5?: titleTopConstraint.constant = 30
            case .Iphone6_7_plus?: titleTopConstraint.constant = 85
            case .Iphone6_7?: titleTopConstraint.constant = 70
            case .IphoneX?: titleTopConstraint.constant = 85
        default: return
            self.view.updateConstraintsIfNeeded()
        }
    }
    //MARK: - Button action
    @IBAction func registerButtonAction(_ sender: UIButton) {
        self.dimView = setupSpinner()
        self.codeTextField.resignFirstResponder()
        codeHandler.registerCode(code: codeTextField.text!, complition: { (result) in
            
            self.removeSpinner(dimView: self.dimView)
            
            switch result {
                case .Incorrect: self.prepareForError(titleLabel: self.titleLabel, codeTextField: self.codeTextField); self.codeTextField.becomeFirstResponder()
                default: self.moveToResultsController(code: self.codeTextField.text, result: result)
            }
            
            
        }) { (responseError) in
            self.codeTextField.becomeFirstResponder()
            self.removeSpinner(dimView: self.dimView)
            switch responseError {
                case .noConnection?: self.showAlert(message: "There is no internet connection")
                default: return
            }
        }
    }
    
    func prepareForError(titleLabel: RegistrationTitleLabel, codeTextField: UITextField) {
        titleLabel.text = "Incorrect code"
        titleLabel.textColor = .red
        codeTextField.textColor = .red
    }
    
    func prepareForNormalState(titleLabel: RegistrationTitleLabel, codeTextField: UITextField) {
        titleLabel.text = "Enter code"
        titleLabel.textColor = .black
        codeTextField.textColor = .black
    }
    
    func showAlert(message: String) {
        alertMessage("Error", message: message, titleAction: "OK", cancelAction: false)
    }
    
    // MARK: - Buttons
    
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    private func moveToResultsController(code: String?, result: CodeResult?) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let window = application.window else { return }
        let device = Device.init(rawValue: UIScreen.main.bounds.height)
        var controller : UIViewController?
        
        switch device {
        case .Iphone5?,.Iphone6_7?,.Iphone6_7_plus?,.IphoneX?:
            controller = setStoryboard(name: "MainIPhone", controllerIdentifier: "ResultsTextRecognitionController")
        case .IpadMini_Air?,.IpadPro10_5?,.IpadPro12_9?:
            controller = setStoryboard(name: "MainIPad", controllerIdentifier: "ResultsTextRecognitionController")
        default: break
        }
        
        if let resultsCodeController = controller as? ResultCodeRecognitionViewController {
    
            resultsCodeController.code = code
            resultsCodeController.codeRegistrationResult = result
            window.rootViewController = resultsCodeController
        }
    }
  
    func setStoryboard(name: String, controllerIdentifier: String) -> UIViewController? {
       
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: controllerIdentifier)
        return viewController
    }
    
    // MARK: - Notification
    
    @objc func UITextFieldTextDidChange(notification: Notification) {
        if self.codeTextField.textColor == .red {
            prepareForNormalState(titleLabel: self.titleLabel, codeTextField: self.codeTextField)
        }
    }
    @objc func UIKeyboardDidShow(notification: Notification) {
    
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        let codeTxtFieldLowerPoint = codeTextField.frame.origin.y + codeTextField.frame.size.height
        let keyboardHighestPoint = self.view.frame.size.height - keyboardFrame.cgRectValue.height
        let delta = keyboardHighestPoint - codeTxtFieldLowerPoint
        let newConstant = (delta - registerButton.frame.size.height) / 2
        registerBtnTopConstraint.constant = newConstant
        
        UIView.animate(withDuration: 0.3) {
            self.registerButton.alpha = 1
        }
    }
    
    @objc func UIKeyboardDidHide(notification: Notification) {

        UIView.animate(withDuration: 0.3) {
            self.registerButton.alpha = 0
        }
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
}
