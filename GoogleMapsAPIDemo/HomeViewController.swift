//
//  HomeViewController.swift
//  GoogleMapsAPIDemo
//
//  Created by Christopher Schlitt on 3/28/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces

class HomeViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    /* Instance Variables */
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var googlePlacesClient: GMSPlacesClient?
    var showingServiceDetail = true
    var showingLocationsBar = false
    var showingCurrentLocation = true
    
    /* UI outlets */
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchButtonsContainer: UIView!
    @IBOutlet weak var searchButtonsCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var locationsBar: UINavigationBar!
    @IBOutlet weak var currentLocationButton: UIBarButtonItem!
    @IBOutlet weak var philadelphiaButton: UIBarButtonItem!
    
    /* Other UI Components */
    var mapView: GMSMapView!
    var navBarBorder: UIView!
    var searchButtonsContainerBorder: UIView!
    var requestButton: UIView!
    
    /* UI Constraints */
    var hideSearchButtonsConstraint: NSLayoutConstraint!
    var showSearchButtonsConstraint: NSLayoutConstraint!
    @IBOutlet weak var tmpSearchButtonsConstraint: NSLayoutConstraint!
    
    /* Search Button Data */
    var searchButtonData = SearchButtonData.getData()
    var nearbyPlaces = [String]()
    
    /* UI Setup Methods */
    func initializeMap() -> Void {
        // Create ma[
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        self.mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        self.mapView.isMyLocationEnabled = true
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(self.mapView, belowSubview: self.locationsBar)
        
        // Add constraints to position the map
        let mapBottomConstraint = NSLayoutConstraint(item: self.mapView, attribute: .bottom, relatedBy: .equal, toItem: self.searchButtonsContainerBorder, attribute: .top, multiplier: 1.0, constant: 0.0)
        let mapTopConstraint = NSLayoutConstraint(item: self.mapView, attribute: .top, relatedBy: .equal, toItem: self.navBarBorder, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let mapLeadingConstraint = NSLayoutConstraint(item: self.mapView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let mapTrailingConstraint = NSLayoutConstraint(item: self.mapView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([mapBottomConstraint, mapTopConstraint, mapLeadingConstraint, mapTrailingConstraint])
        
        // Initialize the Location Manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    /* Button Actions */
    @IBAction func backButtonPressed(_ sender: Any) {
        if(self.showingServiceDetail){
            // Hide request button, go back
            UIView.animate(withDuration: 0.5, animations: {
                for constraint in self.requestButton.constraints {
                    if(constraint.identifier == "buttonBottomConstraint"){
                        constraint.constant = -100
                    }
                }
                self.showSearchButtons()
            }, completion: {(_ success: Bool) -> Void in
                self.requestButton.removeFromSuperview()
            })
        } else {
            // Toggle locations bar
            if(self.showingLocationsBar){
                self.hideLocationsBar()
            } else {
                self.showLocationsBar()
            }
        }
        
        
    }
    @IBAction func currentLocationButtonPressed(_ sender: Any) {
        // Get current location
        self.showingCurrentLocation = true
        self.mapView.isMyLocationEnabled = true
        self.locationManager.requestLocation()
        self.hideLocationsBar()
        self.hideSearchButtons()
    }
    @IBAction func philadelphiaButtonPressed(_ sender: Any) {
        // Change to Philadelphia
        self.showingCurrentLocation = false
        self.mapView.isMyLocationEnabled = false
        self.currentLocation = CLLocation(latitude: 39.952447, longitude: -75.163930)
        self.reloadMap()
        self.hideLocationsBar()
        self.placeCustomLocationMarker()
    }
    
    // Place a custom marker on the map (currently Philadelphia)
    func placeCustomLocationMarker(){
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.position = CLLocationCoordinate2D(latitude: 39.952447, longitude: -75.163930)
        marker.title = "Philadelphia"
        marker.snippet = "Pennsylvania"
        marker.map = mapView
    }
    
    /* UI Animation Methods */
    func showSearchButtons(){
        if(self.showingServiceDetail){
            self.showingServiceDetail = false
            DispatchQueue.main.async {
                self.backButton.title = "Locations"
                self.mapView.clear()
                if(!self.showingCurrentLocation){
                    self.placeCustomLocationMarker()
                }
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.15, animations: {
                    self.hideSearchButtonsConstraint.isActive = false
                    NSLayoutConstraint.activate([self.showSearchButtonsConstraint])
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    func hideSearchButtons(){
        if(!self.showingServiceDetail){
            self.showingServiceDetail = true
            DispatchQueue.main.async {
                self.backButton.title = "Back"
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.15, animations: {
                    self.showSearchButtonsConstraint.isActive = false
                    NSLayoutConstraint.activate([self.hideSearchButtonsConstraint])
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    func showLocationsBar(){
        if(!self.showingLocationsBar){
            self.showingLocationsBar = true
            DispatchQueue.main.async {
                for constraint in self.view.constraints {
                    if(constraint.identifier == "locationsBarTop"){
                        UIView.animate(withDuration: 0.15, animations: {
                            constraint.constant = 44.0
                            self.view.setNeedsLayout()
                            self.view.layoutIfNeeded()
                        })
                    }
                }
            }
        }
    }
    func hideLocationsBar(){
        if(self.showingLocationsBar){
            self.showingLocationsBar = false
            DispatchQueue.main.async {
                for constraint in self.view.constraints {
                    if(constraint.identifier == "locationsBarTop"){
                        UIView.animate(withDuration: 0.15, animations: {
                            constraint.constant = 0
                            self.locationsBar.setNeedsLayout()
                            self.locationsBar.layoutIfNeeded()
                        })
                    }
                }
            }
        }
    }
    
    /* Location Delegate Methods */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error determining location: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
        self.reloadMap()
        
    }
    
    /* Map Methods */
    func reloadMap(){
        DispatchQueue.main.async {
            self.mapView.animate(toLocation: self.currentLocation.coordinate)
            self.mapView.animate(toZoom: 15.0)
        }
        self.showSearchButtons()
    }
    
    /* Search Container Collection View Delegate Methods */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchButtonData.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Search Button", for: indexPath) as! ServiceCell
        cell.data = self.searchButtonData[indexPath.row]
        cell.refreshUI()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ServiceCell
        let cellData = self.searchButtonData[indexPath.row]
        
        // Get a list of places to show on the map
        self.requestPlaces(cellData.search)
        
        // Create the request button
        self.requestButton = UIView(frame: cell.frame)
        self.requestButton.translatesAutoresizingMaskIntoConstraints = false
        self.requestButton.layer.cornerRadius = 32.5
        self.requestButton.backgroundColor = cell.backgroundColor!
        self.requestButton.layer.borderColor = cell.backgroundColor!.lighter(by: 10.0)?.cgColor
        self.requestButton.layer.borderWidth = 1.5
        
        // Create the image for the reset button
        let image = UIImageView(frame: cell.image.frame)
        image.image = UIImage(named: cellData.image)
        image.translatesAutoresizingMaskIntoConstraints = false
        self.requestButton.addSubview(image)
        
        // Create the label for the reset button
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 18.0)
        
        self.view.addSubview(self.requestButton)
        self.hideSearchButtons()
        
        // Position the image
        let imageHeightConstraint = NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0)
        let imageWidthConstraint = NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0)
        let imageCenterYConstraint = NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: self.requestButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let imageLeadingConstraint = NSLayoutConstraint(item: image, attribute: .leading, relatedBy: .equal, toItem: self.requestButton, attribute: .leading, multiplier: 1.0, constant: 32.5)
        
        // Position the request button
        let heightConstraint = NSLayoutConstraint(item: self.requestButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 65.0)
        let widthConstraint = NSLayoutConstraint(item: self.requestButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 65.0)
        let bottomConstraint = NSLayoutConstraint(item: self.requestButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10.0)
        
        let leadingPrevConstraint = NSLayoutConstraint(item: self.requestButton, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([imageHeightConstraint, imageWidthConstraint, imageCenterYConstraint, heightConstraint, widthConstraint, bottomConstraint, leadingPrevConstraint, imageLeadingConstraint])
        
        // Animate the Button
        UIView.animate(withDuration: 0.2, animations: {
            // Expand the width of the button
            widthConstraint.isActive = false
            leadingPrevConstraint.isActive = false
            bottomConstraint.isActive = false
            
            let leadingConstraint = NSLayoutConstraint(item: self.requestButton, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 25.0)
            let trailingConstraint = NSLayoutConstraint(item: self.requestButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -25.0)
            let bottomConstraintRaised = NSLayoutConstraint(item: self.requestButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -20.0)
            bottomConstraint.identifier = "buttonBottomConstraint"
            NSLayoutConstraint.activate([trailingConstraint, bottomConstraintRaised, leadingConstraint])

            self.requestButton.setNeedsLayout()
            self.requestButton.layoutIfNeeded()
            
            // Position the label
            label.translatesAutoresizingMaskIntoConstraints = false
            self.requestButton.addSubview(label)
            label.textColor = UIColor.groupTableViewBackground
            
            let labelTopConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self.requestButton, attribute: .top, multiplier: 1.0, constant: 0.0)
            let labelBottomConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self.requestButton, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let labelTrailingConstraint = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self.requestButton, attribute: .trailing, multiplier: 1.0, constant: -32.5)
            let labelLeadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: image, attribute: .trailing, multiplier: 1.0, constant: 10)
            
            NSLayoutConstraint.activate([labelTopConstraint, labelBottomConstraint, labelTrailingConstraint, labelLeadingConstraint])
            
        }, completion: {(_ success) -> Void in
            // Change the label text
            UIView.animate(withDuration: 0.1, animations: {
                label.text = "Request " + cellData.search
            })
        })
 
    }
    
    // Report the device's location to Google Maps
    func reportDevice(){
        googlePlacesClient?.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place
                    self.googlePlacesClient?.reportDeviceAtPlace(withID: place.placeID)
                }
            }
        })
    }
    
    
    /* API Request Methods */
    func requestPlaces(_ query: String){
        // This is where an API request would be made to get location information
        
        self.mapView.animate(toLocation: self.currentLocation.coordinate)
        
        // Placeholder random data
        for i in 0...15 {
            let randomLatNum:UInt32 = arc4random_uniform(10)
            var coordinateLatOffset: Double = Double(randomLatNum) / 1000.0
            if(i % 2 == 0){
                coordinateLatOffset = coordinateLatOffset * (-1)
            }
            
            let randomNumLon:UInt32 = arc4random_uniform(10)
            var coordinateLonOffset: Double = Double(randomNumLon) / 1000.0
            if(i % 2 == 0){
                coordinateLonOffset = coordinateLonOffset * (-1)
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: self.currentLocation.coordinate.latitude + coordinateLatOffset, longitude: self.currentLocation.coordinate.longitude + coordinateLonOffset)
            
            let position = coordinate
            let marker = GMSMarker(position: position)
            marker.title = "\(coordinate.latitude), \(coordinate.longitude)"
            marker.map = self.mapView
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize Google APIs
        self.googlePlacesClient = GMSPlacesClient.shared()
        self.reportDevice()
        
        // Set the Status Bar Color
        let color = UIColor.hexStringToUIColor(hex:"3F4279")
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.statusBarView?.backgroundColor = color
        
        // Create the navBarBorder
        DispatchQueue.main.async {
            self.navBarBorder = UIView(frame: CGRect(x: 0.0, y: self.navBar.frame.maxY, width: self.navBar.frame.width, height: 2.5))
            self.view.addSubview(self.navBarBorder)
            
            self.navBarBorder.translatesAutoresizingMaskIntoConstraints = false
            self.navBar.translatesAutoresizingMaskIntoConstraints = false
            
            let navBarBorderTopConstraint = NSLayoutConstraint(item: self.navBarBorder, attribute: .top, relatedBy: .equal, toItem: self.navBar, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let navBarBorderLeadingConstraint = NSLayoutConstraint(item: self.navBarBorder, attribute: .leading, relatedBy: .equal, toItem: self.navBar, attribute: .leading, multiplier: 1.0, constant: 0.0)
            let navBarBorderTrailingConstraint = NSLayoutConstraint(item: self.navBarBorder, attribute: .trailing, relatedBy: .equal, toItem: self.navBar, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            let navBarBorderHeightConstraint = NSLayoutConstraint(item: self.navBarBorder, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2.5)
            NSLayoutConstraint.activate([navBarBorderTopConstraint, navBarBorderLeadingConstraint, navBarBorderTrailingConstraint, navBarBorderHeightConstraint])
            
            self.navBarBorder.backgroundColor = UIColor.hexStringToUIColor(hex: "3F4279").darker(by: 5.0)
        }
        
        // Create the searchButtonsContainerBorder
        DispatchQueue.main.async {
            
            self.searchButtonsContainerBorder = UIView(frame: CGRect(x: 0.0, y: self.searchButtonsContainer.frame.minY, width: self.searchButtonsContainer.frame.width, height: 2.0))
            self.view.addSubview(self.searchButtonsContainerBorder)
            
            self.searchButtonsContainerBorder.translatesAutoresizingMaskIntoConstraints = false
            self.searchButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let searchButtonsContainerBorderTopConstraint = NSLayoutConstraint(item: self.searchButtonsContainerBorder, attribute: .top, relatedBy: .equal, toItem: self.searchButtonsContainer, attribute: .top, multiplier: 1.0, constant: 0.0)
            let searchButtonsContainerBorderLeadingConstraint = NSLayoutConstraint(item: self.searchButtonsContainerBorder, attribute: .leading, relatedBy: .equal, toItem: self.searchButtonsContainer, attribute: .leading, multiplier: 1.0, constant: 0.0)
            let searchButtonsContainerBorderTrailingConstraint = NSLayoutConstraint(item: self.searchButtonsContainerBorder, attribute: .trailing, relatedBy: .equal, toItem: self.searchButtonsContainer, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            let searchButtonsContainerBorderHeightConstraint = NSLayoutConstraint(item: self.searchButtonsContainerBorder, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2.0)
            NSLayoutConstraint.activate([searchButtonsContainerBorderTopConstraint, searchButtonsContainerBorderLeadingConstraint, searchButtonsContainerBorderTrailingConstraint, searchButtonsContainerBorderHeightConstraint])
            
            self.searchButtonsContainerBorder.backgroundColor = self.searchButtonsContainer.backgroundColor!.lighter(by: 20.0)
            
            self.hideSearchButtonsConstraint = NSLayoutConstraint(item: self.searchButtonsContainerBorder, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
            self.showSearchButtonsConstraint = NSLayoutConstraint(item: self.searchButtonsContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
            
            self.tmpSearchButtonsConstraint.isActive = false
            NSLayoutConstraint.activate([self.hideSearchButtonsConstraint])
            
        }
        
        // Setup Search Button Delegate and Data Source
        self.searchButtonsCollectionView.delegate = self
        self.searchButtonsCollectionView.dataSource = self
        
        
        // Setup Various UI Colors and Fonts, and map
        DispatchQueue.main.async {
            self.locationsBar.tintColor = UIColor.hexStringToUIColor(hex: "3F4279").darker(by: 5.0)
            self.currentLocationButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 18)!], for: .normal)
            self.philadelphiaButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 18)!], for: .normal)
            self.backButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 16.0)!], for: .normal)
            self.initializeMap()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UIColor {
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    public func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    public func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
    
}


