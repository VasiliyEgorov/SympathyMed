//
//  ClinicsMarkerView.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 21.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

protocol CloseButtonDelegate : class {
    func closeButton(sender: UIButton)
}

class ClinicsMarkerView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var snippetLabel: UILabel!
    @IBOutlet weak var telephoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    weak var delegate : CloseButtonDelegate?
   
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.delegate?.closeButton(sender: sender)
    }
}
