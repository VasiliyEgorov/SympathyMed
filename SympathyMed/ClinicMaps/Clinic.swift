//
//  Clinic.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 16.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Foundation

struct Clinic : Decodable {
    
    let name : String
    let latitude : Double
    let longitude : Double
    let snippet : String
    let telephone : String
    let website : String
    let objectId : String
    let ___class: String
}
