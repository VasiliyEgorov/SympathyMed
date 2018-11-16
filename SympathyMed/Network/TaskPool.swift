//
//  TaskPool.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 02.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

protocol TaskPoolProtocol: class {
    
    func sendRequest(taskId: String, urlRequest: URLRequest, complition: @escaping (Data?, Error?) -> ())
    func taskById(_ taskId: String) -> DataTask?
}

class TaskPool: TaskPoolProtocol {
    
    static let shared = TaskPool()
    private lazy var session : URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return URLSession.init(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()
    private(set) var activeTasks = Set<DataTask>()
    private init() {}
    
    
    func sendRequest(taskId: String, urlRequest: URLRequest, complition: @escaping (Data?, Error?) -> ()) {
        if taskById(taskId) != nil {
            print("task with id \"\(taskId)\" is already active.")
            return
        }
        
        let newTask = DataTask.init(taskId: taskId)
        activeTasks.insert(newTask)
        
        newTask.task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            guard error == nil else { self.activeTasks.remove(newTask); complition(nil, error); return }
            self.activeTasks.remove(newTask)
            
            complition(data, nil)
            
        })
        newTask.task?.resume()
    }

    func taskById(_ taskId: String) -> DataTask? {
        return activeTasks.first(where: { (task) -> Bool in
            return task.taskId == taskId
        })
    }
}
