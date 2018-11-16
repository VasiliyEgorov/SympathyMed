//
//  DataTask.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 02.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

class DataTask: Hashable, Equatable {
    
    let taskId: String
    var task : URLSessionDataTask?
    
    init(taskId: String) {
        self.taskId = taskId
    }
    
    // MARK: - Equatable
    
    static func ==(lhs: DataTask, rhs: DataTask) -> Bool {
        return lhs.taskId == rhs.taskId
    }
    
    // MARK: - Hashable
    
    var hashValue: Int {
        return taskId.hashValue
    }
}
