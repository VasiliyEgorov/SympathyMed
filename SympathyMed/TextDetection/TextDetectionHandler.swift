//
//  AVCaptureVideoDelegate.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 28.04.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class TextDetectionHandler: NSObject {
    private var requests = [VNRequest]()
    private let previewView : UIView
    private let captionView : UIView
    private let textRecognizer = TextRecognizerHandler()
    private var buffer : CMSampleBuffer!
    
    private lazy var textRequest : VNDetectTextRectanglesRequest = { [weak self] in
        return VNDetectTextRectanglesRequest(completionHandler: { [weak self] (request, error) in
            guard let observations = request.results else {print("no result"); return}
            let result = observations.map({$0 as? VNTextObservation})
            DispatchQueue.main.async {
                for region in result {
                    guard let rg = region else {continue}
                    self?.makeRegionBox(box: rg)
                }
            }
        })
    }()
    
    init(preview: UIView, captionView: UIView) {
        self.previewView = preview
        self.captionView = captionView
        super.init()
    }
    
   

    // MARK: - Draw
    private func makeRegionBox(box: VNTextObservation) {
        guard let boxes = box.characterBoxes else {return}
        var xMin: CGFloat = 9999.0
        var xMax: CGFloat = 0.0
        var yMin: CGFloat = 9999.0
        var yMax: CGFloat = 0.0
        
        for char in boxes {
            if char.bottomLeft.x < xMin {xMin = char.bottomLeft.x}
            if char.bottomRight.x > xMax {xMax = char.bottomRight.x}
            if char.bottomRight.y < yMin {yMin = char.bottomRight.y}
            if char.topRight.y > yMax {yMax = char.topRight.y}
        }
        
        let xCoord = xMin * previewView.frame.size.width
        let yCoord = (1 - yMax) * previewView.frame.size.height
        let width = (xMax - xMin) * previewView.frame.size.width
        let height = (yMax - yMin) * previewView.frame.size.height
        
        let regionBoxFrame = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        
        tryToRecognizeTextIn(boxFrame: regionBoxFrame)
    }
    private func tryToRecognizeTextIn(boxFrame: CGRect) {
      
        if textRecognizer.isRunning == false {
           
            let snapshot = getImageFromSampleBuffer(sampleBuffer: buffer)
            let resizedToCurrentScreen = UIImage.resizeImage(image: snapshot, to: UIScreen.main.bounds.size)
            if let resized = resizedToCurrentScreen {
                textRecognizer.inputImage = CIImage.init(image: resized)
            }
        }
    }
    private func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
       
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation:.up)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
}

extension TextDetectionHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
        
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        buffer = sampleBuffer
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation.up, options: requestOptions)
        self.textRequest.reportCharacterBoxes = true
        self.requests = [self.textRequest]
        
        do {
                try imageRequestHandler.perform(self.requests)
           }
         catch {
            print(error)
        }
    }
}


