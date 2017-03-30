//
//  HomeDealViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 4/25/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SafariServices

class HomeDealTableViewCell : UITableViewCell{
    
    //TODO : - Controls
    
    @IBOutlet weak var lblDealTitle: UILabel!
    @IBOutlet weak var lblDealDesc: UILabel!
    @IBOutlet weak var btnViewOnMap: UIButton!
    
    @IBOutlet weak var imgBusinessLogo: UIImageView!
    @IBOutlet weak var lblBusinessName: UIButton!
    @IBOutlet weak var borderView: UIView!
   // @IBOutlet weak var lblBusinessName: UILabel!
    @IBOutlet weak var btnBuzzIT: UIButton!
   // @IBOutlet weak var lblDealDate: UILabel!
    
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblDealStartDate: UILabel!
    @IBOutlet weak var lblDealStartTime: UILabel!
    
    @IBOutlet weak var lblDealEndDate: UILabel!
    @IBOutlet weak var lblDealEndTime: UILabel!
}

@available(iOS 9.0, *)
class HomeDealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate ,CLLocationManagerDelegate,SFSafariViewControllerDelegate{

    
    
//TODO: General
    
    let cust : CustomClass_Dev = CustomClass_Dev()
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()
    let convert : Conversions = Conversions()
    
    
    var userID : String = String()
    //Response Handler
    
    var dealIDArray : [String] = []
    var dealTitleArray : [String] = []
    var dealDescArray : [String] = []
    var dealStartDateArray : [String] = []
    var dealEndDateArray : [String] = []
    var dealStartTimeArray : [String] = []
    var dealEndTimeArray : [String] = []

    var businessPictureArray : [String] = []
    var businessIDArray : [String] = []
    var businessNameArray : [String] = []
    var businessAddressArray : [String] = []
     var businessLocation : [String] = []
    var businessLatArray : [String] = []
    var businessLongArray : [String] = []
    
//TODO: Controls
    
    var  safariVC : SFSafariViewController!
    @IBOutlet weak var tblDealList: UITableView!
    
    @IBOutlet weak var btnViewAllMerchantsOutlet: UIButton!
    var messageLable  : UILabel = UILabel()
    
    
//TODO: Let's Play
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        self.delObj.locFlag = false
        self.delObj.CurrentLocationIdentifier()
        
       // if(self.delObj.locationStatusEnable){
        //Add Observer from appdelegate
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeDealViewController.gotUserLocation(_:)), name: "postLocationUpdate", object: nil)
        //}else{
            
            loadAllActiveDeal()
        //}
        
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func gotUserLocation(notification : NSNotification){
        
        loadAllActiveDeal()
    }
    
    func fetchDistanceBetween(businessLat:String,businessLong:String,index:Int, completion : (Bool) -> ()) -> String{
        var DisplayKM : String = String()
        let currentLat = defaults.valueForKey("currentLat") as! Double
        let currentLon = defaults.valueForKey("currentLon") as! Double
        
        //https:/maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615,-73.9976592&key=AIzaSyBG3ywOviyiatBY7h7nPRsKvTMayjdyhaM
        
        // if(self.businessLat != 0){
        
        let googleAPIURL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(currentLat),\(currentLon)&destinations=\(businessLat),\(businessLong)&key=AIzaSyBG3ywOviyiatBY7h7nPRsKvTMayjdyhaM"
        
        
        print("gogoleAPIURL:\(googleAPIURL)")
        Alamofire.request(.POST, googleAPIURL).responseJSON{
            response in
            
            print(response.result)
            
            if(response.result.isSuccess){
                
                print(response.result.value!)
                //Hide Activity
                //    self.cust.hideLoadingCircle()
                let outJSON = JSON(response.result.value!)
                print("JSON:: \(outJSON)")
                
                let overCount = outJSON["rows"].count
                for overTmp in 0...overCount-1{
                    let innerCount = outJSON["rows"][overTmp]["elements"].count
                    for innerTmp in 0...innerCount-1{
                        let textOut = outJSON["rows"][overTmp]["elements"][innerTmp]["distance"]["text"].stringValue
                        print("222:\(textOut)")
                        
                        let modified = textOut.replace("mi", withString:"")
                        
                        print("modified:\(modified)")
                        let m : Double =  NSString(string: modified).doubleValue // 3.1 //Double(modified)!// as! Double
                        print("newDouble::\(self.convert.milesToKilometers(m))")
                        
                        DisplayKM = String(format:"%.2f", self.convert.milesToKilometers(m))
                        self.businessLocation.insert(DisplayKM, atIndex: index)
                        completion(true)
                        //set distance to label
                       
                        
                       /* UIView.animateWithDuration(0.6, animations: { () -> Void in
                            self.imgLocation.transform = CGAffineTransformMakeScale(1.3, 1.3)
                        }) { (Value:Bool) -> Void in
                            UIView.animateWithDuration(0.6, animations: { () -> Void in
                                self.imgLocation.transform = CGAffineTransformIdentity
                                }, completion: nil)
                            
                        }*/
                        
                    }
                    
                }
                
                
                
                //
            }else{
                //Hide Activity
                //self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
            }
        }
        //self.tblDealList.reloadData()
        return DisplayKM
        //}
    }
    
