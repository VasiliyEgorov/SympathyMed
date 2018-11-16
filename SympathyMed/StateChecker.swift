//
//  StateChecker.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 01.06.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

struct StateChecker {
    
    private let kAnimationKey = "kAnimationKey"
    
    func allowAnimations() -> Bool {
        
        let userDefaults = UserDefaults.standard
        let isAllowed = userDefaults.bool(forKey: kAnimationKey)
        if isAllowed {
            return true
        } else {
            return false
        }
    }
    
    func saveState(isAnimationAllowed: Bool) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(isAnimationAllowed, forKey: kAnimationKey)
        userDefaults.synchronize()
    }
}
