//
//  HomeViewController.swift
//  Genfare
//
//  Created by omniwzse on 14/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class HomeViewController: GFBaseViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var whereToGoText: UITextField!
    @IBOutlet weak var topNavBar: UIView!
    @IBOutlet weak var navBarLogo: UIImageView!
    
    @IBOutlet weak var zoomOutBtn: UIButton!
    @IBOutlet weak var zoomInBtn: UIButton!
    
    var locationManager = CLLocationManager()
    var locationLat:String?
    var locationLong:String?
    var userCurrentLocation:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        whereToGoText.delegate = self
        mapView.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor.topNavBarColor
        
        self.navBarLogo.backgroundColor = UIColor.clear
        topNavBar.backgroundColor = UIColor.topNavBarColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //TripDataManager.resetTrip()
        //Show user currentlocation
        determineCurrentLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineCurrentLocation()
    {
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        } else {
            print("Please turn on location services or GPS")
        }
    }
    
    func requestCurrentLocation()
    {
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() == true {
            
            locationManager.requestLocation()
            
        } else {
            print("Please turn on location services or GPS")
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func gotoCurrentLocation(_ sender: UIButton) {
        requestCurrentLocation()
    }
    
    @IBAction func zoomInMap(_ sender: UIButton) {

        self.mapView.setZoomByDelta(delta: 0.5, animated: true)
    }
    
    @IBAction func zoomOutMap(_ sender: UIButton) {

        self.mapView.setZoomByDelta(delta: 2, animated: true)
    }
    
    @IBAction func openHeader(_ sender: UIButton) {
     
        let viewController = SampleCategoryViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK:- UITextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //Check for reachability
//        if Reachability.isConnectedToNetwork() != true {
//            popupAlert(title: "Alert", message: "Seems like there is no internet connection, please check back later", actionTitles: ["OK"], actions: [nil])
//            return false
//        }

        //push controller
        return false
    }
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(region, animated: true)
        }
    }

    //MARK:- CLLocationManager Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationLat = "\(locations[0].coordinate.latitude)"
        locationLong = "\(locations[0].coordinate.longitude)"
        self.centerViewOnUserLocation()
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        guard userCurrentLocation?.latitude != nil else {
            print("User location is nil")
            return
        }
                
        let currentLoc = CLLocation(latitude: (userCurrentLocation?.latitude)!, longitude: (userCurrentLocation?.longitude)!)
        let selectedLoc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
                
        print(currentLoc.distance(from: selectedLoc))
        
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = Int(log2(zoomWidth)) - 9
        let pinDistance = (20 * zoomFactor)


        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    func animationScaleEffect(view:UIView,animationTime:Float)
    {
        UIView.animate(withDuration: TimeInterval(animationTime), animations: {
            
            view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            
        },completion:{completion in
            UIView.animate(withDuration: TimeInterval(animationTime), animations: { () -> Void in
                
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
        
    }
    
}

extension MKMapView {

    // delta is the zoom factor
    // 2 will zoom out x2
    // .5 will zoom in by x2

    func setZoomByDelta(delta: Double, animated: Bool) {
        var _region = region;
        var _span = region.span;
        _span.latitudeDelta *= delta;
        _span.longitudeDelta *= delta;
        _region.span = _span;

        setRegion(_region, animated: animated)
    }
}
