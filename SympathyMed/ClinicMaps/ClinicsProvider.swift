//
//  ClinicsProvider.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 16.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

protocol ClinicsProviderProtocol : TaskProtocol {
    
    func getClinics(taskId: String, complition: @escaping ([Clinic]) -> (), failure: @escaping (Error?) -> ())
}

class ClinicsProvider : ClinicsProviderProtocol {
    
    func getTaskWith(taskId: String) -> DataTask? {
        return TaskPool.shared.taskById(taskId)
    }
    
    func getClinics(taskId: String, complition: @escaping ([Clinic]) -> (), failure: @escaping (Error?) -> ()) {
        
        guard let clinicsRequest = RequestFactory().obtainGetRequestWith(urlString: "/clinics") else { failure(nil); return }
        
        TaskPool.shared.sendRequest(taskId: taskId, urlRequest: clinicsRequest) { (data, error) in
            
            guard let data = data else { DispatchQueue.main.async {failure(error)}; return }
            
            do {
                
                let clinics = try JSONDecoder().decode([Clinic].self, from: data)
                
                DispatchQueue.main.async { complition(clinics) }
                
            } catch let err {
                print("decode error \(err)")
                
                DispatchQueue.main.async { failure(err) }
            }
        }
    }
}
