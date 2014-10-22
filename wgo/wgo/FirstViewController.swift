//
//  FirstViewController.swift
//  wgo
//
//  Copyright (c) 2014 DJSS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation
import CoreData

class FirstViewController: UIViewController, CLLocationManagerDelegate , UITableViewDelegate{
    
    @IBOutlet var mapView: MKMapView!
    var myPin:[MKPointAnnotation] = []
    var currLoc:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var data = NSMutableData()
    var locationManager = CLLocationManager()
    @IBOutlet weak var minimizeButton: UIButton!
    let tapRec = UITapGestureRecognizer()
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            
            tapRec.addTarget(self, action: "tappedView")
            minimizeButton.addTarget(self, action: Selector("miniClick"), forControlEvents: .TouchUpInside)
            mapView.addGestureRecognizer(tapRec)
            mapView.userInteractionEnabled = true
            minimizeButton.hidden = true
            /*Starts thread to call update() every 10 seconds)*/
            let priority = DISPATCH_QUEUE_PRIORITY_HIGH
            dispatch_async(dispatch_get_global_queue(priority, 0), { ()->() in
            dispatch_async(dispatch_get_main_queue(), {
            var timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("update"), userInfo: nil, repeats: true)//Update is called every 10 seconds
           println("hello from UI thread executed as dispatch")
            
            })
            })
           println("hello from UI thread")
            let location = locationManager.location
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
            self.mapView.setRegion(region, animated: true)
        }
        
    }
    
    /*Function called when map needs to be maximized*/
    func tappedView(){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height;
        minimizeButton.hidden = false
       UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut  , animations: {
            var frame = self.mapView.frame
            frame.size.height = screenHeight
            self.mapView.frame = frame
            }, completion: nil)
    }
    /*Function called when map needs to be minimized*/
    func miniClick(){
         minimizeButton.hidden = true
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut  , animations: {
            var frame = self.mapView.frame
            frame.size.height = 213
            self.mapView.frame = frame
            }, completion: nil)

    }
    /*Not Being Used At The Moment, But Will Be..Used for to show CoreData info*/
    func presentItemInfo() {
        let fetchRequest = NSFetchRequest(entityName: "UserEn")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [UserEn] {
                let alert = UIAlertView()
                alert.title = fetchResults[0].first_name
                alert.message = fetchResults[0].last_name
                alert.show()
            
        }
    }
    
    /*Update is called every 10 seconds, 
     * It clears the pins and gets stuff from the database
     * It then loops through all of the people and makes a pin for each one
     */
    func update(){
        self.mapView.removeAnnotations(myPin)
        myPin = []
        let fetchRequest = NSFetchRequest(entityName: "UserEn")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [UserEn] {
            var currId:String = fetchResults[0].id
        var markersDictionary: NSArray = Poster.parseJSON(Poster.getJSON(Poster.getIP() + "/users/\(currId)/friends"))
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        //saddInitialPin(locationManager)
                /* Start Loop to Update ALL Markers */
        for i in 0...markersDictionary.count-1 {
            var lnglat:NSArray = markersDictionary[i]["loc"] as NSArray
            var firstname: String = markersDictionary[i]["first_name"] as String
            var lastname: String = markersDictionary[i]["last_name"] as String
            var subname:String = "subname"
            var lng:double_t = lnglat[0] as double_t
            var lat:double_t = lnglat[1] as double_t
            /*Making a Pin here...*/
            var currentLat:CLLocationDegrees = lat
            var currentLng:CLLocationDegrees = lng
            currLoc = CLLocationCoordinate2DMake(currentLat, currentLng)
            myPin.append(MKPointAnnotation())
            myPin[i].coordinate = currLoc
            myPin[i].title = (firstname + " " + lastname)
            self.mapView.addAnnotation(myPin[i])
            /* End Of Pin Code*/
        }
        }
    }
   
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        var currentLat:CLLocationDegrees = location.coordinate.latitude
        var currentLng:CLLocationDegrees = location.coordinate.longitude
        currLoc = CLLocationCoordinate2DMake(currentLat, currentLng)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")!
        cell.textLabel?.text = "Event #\(indexPath.row)"
        cell.detailTextLabel?.text = "Event Description"
        return cell
    }
    
}