//
//  CodeTextField.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 05.06.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

class CodeTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.font = UIFont.init(name: "HelveticaNeue-Thin", size: self.frame.size.height * 0.6)
    }
}
