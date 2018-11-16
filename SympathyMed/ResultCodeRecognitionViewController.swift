//
//  ResultCodeRecognitionViewController.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 07.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class ResultCodeRecognitionViewController: UIViewController {

  
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var codeLabel: RegistrationResultLabel!
    @IBOutlet weak var messageLabel: RegistrationResultLabel!
    var codeRegistrationResult : CodeResult?
    var code : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureLabels()
    }

    private func configureLabels() {
        if let code = code {
            codeLabel.text = "Code: " + code
        }
        
        if codeRegistrationResult == .Registered {
            self.resultImageView.image = UIImage.init(named: "doneThick.png")
            messageLabel.codeRegistered()
        } else  {
            self.resultImageView.image = UIImage.init(named: "warning.png")
            messageLabel.codeAlreadyRegistered()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backButtonAction(_ sender: UIButton) {

        DispatchQueue.main.async {
            guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let window = application.window else { return }
            let root = MainMenuViewController.instantiateFromAppStoryboard(appStoryboard: .MainIPhone)
            window.rootViewController = root
        }
    }

}
