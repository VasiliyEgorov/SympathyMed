//
//  ClinicMapsViewController.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 11.05.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class ClinicMapsViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let clinicsProvider = ClinicsProvider()
    var userLocation : CLLocation?
    var markers = [ClinicsMarker]()
    var markerView : ClinicsMarkerView?
    var dimView: IndicatorDimView?
    let task = "clinicsTask"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchClinics() {
        self.dimView = self.setupSpinner()
        clinicsProvider.getClinics(taskId: task, complition: { (clinics) in
            clinics.forEach({
                let marker = ClinicsMarker.init(clinic: $0)
                marker.map = self.mapView
                self.markers.append(marker)
            })
           
            self.removeSpinner(dimView: self.dimView)
            self.setCameraToNearbyMarker(markers: self.markers)
        }) { (error) in
            if let err = error {
               let responseError = ResponseError.init(rawValue: err._code)
                switch responseError {
                    case .noConnection?: self.showAlert(message: "There is no internet connection")
                    default: return
                }
            }
          
        }
    }
    
    func showAlert(message: String) {
        alertMessage("Error", message: message, titleAction: "OK", cancelAction: false)
    }
    
    func configureMap(coord: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: coord.latitude, longitude: coord.longitude, zoom: 0)
        mapView.camera = camera
        mapView.animate(toLocation: coord)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func setCameraToNearbyMarker(markers: [ClinicsMarker]) {

        let sortedMarkers = markers.sorted(by: { markerOne, markerTwo in
            let markerOneLocation = CLLocation(latitude: markerOne.position.latitude, longitude: markerOne.position.longitude)
            let markerTwoLocation = CLLocation(latitude: markerTwo.position.latitude, longitude: markerTwo.position.longitude)
            let metersOne = userLocation!.distance(from: markerOneLocation)
            let metersTwo = userLocation!.distance(from: markerTwoLocation)
                return metersOne < metersTwo
        })
       let location = CLLocationCoordinate2DMake(sortedMarkers.first!.clinic.latitude, sortedMarkers.first!.clinic.longitude)
       configureMap(coord: location)
    }
    
    // MARK: - Buttons
    
    @IBAction func refreshButtonAction(_ sender: UIBarButtonItem) {
        fetchClinics()
    }
    
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension ClinicMapsViewController: CloseButtonDelegate {
    func closeButton(sender: UIButton) {
        self.markerView?.removeFromSuperview()
        UIView.animate(withDuration: 0.3) {
            self.mapView.padding = UIEdgeInsets.init(top: self.view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
        }
    }
}
extension ClinicMapsViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.markerView?.removeFromSuperview()
        guard let clinicMarker = marker as? ClinicsMarker else { return false }
        guard let markerView = UINib.init(nibName: "ClinicsMarkerView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ClinicsMarkerView else { return false }
        self.markerView = markerView
        self.markerView?.delegate = self
        self.view.addSubview(markerView)
        let guide = self.view.safeAreaLayoutGuide
        let width = guide.layoutFrame.size.width
        let height = guide.layoutFrame.size.height / 5
        let originX : CGFloat = 0
        let originY : CGFloat
        
        let device = Device.init(rawValue: UIScreen.main.bounds.height)
        
        switch device {
            case .IphoneX_Xs?,.IphoneXsMax_Xr?: originY = guide.layoutFrame.size.height
            default: originY = self.view.frame.size.height - height
        }
        
        
        markerView.frame = CGRect(x: originX, y: originY, width: width, height: height)
        
        markerView.nameLabel.text = clinicMarker.clinic.name
        markerView.snippetLabel.text = clinicMarker.clinic.snippet
        markerView.telephoneLabel.text = clinicMarker.clinic.telephone
        markerView.websiteLabel.text = clinicMarker.clinic.website
        UIView.animate(withDuration: 0.3) {
            self.mapView.padding = UIEdgeInsets.init(top: self.view.safeAreaInsets.top, left: 0, bottom: markerView.frame.size.height, right: 0)
        }
        
        return true
    }
}

extension ClinicMapsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            fetchClinics()
        case .denied:
            let message = NSLocalizedString("SympathyMedApp doesn't have permission to get location, please change privacy settings",
                                            comment: "Alert message when the user has denied access to his location")
            let alertController = UIAlertController.init(title: "SympathyMedApp", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("Ok", comment: "Alert Ok button"), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let settingsAction = UIAlertAction.init(title: NSLocalizedString("Settings", comment: "Button to open system settings"), style: .default, handler: { (action) in
                UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            })
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //stop updation location to save battery life
        guard let currentLocation = locations.last else { return }
        userLocation = currentLocation
        locationManager.stopUpdatingLocation()
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
