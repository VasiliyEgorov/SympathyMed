//
//  IPhoneCameraViewController.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 07.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class TextDetectionViewController: CameraViewController {
    
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var videoLayerView: UIView!
    @IBOutlet weak var captionView: CaptionView!
    var dimView: IndicatorDimView?
    var textDetection : TextDetectionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        configurePreviewLayerWith(videoView: videoLayerView)
        videoLayerView.bringSubview(toFront: msgLabel)
        videoLayerView.bringSubview(toFront: captionView)
        textDetection = TextDetectionHandler.init(preview: videoLayerView, captionView: captionView)
        setupSessionWith(textDetection: textDetection)
        self.captionView.captureDevice = captureDevice
        configureNotifications()
    }
   
    deinit {
        removeNotifications()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tryToRunSession()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotifications()
    }
    override func viewDidLayoutSubviews() {
        previewLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        previewLayer?.connection?.videoOrientation = .landscapeRight
        
    }
    func showNoConnectionAlert(message: String) {
        alertMessage("Error", message: message, titleAction: "OK", cancelAction: false)
    }
    
    func moveToResultsRecognitionControllerWith(code: String, codeRegistrationResult: CodeResult) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let window = application.window else { return }
        removeNotifications()
        DispatchQueue.main.async {
            if self.dimView == nil {
                self.dimView = self.setupSpinnerForCamera()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.removeSpinner(dimView: self.dimView)
            if let resultsCodeController = AppStoryboard.MainIPhone.instance.instantiateViewController(withIdentifier: "ResultsTextRecognitionController") as? ResultCodeRecognitionViewController {
                
                resultsCodeController.code = code
                resultsCodeController.codeRegistrationResult = codeRegistrationResult
                window.rootViewController = resultsCodeController
            }
        } 
    }
    // MARK: - Notifications
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(registrationDidComplete(notification:)), name: .RegistrationDidCompleteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(codeAlreadyRegistered(notification:)), name: .CodeAlreadyRegisteredNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noConnectionNotification), name: .NoConnectionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(incorrectNotification), name: .IncorrectNotification, object: nil)
    }
    
   
    @objc func registrationDidComplete(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let code = userInfo["code"] as? String {
           moveToResultsRecognitionControllerWith(code: code, codeRegistrationResult: .Registered)
        }
    }
    @objc func codeAlreadyRegistered(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let code = userInfo["code"] as? String {
            moveToResultsRecognitionControllerWith(code: code, codeRegistrationResult: .AlreadyRegistered)
        }
    }
  
    @objc func noConnectionNotification() {
        DispatchQueue.main.async {
            self.removeSpinner(dimView: self.dimView)
            self.showNoConnectionAlert(message: "There is no internet connection")
        }
    }
    
    @objc func incorrectNotification() {
        DispatchQueue.main.async {
            self.removeSpinner(dimView: self.dimView)
        }
    }
    // MARK: - Buttons Action
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        
        stopSession()
        
        DispatchQueue.main.async {
            guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let window = application.window else { return }
            let root = MainMenuViewController.instantiateFromAppStoryboard(appStoryboard: .MainIPhone)
            window.rootViewController = root
        }
    }
    
    @IBAction func checkOriginalityButtonAction(_ sender: UIButton) {
        DispatchQueue.main.async {
        guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let window = application.window else { return }
        let registrationNavController = AppStoryboard.MainIPhone.instance.instantiateViewController(withIdentifier: "RegistrationNavController")
        window.rootViewController = registrationNavController
        }
    }
    
    

}
