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
import CDYelpFusionKit

class HomeViewController: GFBaseViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var whereToGoText: UITextField!
    @IBOutlet weak var topNavBar: UIView!
    @IBOutlet weak var navBarLogo: UIImageView!
    
    @IBOutlet weak var zoomOutBtn: UIButton!
    @IBOutlet weak var zoomInBtn: UIButton!
    @IBOutlet weak var currentLocationBtn: UIButton!

    @IBOutlet weak var nearLocation1: UIButton!
    @IBOutlet weak var nearLocation2: UIButton!
    @IBOutlet weak var nearLocation3: UIButton!
    @IBOutlet weak var listOutlet: UIButton!
    
    var locationManager = CLLocationManager()
    var locationLat:String?
    var locationLong:String?
    var userCurrentLocation:CLLocationCoordinate2D?
    var searchResponse: [CDYelpBusiness]?
    var searchItem = ""
    var radiusOffset = 100
    var bottomController: AnnotationsListViewController?
    var matchesCount = 0
    
    let yelpAPIClient = CDYelpAPIClient(apiKey: "JuFWYKLiETl9O-z6Tn7ysBeGyXbzON1Eh-_lbP56VDbu5YdZMRLQTBE2rNWfLCCM85Ot21lMMhiW9GsuaEVAg8kBQLPPVoAaTFP99Fm3m9_2WHMBibfkoItNQhuLXnYx")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        whereToGoText.delegate = self
        mapView.delegate = self
        
        nearLocation1.isHidden = true
        nearLocation2.isHidden = true
        nearLocation3.isHidden = true
        listOutlet.isHidden = true
        
        self.zoomInBtn.makeCircular()
        self.zoomOutBtn.makeCircular()
        self.currentLocationBtn.makeCircular()
        self.currentLocationBtn.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.bottomController != nil {
            
            self.addChild(self.bottomController!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //TripDataManager.resetTrip()
        //Show user currentlocation
        determineCurrentLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        

        super.viewWillDisappear(animated)
        if self.children.count != 0 {
            
            self.children[0].removeFromParent()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func attachBottomController() {
        
        if let annotations = self.bottomController {
            
            annotations.dataSource = self.searchResponse
            annotations.tableView.reloadData()
        } else {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "AnnotationsListViewController") as? AnnotationsListViewController {
                
                viewController.dataSource = self.searchResponse
                viewController.searchItem = whereToGoText.text ?? ""
                self.bottomController = viewController
                viewController.attach(to: self)
            }
        }
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
        GFGlobal.localDebug = false

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
        self.radiusOffset /= 2
        print(radiusOffset)
        self.yelpQuery()
    }
    
    @IBAction func zoomOutMap(_ sender: UIButton) {
        
        self.mapView.setZoomByDelta(delta: 2, animated: true)
        self.radiusOffset *= 2
        print(radiusOffset)
        self.yelpQuery()
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
    
    @IBAction func listPressed(_ sender: UIButton) {
        
        self.wayToAnnotationList()
    }
    
    @IBAction func setupLocalLocation(_ sender: UIButton) {
        
        self.setupDebugLocation(lat: "37.785834", long: "-122.406417")
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
        
        self.yelpQuery()
        textField.resignFirstResponder()
        return true
    }
    
    func centerViewOnUserLocation() {
        
        if GFGlobal.localDebug {
            
            let location = CLLocationCoordinate2D(
                latitude: Double(self.locationLat ?? "0")!,
                longitude: Double(self.locationLong ?? "0")!)
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(region, animated: true)
        }
        
        if let location = locationManager.location?.coordinate {
            
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(region, animated: true)

        }
    }
    
    func setupDebugLocation(lat:String, long:String) {
        
        GFGlobal.localDebug = true
        self.locationLat = lat
        self.locationLong = long
        
        self.centerViewOnUserLocation()
        self.yelpQuery()
    }
    
    //MARK:- CLLocationManager Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationLat = "\(locations[0].coordinate.latitude)"
        locationLong = "\(locations[0].coordinate.longitude)"
        self.centerViewOnUserLocation()
        manager.stopUpdatingLocation()
        self.radiusOffset = 100
        self.yelpQuery()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        guard userCurrentLocation?.latitude != nil else {
            print("User location is nil")
            return
        }
        
        yelpAPIClient.cancelAllPendingAPIRequests()
        
        let currentLoc = CLLocation(latitude: (userCurrentLocation?.latitude)!, longitude: (userCurrentLocation?.longitude)!)
        let selectedLoc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        print(currentLoc.distance(from: selectedLoc))
        
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = Int(log2(zoomWidth)) - 9
        let pinDistance = (20 * zoomFactor)
        
        let lat = Double(round(selectedLoc.coordinate.latitude * 1000000)/1000000)
        let long = Double(round(selectedLoc.coordinate.longitude * 1000000)/1000000)
        if currentLoc.coordinate.latitude != lat && currentLoc.coordinate.longitude != long {
            locationLat = "\(mapView.centerCoordinate.latitude)"
            locationLong = "\(mapView.centerCoordinate.longitude)"
            self.yelpQuery()
        }
        //self.radius = 200
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
    
    func yelpQuery() {
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        var radius = 100
        
        yelpAPIClient.cancelAllPendingAPIRequests()
        
        if self.radiusOffset > 40000 {
            
            radius = 40000
        } else if self.radiusOffset < 0 {
            
            radius = 0
        } else if self.radiusOffset >= 0 && self.radiusOffset <= 40000 {
            
            radius = self.radiusOffset
        }
        
        print("Radius : \(radius)")
        yelpAPIClient.searchBusinesses(byTerm: whereToGoText.text,
                                       location: nil,
                                       latitude: Double(self.locationLat ?? ""),
                                       longitude: Double(self.locationLong ?? ""),
                                       radius: radius,
                                       categories: nil,
                                       locale: .english_unitedStates,
                                       limit: 50,
                                       offset: nil,
                                       sortBy: .bestMatch,
                                       priceTiers: nil,
                                       openNow: nil,
                                       openAt: nil,
                                       attributes: nil) { (response) in
                                        
                                        if let response = response,
                                            let businesses = response.businesses {
                                            
                                            if businesses.count == 0 {
                                                
                                                self.searchResponse = nil
                                                if self.matchesCount < 2 {
                                                self.popupAlert(title: "Alert", message: "No matches Found", actionTitles: ["OK"], actions: [nil])
                                                    self.matchesCount = self.matchesCount + 1
                                                }
                                            } else {
                                                print(response)
                                                
                                                self.searchResponse = response.businesses
                                                self.attachBottomController()
                                                for business in businesses {
                                                    
                                                    let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: business.coordinates?.latitude ?? 0, longitude: business.coordinates?.longitude ?? 0))
                                                    point.business = business
                                                    point.title = business.name
                                                     self.mapView.addAnnotation(point)
                                                }
                                                
                                                if "\(self.userCurrentLocation?.latitude ?? 0)" != self.locationLat && "\(self.userCurrentLocation?.longitude ?? 0)" != self.locationLong {
                                                let annotation = MKPointAnnotation()
                                                    annotation.coordinate = CLLocationCoordinate2D(latitude: Double(self.locationLat ?? "")!, longitude: Double(self.locationLong ?? "")!)
                                                         annotation.title = "Refernce Location"
                                                self.mapView.addAnnotation(annotation)
                                                }
                                            }
                                        }
                                        else {
                                            
                                            print("error")
                                        }
        }
        
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
        }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        if let customAnnotation = view.annotation as? CustomAnnotation {
            
            view.canShowCallout = true
            view.titleVisibility = .adaptive
            view.calloutOffset = CGPoint(x: -5, y: 5)
            
            let calloutView = CustomAnnotationView()
            calloutView.configureView(customAnnotation.business)
            
            calloutView.snp.makeConstraints { (make) in
                
                make.height.equalTo(80)
            }
            
            calloutView.actionButton.addTarget(self, action: #selector(self.annotationPressed(sender:)), for: .touchUpInside)
            calloutView.isUserInteractionEnabled = true
            view.detailCalloutAccessoryView = calloutView
        } else if let _ = view.annotation as? MKPointAnnotation {
            
            view.canShowCallout = false
            view.markerTintColor = UIColor.green
        }
        
        return view
    }
    
    @objc func annotationPressed(sender: UIButton) {
            
        self.wayToFeedbackViewController(sender.titleLabel?.text)
    }
    
    func wayToFeedbackViewController(_ title:String?) {
        
        //TODO - this for loop can be removed
        for i in 0..<(searchResponse?.count ?? 1) {
            
            if searchResponse?[i].name ?? "" == title {
                
                guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "FeedbackViewController") as? FeedbackViewController else {
                    return
                }
                
                viewController.feedbackModel.restaurantTitle =  searchResponse?[i].name ?? ""
                viewController.bussiness = searchResponse?[i]
                
                if let location = searchResponse?[i].location {
                    
                    viewController.feedbackModel.address = "\(location.addressOne ?? "") \(location.addressTwo ?? "") \(location.addressThree ?? "") \(location.city ?? "") \(location.state ?? "") \(location.country ?? "") \(location.zipCode ?? "")"
                }
                viewController.searchItem = whereToGoText.text ?? ""
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func wayToAnnotationList() {
        
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "AnnotationsListViewController") as? AnnotationsListViewController else {
            return
        }
          
        viewController.dataSource = self.searchResponse
        viewController.searchItem = whereToGoText.text ?? ""
        self.navigationController?.pushViewController(viewController, animated: true)
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

extension UIView {
    
    func makeCircular() {
        
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.masksToBounds = false
    }
}

extension UIViewController {
   
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
   }
}
