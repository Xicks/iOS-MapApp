//
//  ViewController.swift
//  Map App
//
//  Created by Leonardo Schick on 1/25/16.
//  Copyright © 2016 Xicks. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var pointDescription: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var locationPressed: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let latitude: CLLocationDegrees = 48.8588377
        let longitude: CLLocationDegrees = 2.277517
        let latDelta: CLLocationDegrees = 1
        let longDelta: CLLocationDegrees = 1
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        myMap.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
        annotation.title = "Paris"
        annotation.subtitle = "Beautiful Place"
        myMap.addAnnotation(annotation)
        
        let uilpg = UILongPressGestureRecognizer(target: self, action: "prepareAddPoint:")
        uilpg.minimumPressDuration = 1
        myMap.addGestureRecognizer(uilpg)
    }
    
    @IBAction func addPoint(sender: AnyObject) {
        if !pointDescription.text!.isEmpty {
            let annotation = MKPointAnnotation()
            annotation.title = pointDescription.text
            annotation.subtitle = "Created by the user!"
            annotation.coordinate = myMap.convertPoint(locationPressed!, toCoordinateFromView: self.myMap)
            myMap.addAnnotation(annotation)
        }
        UIView.animateWithDuration(1) { () -> Void in
            self.pointDescription.alpha = 0
            self.addButton.alpha = 0
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        let userLocation : CLLocation = locations.last!
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let location: CLLocationCoordinate2D = userLocation.coordinate
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        myMap.setRegion(region, animated: true)
        
        coordinateLabel.text = "Latitude: \(location.latitude)   Longitude: \(location.longitude)\nAltitude: \(userLocation.altitude)m"
        speedLabel.text = "Speed: \(userLocation.speed)mps   Course: \(userLocation.course)"
        
        CLGeocoder().reverseGeocodeLocation(userLocation) { (placemarks, error) -> Void in
            if error == nil {
                if let placemark: CLPlacemark = CLPlacemark(placemark: placemarks![0]){
                    var subThoroughfare = ""
                    if placemark.subThoroughfare != nil {
                        subThoroughfare = placemark.subThoroughfare!
                    }
                    // Unwraps only the non nil variables
                    let addressArray = [subThoroughfare , placemark.thoroughfare, placemark.subLocality ,
                        placemark.subAdministrativeArea, placemark.postalCode, placemark.country]
                    var addressText = ""
                    for s in addressArray {
                        if let s = s {
                            addressText += "\n\(s)";
                        }
                    }
                    self.addressLabel.text = addressText;
                }
            }

        }
    }
    
    func prepareAddPoint(gestureRecognizer: UIGestureRecognizer ){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            self.locationPressed = gestureRecognizer.locationInView(self.myMap)
            UIView.animateWithDuration(1) { () -> Void in
                self.pointDescription.alpha = 1
                self.addButton.alpha = 1
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.pointDescription.alpha = 0
        self.addButton.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

