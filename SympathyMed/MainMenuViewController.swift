//
//  MultiplyOptionViewController.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 10.04.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    
    @IBOutlet var blockViewConstraints: [NSLayoutConstraint]!
    @IBOutlet var blockViews: [UIView]!
    @IBOutlet var borderViews: [UIView]!
    let stateChecker = StateChecker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if stateChecker.allowAnimations() {
            blockViewConstraints.forEach({ $0.isActive = false })
            blockViews.forEach({ $0.frame.origin.y += UIScreen.main.bounds.height })
            borderViews.forEach({ $0.isHidden = true })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimationWith(constraints: blockViewConstraints)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    private func startAnimationWith(constraints: [NSLayoutConstraint]) {

        constraints.forEach({ $0.isActive = true })
        
        UIView.animate(withDuration: 0.7,
                       delay: 0.0,
                       options: [.curveLinear],
                       animations: {
            
                        self.view.layoutIfNeeded()
        }) { (finished) in
            self.borderViews.forEach({ $0.isHidden = false })
        }
    }
    
    @IBAction func productRecognizeButtonAction(_ sender: UIButton) {
        guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let window = application.window else { return }
        let device = Device.init(rawValue: UIScreen.main.bounds.height)
        
        switch device {
        case .Iphone5?,.Iphone6_7?,.Iphone6_7_plus?,.IphoneX_Xs?,.IphoneXsMax_Xr?:
            let cameraNavController = AppStoryboard.MainIPhone.instance.instantiateViewController(withIdentifier: "TextDetectionNavController")
            window.rootViewController = cameraNavController
        case .IpadMini_Air?,.IpadPro10_5?,.Ipad11?,.IpadPro12_9?:
            let cameraNavController = AppStoryboard.MainIPad.instance.instantiateViewController(withIdentifier: "TextDetectionNavController")
            window.rootViewController = cameraNavController
        default: break
        }
    }
}
