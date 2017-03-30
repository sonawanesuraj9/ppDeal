//
//  HomePageViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/23/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import MapKit

import CoreLocation
import Alamofire

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
    var pinId :Int!
    
    /*func setPinid(pinid1: Int) {
        pinId = pinid1
    }
    func getPinId()->Int{
        return pinId
    }*/
    
}


class filterTableViewCell : UITableViewCell{
    
//TODO: - Controlls
    
    @IBOutlet weak var lblFilterTitle: UILabel!
}

class HomePageViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    var is_searching : Bool = Bool()
    var dataArray : NSMutableArray = NSMutableArray()
    var searchingDataArray : NSMutableArray = NSMutableArray()
    var locationManager: CLLocationManager!
    var userID : String = String()
    //Array Structure
    
    var businessIDArray : [String] = []
    var businessNameArray : [String] = []
    var businessDescArray : [String] = []
    var businessLogoUrlArray : [String] = []
    var businessPhoneArray : [String] = []
    var businessLatitude : [String] = []
    var businessLongitude : [String] = []
    
//TODO: - Controlls
   // @IBOutlet weak var btnViewAllBusinessOutlet: UIButton!
  
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var viewMain: UIView!
   
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
       
        //******** call to del method
        
        //Add Observer from appdelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomePageViewController.updateDeviceToken(_:)), name: "GotDeviceToken", object: nil)
        
    }
    
