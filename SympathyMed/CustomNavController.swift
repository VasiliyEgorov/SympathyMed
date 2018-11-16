//
//  CustomNavController.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 07.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class CustomNavController: UINavigationController {

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
        self.navigationBar.backIndicatorImage = UIImage.init(named: "backButton.png")
        self.navigationBar.backIndicatorTransitionMaskImage = UIImage.init(named: "backButton.png")
        self.navigationBar.tintColor = .black
    }

}
