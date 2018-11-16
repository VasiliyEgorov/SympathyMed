//
//  CodeRegistrationFromTxtRecognizerHandler.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 04.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

class CodeRegistrationFromTxtRecognizerHandler: CodeRegistrationFromVcHelper {
    
    private let codeLenght = 8
    
    func checkCode(code: String) -> String? {
        
        guard code.count == codeLenght else { return nil }
        guard code.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil else { return nil }
        
        return code
        
    }
    
}
