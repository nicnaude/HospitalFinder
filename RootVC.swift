//
//  RootVC.swift
//  HospitalFinder
//
//  Created by Nicholas Naudé on 03/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RootVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // outlets:
    @IBOutlet weak var rootTableView: UITableView!
    @IBOutlet weak var directionsTextView: UITextView!
    
    // properties:
    var destinationsArray = [Hospital]()
    var destinationsArrayToProcess = []
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        directionsTextView.text = "Choose location from the list above for directions."
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        startViolatingPrivacy()
    }
    
    // ask to use location. THIS WORKS.
    func startViolatingPrivacy() {
        locationManager.startUpdatingLocation()
        print("Locating you")
    }
    
    // get current location. THIS WORKS
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location?.verticalAccuracy < 1000 && location?.horizontalAccuracy < 1000 {
            //            reverseGeoCoding(location!)
            locationManager.stopUpdatingLocation()
            print(location)
            findHelp(location!)
        }
    }
    
    
    
    // display error if location coult not be established. PROBABLY WORKS?
    func locationManager (manager: CLLocationManager, didFailWithError error: NSError){
        print(error)
    }
    
    // Look up hospitals, emergency rooms, doctors rooms.
    func findHelp (location: CLLocation) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "hospital" // add more queries here.
        request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1))
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler{(response, error) -> Void in
            let mapItems = response?.mapItems
            let mapItem = mapItems?.first!
            
            self.destinationsArrayToProcess = [mapItems!]
            print("destinationsArray: \(self.destinationsArray)")
            
            //loop through arrray
            for currentHospital in self.destinationsArrayToProcess {
                let currentHospitalName = currentHospital["name"] as! String
                
                let hospital = Hospital(hospitalName: currentHospitalName)
                self.destinationsArray.append(hospital)
                print(self.destinationsArray)
            }
        }
        
        // populate the map on a separate thread.
        
        
        // on tableViewCell tap, display directions to the point of interest in the text view.
        func getDirectionsTo(destinationItem:MKMapItem){
            let request = MKDirectionsRequest()
            request.source = MKMapItem.mapItemForCurrentLocation()
            request.destination = destinationItem
            let directions = MKDirections(request: request)
            directions.calculateDirectionsWithCompletionHandler {(response, error) -> Void in
                
                let routes = response?.routes
                let route = routes?.first
                
                var counter = 1
                var instructionsString = ""
                
                self.directionsTextView.text = " /n"
                
                for step: MKRouteStep in route!.steps {
                    print(step.instructions)
                    instructionsString = instructionsString.stringByAppendingString("\(counter). " + step.instructions + "\n")
                    counter += 1
                }
                self.directionsTextView.text = "Limp, crawl or ask a friend to take you to the nearest hospital: \(instructionsString)"
            }
        }
        
        //TODO:
        
        // on walktapped segue to new VC. Display map of current location and destination.
        
        // draw out the walking route on the map to destination.
        
        // on drivetapped segue to new VC. Display map of current location and destination.
        
        // draw out the driving route on the map to destination.
        
        // stretch goal. Display the walking times in waling directions.
        
        // populate tableview with the contents of an array containing the results from the natural language query.
        
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = rootTableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
            
            //            let currentHospital = self.destinationsArray[indexPath.row] as! NSDictionary
            //            let hospitalName = currentHospital.objectForKey("name") as? String
            //            cell.detailTextLabel?.text = "\(hospitalName)"
            //            cell.detailTextLabel?.numberOfLines = 0
            return cell
        }
        
        
        func tableViewCell(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return destinationsArray.count
        }
    }
}