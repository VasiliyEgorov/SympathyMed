//
//  CaptionView.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 29.04.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit
import AVFoundation

class CaptionView: UIView {

    var captureDevice : AVCaptureDevice?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleFocusOnTap(recognizer:)))
        self.addGestureRecognizer(tapGesture)
    }
    @objc private func handleFocusOnTap(recognizer: UITapGestureRecognizer) {
        
        guard let captureDevice = self.captureDevice else { return }
        
        if captureDevice.position == .back {
            
            let focusPoint = recognizer.location(in: self)
            let focusX = focusPoint.x / self.frame.size.width
            let focusY = focusPoint.y / self.frame.size.height
            
            if recognizer.state == .ended {
                
                if captureDevice.isFocusModeSupported(.autoFocus) && captureDevice.isFocusPointOfInterestSupported {
                    do {
                        try captureDevice.lockForConfiguration()
                        
                        captureDevice.focusMode = .autoFocus
                        captureDevice.focusPointOfInterest = CGPoint(x: focusX, y: focusY)
                        captureDevice.focusMode = .continuousAutoFocus
                        captureDevice.unlockForConfiguration()
                    } catch {
                        let error = error as NSError
                        fatalError("Unresolved error \(error), \(error.userInfo)")
                    }
                }
            }
        }
    }

}
