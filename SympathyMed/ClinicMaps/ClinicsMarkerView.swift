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

protocol OpenBrowserDelegate: class {
    func openBrowser(urlString: String)
}

class ClinicsMarkerView: UIView {

    @IBOutlet weak var websiteTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var snippetLabel: UILabel!
    @IBOutlet weak var telephoneLabel: UILabel!
    weak var closeButtonDelegate : CloseButtonDelegate?
    weak var openBrowserDelegate : OpenBrowserDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
        self.websiteTextView.textContainerInset = .zero
        self.websiteTextView.textContainer.lineFragmentPadding = 0
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.closeButtonDelegate?.closeButton(sender: sender)
    }
    
}

extension ClinicsMarkerView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.openBrowserDelegate?.openBrowser(urlString: URL.absoluteString)
        return false
    }
}
