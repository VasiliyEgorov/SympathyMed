//
//  RegistrationResultLabel.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 06.06.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class RegistrationResultLabel: UILabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.text = ""
        self.minimumScaleFactor = 0.5
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.font = UIFont.init(name: "HelveticaNeue-Thin", size: self.frame.size.height * 0.4)
    }
    
   
    func codeAlreadyRegistered() {
        self.text = "The code was already registered"
        self.textColor = .red
        
    }
    func codeRegistered() {
        self.text = "Your product is authentic and the code is successfully registered"
        self.textColor = .darkGray
    }

}