//TODO: - WebService / API call
    
    func clearAllArray(){
        
        dealIDArray.removeAll(keepCapacity: false)
        dealTitleArray.removeAll(keepCapacity: false)
        dealDescArray.removeAll(keepCapacity: false)
        dealStartTimeArray.removeAll(keepCapacity: false)
        dealEndTimeArray.removeAll(keepCapacity: false)
        dealStartDateArray.removeAll(keepCapacity: false)
        dealEndDateArray.removeAll(keepCapacity: false)
        businessIDArray.removeAll(keepCapacity: false)
        businessNameArray.removeAll(keepCapacity: false)
        businessPictureArray.removeAll(keepCapacity: false)
        businessLatArray.removeAll(keepCapacity: false)
        businessLongArray.removeAll(keepCapacity: false)
        businessAddressArray.removeAll(keepCapacity: false)
    }
    
    func loadAllActiveDeal(){
      //  self.cust.showLoadingCircle()
        //SVProgressHUD.showWithStatus("Loading...")
       
        let parameters = ["userid":userID,
                          "lat":delObj.currentLat,
                          "long":delObj.currentLong]
        Alamofire.request(.POST,delObj.baseUrl + "buzzdealservices.php/allactivedeals", parameters: parameters ).responseJSON{
            response in
            print("parameters active deal ::: \(parameters)")
            print(response.result.value)
            
            if(response.result.isSuccess){
                let jsonOut = JSON(response.result.value!)
                
                if(jsonOut["status"] != "1"){
                    //SVProgressHUD.dismiss()
                   // self.cust.hideLoadingCircle()
                    
                    let count = jsonOut["data"].array?.count
                    
                    if(count != 0){
                        
                        //clear all data before loading new one
                        self.clearAllArray()
                        
                        
                        if let ct = count{
                            for index in 0...ct-1{
                                
                                if(jsonOut["data"][index]["dealconfirmed"].stringValue == "N"){
                                    
                                self.dealIDArray.append(jsonOut["data"][index]["id"].stringValue)
                                self.dealTitleArray.append(jsonOut["data"][index]["deal_title"].stringValue)
                                self.dealDescArray.append(jsonOut["data"][index]["deal_description"].stringValue)
                                self.dealStartDateArray.append(jsonOut["data"][index]["start_date"].stringValue)
                                self.dealEndDateArray.append(jsonOut["data"][index]["end_date"].stringValue)
                                
                                self.dealStartTimeArray.append(jsonOut["data"][index]["start_time"].stringValue)
                                self.dealEndTimeArray.append(jsonOut["data"][index]["end_time"].stringValue)
                                
                                self.businessIDArray.append(jsonOut["data"][index]["business_id"].stringValue)
                                self.businessNameArray.append(jsonOut["data"][index]["business_name"].stringValue)
                               self.businessPictureArray.append(jsonOut["data"][index]["picture"].stringValue)
                                    
                                self.businessAddressArray.append(jsonOut["data"][index]["address"].stringValue)
                                    
                                    
                                self.businessLatArray.append(jsonOut["data"][index]["latitude"].stringValue)
                                self.businessLongArray.append(jsonOut["data"][index]["longitude"].stringValue)
                                    
                                    //Location Data
                                   /*var tempLat : Double =  Double()
                                    var tempLon : Double = Double()
                                    if(jsonOut["data"][index]["latitude"].stringValue != ""){
                                        tempLat = Double(jsonOut["data"][index]["latitude"].stringValue)!
                                        tempLon = Double(jsonOut["data"][index]["longitude"].stringValue)!
                                    }else{
                                        tempLat = 0.0
                                        tempLon = 0.0
                                    }
                                
                                let tempComb =  CLLocation(latitude: tempLat, longitude: tempLon)
                                self.businessLocation.append(tempComb)*/
                                    /*let tempLat = jsonOut["data"][index]["latitude"].stringValue
                                    let tempLon = jsonOut["data"][index]["longitude"].stringValue
                                    if(tempLat != ""){
                                      // self.fetchDistanceBetween(tempLat, businessLong: tempLon,index: index)
                                         self.businessLocation.append("")
                                    }else{
                                        
                                    }*/
                                   self.businessLocation.append("")
                                    
                                }
                            }//end for loop
                            
                            
                            //MARK: Fetch Distance From Google
                            if self.businessLatArray.count > 0{
                                for ind in 0...self.businessLatArray.count-1{
                                    let tempLat = self.businessLatArray[ind]
                                    let tempLon = self.businessLongArray[ind]
                                    self.fetchDistanceBetween(tempLat, businessLong: tempLon,index: ind){
                                        response in
                                        if response{
                                            self.tblDealList.reloadData()
                                        }else{
                                            
                                        }
                                    }
                                }
                            }
                            print("DataArray: \(self.dealIDArray)")
                        }//end ct loop
                        
                        self.messageLable.removeFromSuperview()
                        self.tblDealList.hidden = false
                        // self.dealTable.reloadData()
                        self.tblDealList.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                    }
                    if(jsonOut["dealcount"].stringValue == "0"){
                        self.displayNoBusinessMessage()
                    }
                }
            }else{
               // self.cust.hideLoadingCircle()
               
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                print("Fail")
            }
            
        }
    }
    
    func displayNoBusinessMessage(){
        messageLable = UILabel(frame: CGRectMake(10,self.view.frame.size.height/2,self.view.frame.size.width*0.8,self.view.frame.size.height*0.5))
        messageLable.center = self.view.center
        messageLable.textAlignment = .Center
        messageLable.text = "No deals available"
        messageLable.textColor = UIColor.lightGrayColor()
        messageLable.font = UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)
        self.tblDealList.hidden = true
        self.view.addSubview(messageLable)
    }
    
