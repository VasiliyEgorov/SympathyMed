//
//  MainScreenButton.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 31.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class MainScreenButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        self.titleLabel?.minimumScaleFactor = 0.5
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Light", size: self.bounds.height * 0.4)
    }
}