//TODO: - Update Device Token API / Webservice
    func updateDeviceToken(notification:NSNotification){
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/updatetoken", parameters : ["userid":userID,"devicetoken":delObj.deviceTokenToSend]).responseJSON{
            response in
            
            print(response.result.value)
            
            if(response.result.isSuccess){
                print("Device token updated")
            }else{
                print("Device token updation failed")
            }
        }
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        //Filter dialogue design
        self.mapView.alpha = 1
        //self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
         loadBusiness()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        
       /* let pinAnnotation = PinAnnotation()
        let location = CLLocationCoordinate2D(latitude: 37.331705, longitude: -122.030237)
       
        pinAnnotation.setCoordinate(location)
        mapView.addAnnotation(pinAnnotation)*/
        
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//TODO: - API / Webservice call
    
    func clearAllArray(){
        
        self.businessDescArray.removeAll(keepCapacity: false)
        self.businessIDArray.removeAll(keepCapacity: false)
        self.businessLogoUrlArray.removeAll(keepCapacity: false)
        self.businessNameArray.removeAll(keepCapacity: false)
        self.businessPhoneArray.removeAll(keepCapacity: false)
    }
    
    func loadBusiness(){
        self.cust.showLoadingCircle()
       
        Alamofire.request(.POST,delObj.baseUrl + "buzzdealservices.php/businesslist",parameters: ["userid": userID]).responseJSON{
            response in
            print(response.result.value)
            
            if(response.result.isSuccess){
                let jsonOut = JSON(response.result.value!)
                self.cust.hideLoadingCircle()
                
                let count = jsonOut["data"].array?.count
                
                if(count != 0){
                    
                    //clear all data before loading new one
                    self.clearAllArray()
                    
                    if let ct = count{
                        for index in 0...ct-1{
                            
                            self.businessIDArray.insert(jsonOut["data"][index]["userid"].stringValue, atIndex: index)
                            self.businessNameArray.insert(jsonOut["data"][index]["businessname"].stringValue, atIndex: index)
                            self.businessDescArray.insert(jsonOut["data"][index]["business_desc"].stringValue, atIndex: index)
                            self.businessLogoUrlArray.insert(jsonOut["data"][index]["photo"].stringValue, atIndex: index)
                            self.businessPhoneArray.insert(jsonOut["data"][index]["phone"].stringValue, atIndex: index)
                            self.businessLatitude.insert(jsonOut["data"][index]["latitude"].stringValue, atIndex: index)
                            self.businessLongitude.insert(jsonOut["data"][index]["longitude"].stringValue, atIndex: index)
                        }//end for loop
                      
                        print("DataArray: \(self.businessNameArray)")
                    }//end ct loop
                     self.addAnnotation()
                }else{
                    //Count is 0
                    
                    //create dynamic label with text. i.e. no business available
                }
            }else{
                self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                print("Fail")
            }
            
        }
        
        
        
    }
   
    
    func addAnnotation(){
        
        for ind in 0...businessNameArray.count-1{
            if(businessLatitude[ind] != "" && businessLongitude[ind] != "") {
                var latitude : Double? = Double(businessLatitude[ind])
            var longitude : Double? =  Double(businessLongitude[ind])
            var Title = businessNameArray[ind]
            var subTitle = businessNameArray[ind]
            var pid = ind
            //let id = Int(businessIDArray[ind])
            
            //****
            //The latitude and longitude of the city of Hong Kong is assigned to location constant using the CLLocationCoordinate2d struct
            var location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            
            
            //The span value is made relative small, so a big portion of London is visible. The MKCoordinateRegion method defines the visible region, it is set with the setRegion method.
                if(defaults.valueForKey("viewonmapID") != nil){
                    let id = defaults.valueForKey("viewonmapID") as! String
                    
                    for i in 0...self.businessIDArray.count-1{
                        if(id == self.businessIDArray[i]){
                            latitude = Double(businessLatitude[i])
                            longitude = Double(businessLongitude[i])
                            Title = self.businessNameArray[i]
                            subTitle = self.businessNameArray[i]
                            pid = i
                            if(latitude != nil){
                           location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
//                            
//                            let span = MKCoordinateSpanMake(0.05, 0.05)
//                            let region = MKCoordinateRegion(center: location, span: span)
//                            mapView.setRegion(region, animated: true)
                            
                            
                            // An annotation is created at the current coordinates with the MKPointAnnotaition class. The annotation is added to the Map View with the addAnnotation method.
                            let info1 = CustomPointAnnotation()
                            info1.coordinate = location
                            info1.title = Title
                            info1.subtitle = subTitle
                            info1.imageName = "pinIc50.png"
                            info1.pinId = Int(pid)
                            mapView.addAnnotation(info1)
                            
                            break
                            }
                        }
                    }
                    
                    
                }else{
//                    let span = MKCoordinateSpanMake(0.05, 0.05)
//                    let region = MKCoordinateRegion(center: location, span: span)
//                    mapView.setRegion(region, animated: true)
                }
                
            
            }
        }
        
        zoomToFitMapAnnotations(mapView)
    }
    
    func zoomToFitMapAnnotations(mapView: MKMapView) {
        if mapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in mapView.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        var region: MKCoordinateRegion = MKCoordinateRegion()
        
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5

        
        // Add a little extra space on the sides
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    
//TODO: - MKMapViewDelegate Method implementation
    /*func locationManager(manager: CLLocationManager!, didUpdateToLocation locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
        self.mapView.setRegion(region, animated: true)
    }*/
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        let detailButton: UIButton = UIButton(type: UIButtonType.DetailDisclosure)
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
            anView!.rightCalloutAccessoryView = detailButton
           
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
         anView!.image = UIImage(named:cpa.imageName)
         anView!.tag = cpa.pinId
        
        
        return anView
    }
    
      
    
    //Method call when annotation is click
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        print(view.tag)
        let tag = view.tag
        
        var selectedBusinessDetails = Dictionary<String, AnyObject>()
       
        selectedBusinessDetails = [
                "businessID" : self.businessIDArray[tag]
            ]
      
        
        //store business detail in dictonary to carry over next
        defaults.setValue(selectedBusinessDetails, forKey: "selectedBusinessDetails")
        defaults.synchronize()
        
        
          let dtVC = self.storyboard?.instantiateViewControllerWithIdentifier("idBusinessDetailViewController") as! BusinessDetailViewController
        self.navigationController?.pushViewController(dtVC, animated: true)
       
    }
    
  /*  @IBAction func btnFilterViewClick(sender: AnyObject) {
        self.displayalertWithTable()
    }*/
    
    /*@IBAction func btnViewAllBusinessClick(sender: AnyObject) {
        
        let allVC = self.storyboard?.instantiateViewControllerWithIdentifier("idBusinessListViewController") as! BusinessListViewController
        self.navigationController?.pushViewController(allVC, animated: true)
        
    }*/
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func btnFavoriteClick(sender:UIButton){
        print("btnFav CLick")
    }
    
    func btnShareClick(sender : UIButton){
        print("btn share click")
    }

    
    func displayalertWithTable(){
        let alert = UIAlertController(title: "BuzzDeal", message: "Select Miles", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            print("Cancel Press")
        alert.addAction(UIAlertAction(title: "Walking (1 mile)", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            print("1")
        }))
        alert.addAction(UIAlertAction(title: "Short Cab (5 miles)", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            print("2")
        }))
        alert.addAction(UIAlertAction(title: "Long Cab (15 miles)", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            print("3")
        }))
        
        alert.addAction(UIAlertAction(title: "Designated Driver (25 miles)", style: UIAlertActionStyle.Default,  handler: { (action:UIAlertAction) -> Void in
            print("4")
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