//TODO: - UITableViewDatasource Method Implementation
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dealIDArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell  = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath) as! HomeDealTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.borderView.layer.borderWidth = 1.0
        cell.borderView.layer.borderColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.6).CGColor
        cell.borderView.layer.cornerRadius = cust.RounderCornerRadious
        
        let ur : NSURL = NSURL(string: businessPictureArray[indexPath.row])!
        cell.imgBusinessLogo.sd_setImageWithURL(ur, placeholderImage: self.delObj.businessPlaceHolderImage, options: SDWebImageOptions.RefreshCached)
        cell.imgBusinessLogo.layer.cornerRadius = self.cust.RounderCornerRadious
        
        cell.lblBusinessName.setTitle(self.businessNameArray[indexPath.row], forState: UIControlState.Normal)
        
        cell.lblDealStartDate.text = self.dealStartDateArray[indexPath.row]
        cell.lblDealStartTime.text = " " + self.dealStartTimeArray[indexPath.row] + " "
        cell.lblDealStartTime.layer.cornerRadius = cust.RounderCornerRadious
        cell.lblDealStartTime.clipsToBounds = true
        
        cell.lblDealEndDate.text = self.dealEndDateArray[indexPath.row]
        cell.lblDealEndTime.text = " " + self.dealEndTimeArray[indexPath.row] + " "
        cell.lblDealEndTime.layer.cornerRadius = cust.RounderCornerRadious
        cell.lblDealEndTime.clipsToBounds = true
        //cell.lblDealDate.text = self.dealStartDateArray[indexPath.row] + " " + self.dealStartTimeArray[indexPath.row] + " - " + self.dealEndTimeArray[indexPath.row]
        
        
        cell.lblDealDesc.text = self.dealDescArray[indexPath.row]
        
        if(cell.lblDealDesc.text?.characters.count > 100){
            let abc : String = (cell.lblDealDesc.text! as NSString).substringWithRange(NSRange(location: 0, length: 100))
            
            let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: abc)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: cust.FontSizeText)!, range: NSMakeRange(0, abc.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value:  cust.textColor, range: NSMakeRange(0, abc.characters.count))
            let moreString = NSMutableAttributedString(string: " ...")
          //  moreString.addAttribute(NSLinkAttributeName, value: " ...", range: NSRange(location: 0, length: 4))
            moreString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0), range: NSMakeRange(0, 3))
            
            attributedString.appendAttributedString(moreString)
            cell.lblDealDesc.tag = indexPath.row
            cell.lblDealDesc.attributedText = attributedString
        }else{
            
            let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: cell.lblDealDesc.text!)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: cust.FontSizeText)!, range: NSMakeRange(0, cell.lblDealDesc.text!.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value:  cust.textColor, range: NSMakeRange(0, cell.lblDealDesc.text!.characters.count))
            cell.lblDealDesc.tag = indexPath.row
            cell.lblDealDesc.attributedText = attributedString
        }
        
        //Distance from current location
        if(self.delObj.currentLat != "0"){
            cell.lblDistance.text = " KM"
            if(self.businessLocation[indexPath.row] == ""){
               // self.fetchDistanceBetween(self.businessLatArray[indexPath.row], businessLong: self.businessLongArray[indexPath.row],index: indexPath.row)
                
            }else{
                 cell.lblDistance.text = "\(self.businessLocation[indexPath.row]) KM"
            }
            
            
            //let outVal = self.businessLocation[indexPath.row]
            //cell.lblDistance.text = "\(outVal) KM"
        }else{
             cell.lblDistance.text = " KM"
        }
        
        //Map button
        if(self.businessLatArray[indexPath.row] == ""){
            cell.btnViewOnMap.hidden = true
        }else{
             cell.btnViewOnMap.hidden = false
        }
        
        
        cell.lblDealTitle.text = self.dealTitleArray[indexPath.row]
        
        cell.btnBuzzIT.layer.cornerRadius = cust.RounderCornerRadious
        cell.btnBuzzIT.tag = indexPath.row
        cell.lblBusinessName.tag = indexPath.row
        
        cell.btnViewOnMap.tag = indexPath.row
        cell.btnViewOnMap.addTarget(self, action: #selector(HomeDealViewController.btnViewOnMapClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.lblBusinessName.addTarget(self, action: #selector(HomeDealViewController.lblBusinessNameClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnBuzzIT.addTarget(self, action: #selector(HomeDealViewController.btnBuzzITClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        defaults.setValue(self.businessIDArray[indexPath.row], forKey: "businessID")
        
        let dealDTVC = self.storyboard?.instantiateViewControllerWithIdentifier("idDealDetailViewController") as! DealDetailViewController
        
        dealDTVC.dealID = self.dealIDArray[indexPath.row]
      //  dealDTVC.is_alreadyAcceptedDeal =
        self.navigationController?.pushViewController(dealDTVC, animated: true)
        
        print("Deal details click")
        
    }
    
    
    
    

