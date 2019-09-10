//
//  TextRecognizerHandler.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 30.04.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import Vision
import UIKit
import CoreML

class TextRecognizerHandler {
    
    let codeHandler = CodeRegistrationFromTxtRecognizerHandler()
    
    lazy var notificationHandler : NotificationHandler = {
        let handler = NotificationHandler()
        return handler
    }()
    var isRunning = false
    //HOLDS OUR INPUT
    var inputImage : CIImage? {
        didSet {
            if let newImage = inputImage {
                doOCR(ciImage: newImage)
            }
        }
    }
    
    //RESULT FROM OVERALL RECOGNITION
    var recognizedCode = String() {
        didSet {
            
            if let code = codeHandler.checkCode(code: recognizedCode), !self.isRunning {
        
                    self.notificationHandler.registrationDidStartNotification()
                    codeHandler.registerCode(code: code, complition: { [weak self] (codeResult) in
                        switch codeResult {
                        case .Registered: self?.notificationHandler.registrationDidCompleteNotification(code: code)
                        case .AlreadyRegistered: self?.notificationHandler.alreadyRegisteredNotification(code: code)
                        case .Incorrect: self?.isRunning = false
                        }
                    }) { [weak self] (responseError) in
                        
                        switch responseError {
                            case .noConnection?: self?.notificationHandler.noConnectionNotification(); self?.isRunning = false
                            default: self?.notificationHandler.incorrectNotification(); self?.isRunning = false
                        }
                    }
            } else {
                self.isRunning = false
            }
        }
    }
    
    //RESULT FROM RECOGNITION
    var recognizedRegion = String()
    
    
    //OCR
    lazy var ocrRequest: VNCoreMLRequest = { [weak self] in
        do {
            //THIS MODEL IS TRAINED BY ME FOR FONT "Inconsolata" (Numbers 0...9 and UpperCase Characters A..Z)
            let model = try VNCoreMLModel(for:OCR().model)
            return VNCoreMLRequest(model: model, completionHandler: { [weak self] (VNRequest, error) in
                guard let observations = VNRequest.results as? [VNClassificationObservation]
                    else { return }//fatalError("unexpected result") }
                guard let best = observations.first
                    else { fatalError("cant get best result")}
                
                self?.recognizedRegion = (self?.recognizedRegion.appending(best.identifier)) ?? ""
            })
        } catch {
            fatalError("cannot load model")
        }
    }()

    //TEXT-DETECTION
    lazy var textDetectionRequest: VNDetectTextRectanglesRequest = { [weak self] in
        return VNDetectTextRectanglesRequest(completionHandler: { [weak self] (VNRequest, error) in
            guard let observations = VNRequest.results as? [VNTextObservation]
                else {fatalError("unexpected result") }
            
            // EMPTY THE RESULTS
            self?.recognizedCode = ""
            
            //NEEDED BECAUSE OF DIFFERENT SCALES
            let  transform = CGAffineTransform.identity.scaledBy(x: (self?.inputImage?.extent.size.width)!, y:  (self?.inputImage?.extent.size.height)!)
            
            //A REGION IS LIKE A "WORD"
            for region:VNTextObservation in observations
            {
                guard let boxesIn = region.characterBoxes else {
                    continue
                }
                
                //EMPTY THE RESULT FOR REGION
                self?.recognizedRegion = ""
                
                //A "BOX" IS THE POSITION IN THE ORIGINAL IMAGE (SCALED FROM 0... 1.0)
                for box in boxesIn
                {
                    //SCALE THE BOUNDING BOX TO PIXELS
                    let realBoundingBox = box.boundingBox.applying(transform)
                    
                    //TO BE SURE
                    guard (self?.inputImage?.extent.contains(realBoundingBox))!
                        else { print("invalid detected rectangle"); return}
                    
                    //SCALE THE POINTS TO PIXELS
                    let topleft = box.topLeft.applying(transform)
                    let topright = box.topRight.applying(transform)
                    let bottomleft = box.bottomLeft.applying(transform)
                    let bottomright = box.bottomRight.applying(transform)
                    
                    //LET'S CROP AND RECTIFY
                    let charImage = self?.inputImage?
                        .cropped(to: realBoundingBox)
                        .applyingFilter("CIPerspectiveCorrection", parameters: [
                            "inputTopLeft" : CIVector(cgPoint: topleft),
                            "inputTopRight" : CIVector(cgPoint: topright),
                            "inputBottomLeft" : CIVector(cgPoint: bottomleft),
                            "inputBottomRight" : CIVector(cgPoint: bottomright)
                            ])
                    
                    //PREPARE THE HANDLER
                    let handler = VNImageRequestHandler(ciImage: charImage!, options: [:])
                    
                    //SOME OPTIONS (TO PLAY WITH..)
                    self?.ocrRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
                    
                    //FEED THE CHAR-IMAGE TO OUR OCR-REQUEST - NO NEED TO SCALE IT - VISION WILL DO IT FOR US !!
                    do {
                        try handler.perform([self!.ocrRequest])
                    }  catch { print("Error")}
                    
                }
                
                //APPEND RECOGNIZED CHARS FOR THAT REGION
                self?.recognizedCode.append(contentsOf: self?.recognizedRegion ?? "")
                //print(self?.recognizedCode)
            }
            
        })
    }()
    
   
    func doOCR(ciImage:CIImage) {
        self.isRunning = true
        //PREPARE THE HANDLER
        let handler = VNImageRequestHandler(ciImage: ciImage, options:[:])
        
        //WE NEED A BOX FOR EACH DETECTED CHARACTER
        self.textDetectionRequest.reportCharacterBoxes = true
        self.textDetectionRequest.preferBackgroundProcessing = false
        
        //FEED IT TO THE QUEUE FOR TEXT-DETECTION
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try  handler.perform([self.textDetectionRequest])
            } catch {
                print ("Error")
            }
        }
        
    }
}
