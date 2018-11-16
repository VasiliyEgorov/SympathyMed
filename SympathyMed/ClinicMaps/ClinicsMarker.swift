//
//  ClinicsIcon.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 22.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit
import GoogleMaps

class ClinicsMarker : GMSMarker {
    
    let clinic : Clinic
    
    init(clinic: Clinic) {
        self.clinic = clinic
        super.init()
        let coords = CLLocationCoordinate2DMake(clinic.latitude, clinic.longitude)
        position = coords
        icon = UIImage.resizeMarker(image: UIImage.init(named: "locationMarker.png"), scaledToSize: CGSize(width: 30, height: 40))
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
    
}
