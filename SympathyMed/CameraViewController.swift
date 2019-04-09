//
//  CameraViewController.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 10.04.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

enum AVCamSetupResult : Int {
    case AVCamSetupResultSuccess, AVCamSetupResultCameraNotAuthorized, AVCamSetupResultSessionConfigurationFailed
}

class CameraViewController: UIViewController {
    
    
    var session : AVCaptureSession = AVCaptureSession.init()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var setupResult : AVCamSetupResult = .AVCamSetupResultCameraNotAuthorized
    var isSessionRunning = false
    let videoQueue = DispatchQueue(label: "com.sympathyMed.app.videoQueue")
    let visionDataOutput = AVCaptureVideoDataOutput()
    let stateChecker = StateChecker()
    var captureDevice : AVCaptureDevice?

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        previewLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        previewLayer?.connection?.videoOrientation = .landscapeRight
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stateChecker.saveState(isAnimationAllowed: false)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tryToRunSession()
    }
     func tryToRunSession() {
        switch setupResult {
        case .AVCamSetupResultSuccess:
            session.startRunning()
            isSessionRunning = session.isRunning
        case .AVCamSetupResultCameraNotAuthorized:
            let message = NSLocalizedString("SympathyMedApp doesn't have permission to use the camera, please change privacy settings",
                                            comment: "Alert message when the user has denied access to the camera")
            let alertController = UIAlertController.init(title: "SympathyMedApp", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("Ok", comment: "Alert Ok button"), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let settingsAction = UIAlertAction.init(title: NSLocalizedString("Settings", comment: "Button to open system settings"), style: .default, handler: { (action) in
                UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            })
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        case .AVCamSetupResultSessionConfigurationFailed:
            let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
            let alertController = UIAlertController.init(title: "SympathyMedApp", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("Ok", comment: "Alert Ok button"), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func configurePreviewLayerWith(videoView: UIView) {
 
        let prevLayer = AVCaptureVideoPreviewLayer.init(session: session)
        prevLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        prevLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        videoView.layer.addSublayer(prevLayer)
        self.previewLayer = prevLayer
        setupResult = AVCamSetupResult.AVCamSetupResultSuccess
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case AVAuthorizationStatus.authorized: break
        // user previously granted accsess to the camera
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                if !granted {
                    self.setupResult = AVCamSetupResult.AVCamSetupResultCameraNotAuthorized
                }
            })
            break
        default: setupResult = AVCamSetupResult.AVCamSetupResultCameraNotAuthorized
        }
       
    }
    
    func setupSessionWith(textDetection: TextDetectionHandler?) {
        if setupResult != AVCamSetupResult.AVCamSetupResultSuccess {
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            setupResult = AVCamSetupResult.AVCamSetupResultSessionConfigurationFailed
            session.commitConfiguration()
            return
        }
        
        self.captureDevice = captureDevice
        
        guard let input = try? AVCaptureDeviceInput.init(device: captureDevice) else {
            setupResult = AVCamSetupResult.AVCamSetupResultSessionConfigurationFailed
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
            
        } else {
            setupResult = AVCamSetupResult.AVCamSetupResultSessionConfigurationFailed
            session.commitConfiguration()
            return
        }
        
        visionDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        visionDataOutput.setSampleBufferDelegate(textDetection, queue: videoQueue)
        
    
        if session.canAddOutput(visionDataOutput) {
            session.addOutput(visionDataOutput)
        } else {
            setupResult = AVCamSetupResult.AVCamSetupResultSessionConfigurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.isSessionRunning {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
 
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
