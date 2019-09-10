//
//  CodeHandler.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 03.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

enum CodeResult: Int {
    case Registered, AlreadyRegistered, Incorrect
}

enum ResponseError: Int {
    case noConnection = -1009
    
}
class CodeRegistrationFromVcHelper {

    private let networkHandler = NetworkHandler()
    private var objectId : String?
    private var isRegistered: Bool?
    private let registerQueue = DispatchQueue(label: "com.sympathyMed.app.searialRegisterCodeQueue", qos: .userInitiated)
    
  
    func registerCode(code: String, complition: @escaping (CodeResult) -> (), failure: @escaping (ResponseError?) -> ()) {
        print("send code \(code)")
        self.registerQueue.async { [weak self] in
            
            self?.networkHandler.getCode(taskId: "getCode", code: code, complition: { (codes) in
                if let codes = codes, codes.count != 0 {
                    codes.forEach({ code in
                             self?.isRegistered = code.isRegistered
                             self?.objectId = code.objectId
                        })
                    
                    if let registered = self?.isRegistered, !registered, let objectId = self?.objectId {
                        self?.networkHandler.registerCode(taskId: "registerCode", code: code, objectId: objectId, complition: { (code) in
                            if code != nil {
                                DispatchQueue.main.async {complition(.Registered)}
                            }
                        }, failure: { (error) in
                            if let err = error {
                                DispatchQueue.main.async {failure(ResponseError.init(rawValue: err._code))}
                            }
                        })
                    } else {
                        DispatchQueue.main.async {complition(.AlreadyRegistered)}
                    }
                    
                } else {
                    DispatchQueue.main.async {complition(.Incorrect)}
                }
            }, failure: { (error) in
                if let err = error {
                    DispatchQueue.main.async {failure(ResponseError.init(rawValue: err._code))}
                }
            })
        }
    }
}
