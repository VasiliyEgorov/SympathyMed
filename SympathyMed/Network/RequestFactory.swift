//
//  RequestFactory.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 02.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

protocol RequestFactoryProtocol {
    
    func obtainGetRequestWith(urlString: String) -> URLRequest?
    func obtainPutRequestWith(urlString: String, dataToPut: MessageForPut) -> URLRequest?
}

class RequestFactory: RequestFactoryProtocol {
    
    private let baseURLString = "https://api.backendless.com/"
    private let applicationId = "F54079CB-B4D5-DA3A-FFD3-9E21179C8100/"
    private let restApiKey = "FF6C3E59-4E8D-A400-FF63-1A6596A24E00/"
    private let tableUrl = "data"
    private let whereClose = "?where=regCode%3D"
    private let paramsUrl = "&props=regCode%2CisRegistered"
    private var urlWithKeys : String {
        return baseURLString + applicationId + restApiKey + tableUrl
    }
    
    func obtainGetRequestWith(urlString: String) -> URLRequest? {
        
        let components = URLComponents(string: urlWithKeys + urlString)
    
        guard let url = components?.url else { return nil }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        
        return request
    }
    func obtainPutRequestWith(urlString: String, dataToPut: MessageForPut) -> URLRequest? {
        
        guard let url = URL(string: urlWithKeys + urlString) else { return nil }
        
        var request = URLRequest.init(url: url)
        
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application-type", forHTTPHeaderField: "REST")
        guard let httpBody = try? JSONEncoder().encode(dataToPut) else { return nil }
       
        request.httpBody = httpBody
        
        return request
    }
}