//TODO: - Button Click
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
   
    func btnViewOnMapClick(sender:UIButton){
        
        
        var currentLat : Double = Double()
        var currentLon : Double = Double()
        
        
        currentLat = defaults.valueForKey("currentLat") as! Double
        currentLon = defaults.valueForKey("currentLon") as! Double
        
        
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: currentLat, longitude: currentLon)
        var sourceAddress = String()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print("placeMark.addressDictionary:\(placeMark.addressDictionary)")
            
            var name : String = String()
            var streetname : String = String()
            var cityname : String = String()
            //var name : String = String()
            
            
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                print("locationName:\(locationName)")
                name = "\(locationName)"
            }
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                print("street:\(street)")
                streetname = "\(street)"
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print("city:\(city)")
                cityname = "\(city)"
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                print("zip:\(zip)")
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                print("country:\(country)")
            }
            sourceAddress = "\(name),+\(cityname)"
            let destAddress = self.businessAddressArray[sender.tag]
            
            
            let newString = sourceAddress.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let newString1 = newString.stringByReplacingOccurrencesOfString("/", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            print("newString>> \(newString1)")
            
            
            let newDestString = destAddress.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let newDestString1 = newDestString.stringByReplacingOccurrencesOfString("/", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            print("newDestString>> \(newDestString1)")
            
            let combineUrl = "https://www.google.co.in/maps/dir/\(newString1)/\(newDestString1)"
            
            print("combineUrl: >> \(combineUrl)")
            
            // if(UIApplication.sharedApplication().canOpenURL(NSURL(string: combineUrl)){
            
            self.safariVC = SFSafariViewController(URL: NSURL(string: combineUrl)!)
            self.safariVC.delegate = self
            self.presentViewController(self.safariVC, animated: true, completion: nil)
            
            // }
            
            
            
            
            
        })
        
        
        

        
        
       /* print(self.businessIDArray[sender.tag])
       let title = self.businessNameArray[sender.tag] 
       let lat = Double(self.businessLatArray[sender.tag])!// as! Double
       let long = Double(self.businessLongArray[sender.tag])! // as! Double
        
        self.defaults.setValue(self.businessIDArray[sender.tag], forKey: "viewonmapID")
       
        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("idMapDisplayViewController") as! MapDisplayViewController
        mapVC.bus_title = title
        mapVC.bus_lat = lat
        mapVC.bus_long = long
        self.navigationController?.pushViewController(mapVC, animated: true)

        */
      
    
    }
    
    func lblBusinessNameClick(sender:UIButton){
        
        let index = sender.tag
        var selectedBusinessDetails = Dictionary<String, AnyObject>()
        
        selectedBusinessDetails = [
                "businessID" : self.businessIDArray[index]
        ]
        //store business detail in dictonary to carry over next
        defaults.setValue(selectedBusinessDetails, forKey: "selectedBusinessDetails")
        defaults.synchronize()
        let dtVC = self.storyboard?.instantiateViewControllerWithIdentifier("idBusinessDetailViewController") as! BusinessDetailViewController
        self.navigationController?.pushViewController(dtVC, animated: true)
        
    }
    
    func btnBuzzITClick(sender:UIButton){
        
        print(self.dealIDArray[sender.tag])
        let index = sender.tag
        defaults.setValue(self.businessIDArray[index], forKey: "businessID")
        
        let dealDTVC = self.storyboard?.instantiateViewControllerWithIdentifier("idDealDetailViewController") as! DealDetailViewController
        
        dealDTVC.dealID = self.dealIDArray[index]
        
        self.navigationController?.pushViewController(dealDTVC, animated: true)
        
        print("Deal details click")

    }

}
