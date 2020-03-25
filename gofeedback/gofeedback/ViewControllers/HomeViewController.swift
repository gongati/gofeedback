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
    
    @IBOutlet weak var nearLocation1: UIButton!
    @IBOutlet weak var nearLocation2: UIButton!
    @IBOutlet weak var nearLocation3: UIButton!
    
    var locationManager = CLLocationManager()
    var locationLat:String?
    var locationLong:String?
    var userCurrentLocation:CLLocationCoordinate2D?
    var searchResponse: [MKMapItem]?
    var searchItem = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        whereToGoText.delegate = self
        mapView.delegate = self
        
        nearLocation1.isHidden = true
        nearLocation2.isHidden = true
        nearLocation3.isHidden = true
        
        whereToGoText.text = searchItem
        self.mapQuery()
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
    
    @objc override func keyboardWillShow(notification: NSNotification) {
            
            self.view.frame.origin.y -= 0
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
            self.userCurrentLocation = locationManager.location?.coordinate
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
    
    @IBAction func nearLocation1Pressed(_ sender: UIButton) {
        
        self.wayToFeedbackViewController(sender.titleLabel?.text)
    }
    
    @IBAction func nearLocation2Pressed(_ sender: UIButton) {
        
        self.wayToFeedbackViewController(sender.titleLabel?.text)
    }
    
    @IBAction func nearLocation3Pressed(_ sender: UIButton) {
        
        self.wayToFeedbackViewController(sender.titleLabel?.text)
    }
    
    
    //MARK:- UITextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //Check for reachability
        if Reachability.isConnectedToNetwork() != true {
            popupAlert(title: "Alert", message: "Seems like there is no internet connection, please check back later", actionTitles: ["OK"], actions: [nil])
            return false
        }
        
        //push controller
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.mapQuery()
        textField.resignFirstResponder()
        return true
    }
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
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
    
    func mapQuery() {
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = whereToGoText.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            
            if error != nil {
                print(
                    error!.localizedDescription)
            } else if response!.mapItems.count == 0 {
                
                self.popupAlert(title: "Alert", message: "No matches Found", actionTitles: ["OK"], actions: [nil])
            } else {
                
                print(response?.mapItems)
                self.searchResponse = response?.mapItems
                for item in response!.mapItems {
                    
                    print(item.name)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.mapView.addAnnotation(annotation)
                }
                DispatchQueue.main.async {
                    
                    self.nearestLocationButtons()
                }
            }
        })
    }
    
    func nearestLocationButtons() {
        
        nearLocation1.isHidden = false
        nearLocation2.isHidden = false
        nearLocation3.isHidden = false
        
        var distances = [CLLocationDistance]()
        if let currentLocation = self.userCurrentLocation {
            let currentLoc = CLLocation(latitude: (userCurrentLocation?.latitude)!, longitude: (userCurrentLocation?.longitude)!)
            
            for annotation in 0..<(self.searchResponse?.count ?? 1) {
                if let searchResponse = self.searchResponse {
                    let value = searchResponse[annotation].placemark.coordinate
                    let selectedLoc = CLLocation(latitude: value.latitude, longitude: value.longitude)
                    distances.append(currentLoc.distance(from: selectedLoc))
                }
            }
            
            let sortedDistances = distances.sorted(by:<)
            print(distances)
            print(sortedDistances)
            var values = [Int]()
            
            for i in 0..<sortedDistances.count {
                
                for j in 0..<distances.count {
                    
                    if distances[j] == (sortedDistances[i]) {
                        
                        values.append(j)
                    }
                }
            }
            print(values)
            
            if values.count >= 3 {
                self.nearLocation1.setTitle(self.searchResponse?[values[0]].name ?? "1", for: .normal)
                self.nearLocation1.titleLabel?.numberOfLines = 2
                self.nearLocation1.titleLabel?.adjustsFontSizeToFitWidth = true
                self.nearLocation2.setTitle(self.searchResponse?[values[1]].name ?? "2", for: .normal)
                self.nearLocation2.titleLabel?.numberOfLines = 2
                self.nearLocation2.titleLabel?.adjustsFontSizeToFitWidth = true
                self.nearLocation3.setTitle(self.searchResponse?[values[2]].name ?? "3", for: .normal)
                self.nearLocation3.titleLabel?.numberOfLines = 2
                self.nearLocation3.titleLabel?.adjustsFontSizeToFitWidth = true
            } else if values.count == 2 {
                
                self.nearLocation1.setTitle(self.searchResponse?[values[0]].name ?? "1", for: .normal)
                self.nearLocation1.titleLabel?.numberOfLines = 2
                self.nearLocation1.titleLabel?.adjustsFontSizeToFitWidth = true
                self.nearLocation2.setTitle(self.searchResponse?[values[1]].name ?? "2", for: .normal)
                self.nearLocation2.titleLabel?.numberOfLines = 2
                self.nearLocation2.titleLabel?.adjustsFontSizeToFitWidth = true
                self.nearLocation3.isHidden = true
            } else {
                
                self.nearLocation2.setTitle(self.searchResponse?[values[0]].name ?? "2", for: .normal)
                self.nearLocation2.titleLabel?.numberOfLines = 2
                self.nearLocation2.titleLabel?.adjustsFontSizeToFitWidth = true
                self.nearLocation1.isHidden = true
                self.nearLocation3.isHidden = true
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
        }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        if let title = view.annotation?.title {
            
            self.wayToFeedbackViewController(title)
        }
    }
    
    func wayToFeedbackViewController(_ title:String?) {
        
        for i in 0..<(searchResponse?.count ?? 1) {
            
            if searchResponse?[i].name ?? "" == title {
                
                guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "FeedbackViewController") as? FeedbackViewController else {
                    return
                }
                
                viewController.restaurantTitle =  searchResponse?[i].name ?? ""
                viewController.address = searchResponse?[i].placemark.title ?? ""
                viewController.searchItem = whereToGoText.text ?? ""
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
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
