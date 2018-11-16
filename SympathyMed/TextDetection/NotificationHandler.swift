//
//  NotificationHandler.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 07.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

struct NotificationHandler {
    
    func registrationDidStartNotification() {
        
        let sendRegistrationDidStart = Notification(name: .RegistrationDidStartNotification)
        NotificationCenter.default.post(sendRegistrationDidStart)
    }
    
    func registrationDidCompleteNotification(code: String) {
        
        let dict = ["code" : code]
        let registrationDidCompleteNotification = Notification(name: .RegistrationDidCompleteNotification, object: nil, userInfo: dict)
        NotificationCenter.default.post(registrationDidCompleteNotification)
    }
    
    func alreadyRegisteredNotification(code: String) {
        
        let dict = ["code" : code]
        let alreadyRegisteredNotification = Notification(name: .CodeAlreadyRegisteredNotification, object: nil, userInfo: dict)
        NotificationCenter.default.post(alreadyRegisteredNotification)
    }
    
    func incorrectNotification () {
        let incorrectNotification = Notification(name: .IncorrectNotification)
        NotificationCenter.default.post(incorrectNotification)
    }
    func noConnectionNotification() {
        let noConnectionNotification = Notification(name: .NoConnectionNotification)
        NotificationCenter.default.post(noConnectionNotification)
    }
}
