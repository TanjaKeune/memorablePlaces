//
//  ViewController.swift
//  Memorable Places2
//
//  Created by Tanja Keune on 8/22/17.
//  Copyright © 2017 SUGAPP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
        //prent the places that was choosed
        
        if activePlace == -1  {
        
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        
        } else {
            
            if let title = places[activePlace]["name"] {
                
                if let lat = places[activePlace]["lat"] {
                    
                    if let lon = places[activePlace]["lon"] {
                        
                        if let latitude = Double(lat) {
                            
                            if let longitude = Double(lon) {
                                
                                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                let region = MKCoordinateRegion(center: coordinate, span: span)
                                
                                self.mapView.setRegion(region, animated: true)
//                                add annotation
                                
                                let annotation = MKPointAnnotation()
                                
                                annotation.title = title
                                annotation.coordinate = coordinate
                                mapView.addAnnotation(annotation)
                            }
                        }
                        
                    }
                }
            }
            
        }
        
//        add gesture recognizer
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(gestureRecognizer:)))
        
        uilgr.minimumPressDuration = 2
        
        mapView.addGestureRecognizer(uilgr)
        
    }

//  TODO: I get misstake on the simulatior connect to phone and run it there to continue
    
    func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            
            let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            var title = ""
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                
                if error != nil {
                    
                    print(error ?? "Something whent wrong")
                } else {
                    
                    if let placemark = placemarks?[0] {
                        
                        if placemark.subThoroughfare != nil {
                            
                            title += placemark.subThoroughfare! + " "
                        }
                        
                        if placemark.thoroughfare != nil {
                            
                            title += placemark.thoroughfare!
                        }
                    }
                }
                
                if title == "" {
                    
                    title = "Added \(NSDate())"
                }
                
                let annotation = MKPointAnnotation()
                
                annotation.title = title
                annotation.coordinate = newCoordinate
                
                self.mapView.addAnnotation(annotation)
                
                places.append(["name":title, "lat":String(newCoordinate.latitude), "lon":String(newCoordinate.longitude)])
                
                UserDefaults.standard.set(places, forKey: "places")
                
            })
            
            print(newCoordinate)
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = newCoordinate
            annotation.title = "Temp title"
            
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

