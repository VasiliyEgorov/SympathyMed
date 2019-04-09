//
//  CameraNavController.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 11.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class CameraNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBar.isTranslucent = true
        self.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = .clear
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.tintColor = .white
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationBar.backIndicatorImage = UIImage.init(named: "backButton.png")
        self.navigationBar.backIndicatorTransitionMaskImage = UIImage.init(named: "backButton.png")
    }
   
}
