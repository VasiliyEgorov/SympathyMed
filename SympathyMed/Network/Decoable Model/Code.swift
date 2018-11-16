//
//  Code.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 02.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

struct Code: Decodable {
    let regCode: String
    let isRegistered: Bool
    let objectId : String
    let ___class: String?
}


struct MessageForPut: Codable {
    let regCode: String
    let isRegistered : Bool
}
