//
//  NetworkHandler.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 10.04.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

protocol TaskProtocol: class {
    func getTaskWith(taskId: String) -> DataTask?
}

protocol CodeNetworkHandlerProtocol: TaskProtocol {
    
    func getCode(taskId: String, code: String, complition: @escaping ([Code]?) -> Void, failure: @escaping (Error?) -> Void)
    func registerCode(taskId: String, code: String, objectId: String, complition: @escaping (Code?) ->(), failure: @escaping (Error?) -> ())
}

class NetworkHandler: CodeNetworkHandlerProtocol {
    
    func getTaskWith(taskId: String) -> DataTask? {
        return TaskPool.shared.taskById(taskId)
    }
    
    func getCode(taskId: String, code: String, complition: @escaping ([Code]?) -> (), failure: @escaping (Error?) -> ()) {
        
        guard let newCodeGetRequest = RequestFactory().obtainGetRequestWith(urlString: "/spacers?where=regCode%3D" + code + "&props=regCode%2CisRegistered") else { complition(nil); return }
    
        TaskPool.shared.sendRequest(taskId: taskId, urlRequest: newCodeGetRequest, complition: { (data, error) in
            
            guard let data = data else { failure(error); return }
            
            do {
                let codes = try JSONDecoder().decode([Code].self, from: data)
                
                    complition(codes)
                
            } catch let error {
                print("decode error \(error)")
                
                    failure(error)
            }
        })
    }
    
    func registerCode(taskId: String, code: String, objectId: String, complition: @escaping (Code?) ->(), failure: @escaping (Error?) -> ()) {
        
        let message = MessageForPut(regCode: code, isRegistered: true)
        
        guard let newCodePostRequest = RequestFactory().obtainPutRequestWith(urlString: "/spacers/" + objectId, dataToPut: message) else { complition(nil); return }
        
        TaskPool.shared.sendRequest(taskId: taskId, urlRequest: newCodePostRequest) { (data, error) in
            
            guard let data = data else {failure(error); return }
            
            do {
                let postAnswer = try JSONDecoder().decode(Code.self, from: data)
                
                    complition(postAnswer)
                
            } catch let error {
                print("decode error \(error)")
                
                    failure(error)
            }
 
            print(data)
        }
    }
}
