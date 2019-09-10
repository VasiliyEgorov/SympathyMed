//
//  Extensions.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 28.04.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit

enum Device : CGFloat {
    case Iphone6_7_plus = 736
    case Iphone6_7 = 667
    case Iphone5 = 568
    case IphoneX_Xs = 812
    case IphoneXsMax_Xr = 896
    case IpadMini_Air = 1024
    case IpadPro10_5 = 1112
    case Ipad11 = 1194
    case IpadPro12_9 = 1366
}

enum AppStoryboard: String {
    
    case MainIPhone
    case MainIPad
    
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

extension UIViewController {
    
    class var storyboardID : String {
        return "\(self)"
    }
    static func instantiateFromAppStoryboard(appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
}

extension UIViewController {
    
    func setupSpinner() -> IndicatorDimView? {
        
        guard let dimView = UINib.init(nibName: "IndicatorDimView", bundle: nil).instantiate(withOwner: self, options: nil).first as? IndicatorDimView else { return nil }
        self.view.addSubview(dimView)
        let guide = self.view.safeAreaLayoutGuide
        
        dimView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        dimView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.layoutIfNeeded()
        dimView.spinner.startAnimating()
        
        return dimView
    }
    func setupSpinnerForCamera() -> IndicatorDimView? {
        
        guard let dimView = UINib.init(nibName: "IndicatorDimView", bundle: nil).instantiate(withOwner: self, options: nil).first as? IndicatorDimView else { return nil }
        self.view.addSubview(dimView)
        
        dimView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        dimView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        for constraint in dimView.constraints {
            if constraint.identifier == "height" {
                constraint.isActive = false
                dimView.spinner.widthAnchor.constraint(equalTo: dimView.widthAnchor, multiplier: 0.085).isActive = true
            }
        }
        
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.layoutIfNeeded()
        dimView.spinner.startAnimating()
        
        return dimView
    }
    func removeSpinner(dimView: IndicatorDimView?) {
        dimView?.spinner.stopAnimating()
        dimView?.removeFromSuperview()
    }
}

extension UIViewController {
    func alertMessage(_ title: String?,
                      message: String?,
                      titleAction: String?,
                      cancelAction:Bool,
                      handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            let action = UIAlertAction(
                title: titleAction,
                style: .default,
                handler: handler
            )
            alert.addAction(action)
            
            if cancelAction {
                let cancel = UIAlertAction (
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )
                alert.addAction(cancel)
            }
            self.present(
                alert,
                animated: true,
                completion: nil
            )
        }
    }
}

extension Notification.Name {
    static let RegistrationDidStartNotification = Notification.Name("RegistrationDidStartNotification")
    static let RegistrationDidCompleteNotification = Notification.Name("RegistrationDidCompleteNotification")
    static let CodeAlreadyRegisteredNotification = Notification.Name("CodeAlreadyRegisteredNotification")
    static let NoConnectionNotification = Notification.Name("NoConnectionNotification")
    static let IncorrectNotification = Notification.Name("IncorrectNotification")
    static let ObjectRecognizedRemoveScopeNotification = Notification.Name("ObjectRecognizedRemoveScopeNotification")
    static let ObjectNotRecognizedAddScopeNotification = Notification.Name("ObjectNotRecognizedAddScopeNotification")
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)![0] as! T
    }
}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

extension UIImage {
    
    class func resizeMarker(image: UIImage?, scaledToSize newSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func takeSnapshotFrom(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 300, height: 300), false, 0);
        view.drawHierarchy(in: CGRect(x: 0, y: 0, width: 300, height: 300), afterScreenUpdates: true)
        let snapshotImage : UIImage? = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshotImage
    }
}
extension UIImage {
    
class func resizeImage(image: UIImage?, to newSize: CGSize) -> UIImage? {
    guard let image = image else { return nil }
    UIGraphicsBeginImageContext(newSize)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}
}
extension UIImage {
    func detectOrientationDegree () -> CGFloat {
        switch imageOrientation {
        case .right, .rightMirrored:    return 90
        case .left, .leftMirrored:      return -90
        case .up, .upMirrored:          return 180
        case .down, .downMirrored:      return 0
        @unknown default: fatalError("cannot detect image orientation")
        }
    }
}
extension UIImage {
    class func crop(image: UIImage?, to frame: CGRect) -> UIImage? {
        guard let image = image else { return nil }
        let rad = {(_ deg: CGFloat) -> CGFloat in
            return deg / 180.0 * CGFloat.pi
        }
        
        var rectTransform : CGAffineTransform
        
        switch image.imageOrientation {
        case .left: rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -image.size.height)
        case .right: rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -image.size.width, y: 0)
        case .down: rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -image.size.width, y: -image.size.height)
        default: rectTransform = CGAffineTransform.identity
        }
        
        rectTransform = rectTransform.scaledBy(x: image.scale, y: image.scale)
        
        let cropFromY : CGFloat
        let cropFromX : CGFloat
        let rectToCrop : CGRect
        
        if image.size.width < image.size.height {
            cropFromY = frame.origin.y
            cropFromX = 0
            rectToCrop = CGRect(x: cropFromX, y: cropFromY, width: frame.size.width, height: frame.size.height)
        } else {
            cropFromX = frame.origin.x
            cropFromY = 0
            rectToCrop = CGRect(x: cropFromX, y: cropFromY, width: frame.size.width, height: frame.size.height)
        }
        
        let transformedCropSquare = rectToCrop.applying(rectTransform)
        
        let imageRef = image.cgImage!.cropping(to: transformedCropSquare)
        let croppedImage = UIImage.init(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        
        return croppedImage
    }
}
