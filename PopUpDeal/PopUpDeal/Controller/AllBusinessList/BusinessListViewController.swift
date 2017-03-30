
//
//  BusinessListViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 3/4/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import CoreLocation


class BusinessListTableViewCell : UITableViewCell{

//TODO: - Controlls
    @IBOutlet weak var lblBusinessName: UILabel!
    
    @IBOutlet weak var lblCuisine: UILabel!
    @IBOutlet weak var txtBusinessDesc: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var btnViewOnMap: UIButton!
    @IBOutlet weak var btnShareBusiness: UIButton!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var imgBusinessPic: UIImageView!
    @IBOutlet weak var lblDealCount: UIButton!
   // @IBOutlet weak var lblDealCount: UILabel!
   // @IBOutlet weak var txtBusinessDesc: UITextView!
    
}

@available(iOS 9.0, *)
class BusinessListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,FBSDKSharingDelegate,SFSafariViewControllerDelegate {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    var is_searching : Bool = Bool()
    var businessNameArray : NSMutableArray = NSMutableArray()
    var sortedbusinessNameArray : NSMutableArray = NSMutableArray()
    var userID : String = String()
    var postImage : UIImage = UIImage()
    var kickMeFlag : Bool = Bool()
   
    //Array Structure
    var businessLatArray : [String] = []
    var businessLongArray : [String] = []
    var businessIDArray : [String] = []
    var businessDescArray : [String] = []
    var businessLogoUrlArray : [String] = []
    var businessPhoneArray : [String] = []
    var businessTotalDealArray : [String] = []
    var businessIsFavArray : [String] = []
    var businessGalleryImageArray : [String] = []
    var businessCuisineArray : [String] = []
    var businessAddressArray : [String] = []
    
    
    var sortedbusinessLatArray : NSMutableArray = NSMutableArray()
    var sortedbusinessLongArray : NSMutableArray = NSMutableArray()
    var sortedNameArray : NSMutableArray = NSMutableArray()
    var sortedIDArray : NSMutableArray = NSMutableArray()
    var sortedDescArray : NSMutableArray = NSMutableArray()
    var sortedPhoneArray : NSMutableArray = NSMutableArray()
    var sortedLogoArray : NSMutableArray = NSMutableArray()
    var sortedTotalDealArray : NSMutableArray = NSMutableArray()
    var sortedIsFavArray : NSMutableArray = NSMutableArray()
    var sortedBusinessCuisineArray : NSMutableArray = NSMutableArray()
    var sortedBusinessAddressArray : NSMutableArray = NSMutableArray()
    
//TODO: - Controlls
    
    @IBOutlet weak var btnallActiveDealOutlet: UIButton!
    @IBOutlet weak var tblBusinessList: UITableView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    var  messageLable : UILabel = UILabel()
    
    var  safariVC : SFSafariViewController!
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
       
        self.tblBusinessList.tableFooterView = UIView(frame: CGRectZero)
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
       // displayNoBusinessMessage()
        defaults.setValue(nil, forKey: "viewonmapID")
        
        self.delObj.CurrentLocationIdentifier()
      
        
     //   if(self.delObj.locationStatusEnable){
            
        //Add Observer from appdelegate
     //   NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessListViewController.gotUserLocation(_:)), name: "postLocationUpdate", object: nil)
     //       kickMeFlag = true
        // }else{
            
            loadAllBusiness()
        //}
        
        //Add Observer from appdelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomePageViewController.updateDeviceToken(_:)), name: "GotDeviceToken", object: nil)
        
        //self.loadAllBusiness()
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        searchBarOutlet.delegate = self
        searchBarOutlet.text = ""
        is_searching = false       
        resignFirstResponder()
        sortedbusinessNameArray = []
         self.tblBusinessList.hidden = false
          self.messageLable.hidden = true
       self.tblBusinessList.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
          self.btnallActiveDealOutlet.layer.cornerRadius = cust.RounderCornerRadious
        
    }
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
    
    
    
    
    
//TODO: - API / Webservice call
    
    func gotUserLocation(notification : NSNotification){
        if(kickMeFlag){
            kickMeFlag = false
            //loadAllBusiness()
        }
        
    }
    
    
    
    
    func clearAllArray(){
        self.businessDescArray.removeAll(keepCapacity: false)
        self.businessIDArray.removeAll(keepCapacity: false)
        self.businessLogoUrlArray.removeAll(keepCapacity: false)
        self.businessNameArray.removeAllObjects()
        self.businessPhoneArray.removeAll(keepCapacity: false)
        self.businessGalleryImageArray.removeAll(keepCapacity: false)
        self.businessLatArray.removeAll(keepCapacity: false)
        self.businessLongArray.removeAll(keepCapacity: false)
        self.businessCuisineArray.removeAll(keepCapacity: false)
        self.businessAddressArray.removeAll(keepCapacity: false)
    }
    
    
    
    
    func loadAllBusiness(){
       // self.cust.showLoadingCircle()
         //SVProgressHUD.showWithStatus("Loading...")
      
        var lat : String = String()
        var lon : String = String()
        
        /*if(defaults.valueForKey("currentLat") != nil){
            lat = "\(defaults.valueForKey("currentLat") as! Double)"
        }else{
            lat = "0"
        }
        
        if(defaults.valueForKey("currentLon") != nil){
             lon = "\(defaults.valueForKey("currentLon") as! Double)"
        }else{
            lon = "0"
        }
        */
         lon = "0"
        lat = "0"
        let parameters = ["userid": userID,"lat":lat,"long":lon]
        
        Alamofire.request(.POST,delObj.baseUrl + "buzzdealservices.php/businesslist",parameters: parameters).responseJSON{
            response in
            print("parameters view all:::\(parameters)")
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
                            
                            self.businessIDArray.insert(jsonOut["data"][index]["userid"].stringValue, atIndex: index)
                            self.businessNameArray.insertObject(jsonOut["data"][index]["businessname"].stringValue, atIndex: index)
                            self.businessDescArray.insert(jsonOut["data"][index]["business_desc"].stringValue, atIndex: index)
                            self.businessLogoUrlArray.insert(jsonOut["data"][index]["photo"].stringValue, atIndex: index)
                            self.businessPhoneArray.insert(jsonOut["data"][index]["phone"].stringValue, atIndex: index)
                            self.businessTotalDealArray.insert(jsonOut["data"][index]["totdeal"].stringValue, atIndex: index)
                            self.businessIsFavArray.insert(jsonOut["data"][index]["isFav"].stringValue, atIndex:  index)
                            self.businessGalleryImageArray.insert(jsonOut["data"][index]["businessgallery"].stringValue, atIndex: index)
                            self.businessLongArray.insert(jsonOut["data"][index]["longitude"].stringValue, atIndex: index)
                            self.businessLatArray.insert(jsonOut["data"][index]["latitude"].stringValue, atIndex: index)
                             self.businessCuisineArray.insert(jsonOut["data"][index]["cuisine"].stringValue, atIndex: index)
                            self.businessAddressArray.insert(jsonOut["data"][index]["address"].stringValue, atIndex: index)
                            
                        }//end for loop
                        
                         print("DataArray: \(self.businessNameArray)")
                    }//end ct loop
                    
                      self.tblBusinessList.hidden = false
                      self.messageLable.hidden = true
                        self.tblBusinessList.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                   
                    
                    }
                    
                    if(jsonOut["rowcount"].stringValue == "0"){
                    //Count is 0
                        self.messageLable.hidden = false
                        self.tblBusinessList.hidden = true
                        self.displayNoBusinessMessage()
                        
                    //create dynamic label with text. i.e. no business available
                        }
                    }
            }else{
               // self.cust.hideLoadingCircle()
                 //SVProgressHUD.dismiss()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                print("Fail")
            }
            
        }
    }
    
    
    
    
    func displayNoBusinessMessage(){
        messageLable = UILabel(frame: CGRectMake(10,self.view.frame.size.height/2,self.view.frame.size.width*0.8,self.view.frame.size.height*0.5))
        messageLable.center = self.view.center
        messageLable.textAlignment = .Center
        messageLable.text = "No Business Found"
        messageLable.textColor = UIColor.lightGrayColor()
        messageLable.font = UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)
        self.view.addSubview(messageLable)
        
        
    }

    
    
//TODO: - UITableViewDatasource Method implementation
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if is_searching{
            if(sortedbusinessNameArray.count == 0){
                 self.messageLable.hidden = false
               // self.tblBusinessList.hidden = true
            }else{
               //  self.tblBusinessList.hidden = false
                self.messageLable.hidden = true
            }
            return sortedbusinessNameArray.count
        }else{
            return businessNameArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath) as! BusinessListTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        
        cell.borderView.layer.borderWidth = 1.0
        cell.borderView.layer.borderColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.6).CGColor
        cell.borderView.layer.cornerRadius = cust.RounderCornerRadious
        
        
        var tmpImgUrl : String = String()
        
        cell.txtBusinessDesc.textColor = cust.textColor
       if is_searching{
            cell.lblBusinessName.text = sortedbusinessNameArray[indexPath.row] as? String
        
            //Business image
            tmpImgUrl = self.sortedLogoArray[indexPath.row] as! String
        
            if(self.sortedIsFavArray[indexPath.row] as! String == "0"){
                print("Not Favorite")
                cell.btnFavorite.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
            }else{
                print("Favorite business")
                cell.btnFavorite.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
            }
            cell.btnFavorite.tag = indexPath.row
            cell.lblCuisine.text = " \(self.sortedBusinessCuisineArray[indexPath.row] as? String) "
        
            cell.btnShareBusiness.tag = indexPath.row
            if(self.sortedTotalDealArray[indexPath.row] as! String == "0"){
                cell.lblDealCount.hidden = true
            }else{
                cell.lblDealCount.hidden = false
                var dealVar : String = String()
                if((self.sortedTotalDealArray[indexPath.row] as! String) == "1"){
                    dealVar = " Deal"
                }else{
                   dealVar = " Deals"
                }
                cell.lblDealCount.setTitle((self.sortedTotalDealArray[indexPath.row] as! String) + dealVar, forState: UIControlState.Normal) 
            }
        
            cell.btnViewOnMap.tag = indexPath.row
        
            cell.lblDealCount.tag = indexPath.row
            cell.txtBusinessDesc.tag = indexPath.row
            cell.txtBusinessDesc.text = self.sortedDescArray[indexPath.row] as? String
        
        //Check if location data is availble, then display map button
            if(sortedbusinessLatArray[indexPath.row] as! String == ""){
                cell.btnViewOnMap.hidden = true
            }else{
                cell.btnViewOnMap.hidden = false
            }
        
        
        //Attributed Description
            if(cell.txtBusinessDesc.text!.utf16.count >= 100){
                let abc : String = (cell.txtBusinessDesc.text! as NSString).substringWithRange(NSRange(location: 0, length: 100))
            
                let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: abc)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: cust.FontSizeText)!, range: NSMakeRange(0, abc.characters.count))
                attributedString.addAttribute(NSForegroundColorAttributeName, value:  cust.textColor, range: NSMakeRange(0, abc.characters.count))
                let moreString = NSMutableAttributedString(string: " ...")
                moreString.addAttribute(NSLinkAttributeName, value: " ...", range: NSRange(location: 0, length: 4))
                moreString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0), range: NSMakeRange(0, 3))
            
                attributedString.appendAttributedString(moreString)
                cell.txtBusinessDesc.tag = indexPath.row
                cell.txtBusinessDesc.attributedText = attributedString
            
                
                
            }else{
                
                let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: cell.txtBusinessDesc.text!)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: cust.FontSizeText)!, range: NSMakeRange(0, cell.txtBusinessDesc.text!.characters.count))
                attributedString.addAttribute(NSForegroundColorAttributeName, value:  cust.textColor, range: NSMakeRange(0, cell.txtBusinessDesc.text!.characters.count))
                cell.txtBusinessDesc.tag = indexPath.row
                cell.txtBusinessDesc.attributedText = attributedString
            }
        
        
        
        
        }  else{
        
            cell.lblBusinessName.text = businessNameArray[indexPath.row] as? String // "Company name goes here"
            //Business image
            tmpImgUrl = self.businessGalleryImageArray[indexPath.row] //self.businessLogoUrlArray[indexPath.row]
        
            if(self.businessIsFavArray[indexPath.row] == "0"){
                print("Not Favorite")
                cell.btnFavorite.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
            }else{
                print("Favorite business")
                cell.btnFavorite.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
            }
            cell.btnFavorite.tag = indexPath.row
            cell.lblDealCount.tag = indexPath.row
            cell.btnShareBusiness.tag = indexPath.row
            cell.btnViewOnMap.tag = indexPath.row
        
            if(self.businessTotalDealArray[indexPath.row] == "0"){
                cell.lblDealCount.hidden = true
            }else{
                cell.lblDealCount.hidden = false
                var dealVari : String = String()
                if(self.businessTotalDealArray[indexPath.row] == "1"){
                    dealVari = " Deal"
                }else{
                    dealVari = " Deals"
                }
                cell.lblDealCount.setTitle(self.businessTotalDealArray[indexPath.row] + dealVari, forState: UIControlState.Normal)
            }
            cell.txtBusinessDesc.text = self.businessDescArray[indexPath.row]
        
        
        
            //Check if location data is availble, then display map button
            if(businessLatArray[indexPath.row] == ""){
                cell.btnViewOnMap.hidden = true
            }else{
                cell.btnViewOnMap.hidden = false
            }

        
        
            if(cell.txtBusinessDesc.text!.utf16.count >= 100){
            let abc : String = (cell.txtBusinessDesc.text! as NSString).substringWithRange(NSRange(location: 0, length: 100))
            
            let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: abc)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)!, range: NSMakeRange(0, abc.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1.0), range: NSMakeRange(0, abc.characters.count))
            
            let moreString = NSMutableAttributedString(string: " ...")
            moreString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0), range: NSMakeRange(0, 3))
            
            attributedString.appendAttributedString(moreString)
            cell.txtBusinessDesc.tag = indexPath.row
            cell.txtBusinessDesc.attributedText = attributedString
            
            
            }else{
                let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: cell.txtBusinessDesc.text!)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: cust.FontSizeText)!, range: NSMakeRange(0, cell.txtBusinessDesc.text!.characters.count))
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1.0), range: NSMakeRange(0, cell.txtBusinessDesc.text!.characters.count))
                cell.txtBusinessDesc.tag = indexPath.row
                cell.txtBusinessDesc.attributedText = attributedString
            }
    
        
        }

        cell.imgBusinessPic.layer.cornerRadius = self.cust.RounderCornerRadious
        cell.imgBusinessPic.layer.masksToBounds = true
        
        cell.lblCuisine.text = " \(self.businessCuisineArray[indexPath.row]) "
        //Business image
        
        let ur = NSURL(string: tmpImgUrl)
        cell.imgBusinessPic.sd_setImageWithURL(ur, placeholderImage: self.delObj.businessPlaceHolderImage, options: SDWebImageOptions.RefreshCached)
        
      //  cell.imgBusinessPic.contentMode = UIViewContentMode.ScaleAspectFill
      /*  SDImageCache.sharedImageCache().queryDiskCacheForKey(tmpImgUrl) { (img:UIImage!, cacheType:SDImageCacheType) -> Void in
            if(img != nil){
                //Check image in cache
                cell.imgBusinessPic.image = img
                
            }else{
                //image not availble in cache, go to download it.
                
                Alamofire.request(.GET, tmpImgUrl).response{
                    request, response, data, error in
                    print(request)
                    
                    if(data != nil){
                        //Yeahh..! You got the image
                        let image = UIImage(data: data!)
                        SDImageCache.sharedImageCache().storeImage(image, forKey: tmpImgUrl)
                        cell.imgBusinessPic.image = image
                        
                    }else{
                        
                        cell.imgBusinessPic.image = self.delObj.businessPlaceHolderImage
                        //No image available, Display place holder
                    }
                }
                
            }
        }*/
        
        
        cell.lblDealCount.addTarget(self, action: #selector(BusinessListViewController.btnDealCountClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnViewOnMap.userInteractionEnabled = true
        cell.btnViewOnMap.addTarget(self, action: #selector(BusinessListViewController.btnViewOnMapClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.btnFavorite.addTarget(self, action: #selector(BusinessListViewController.btnFavoriteClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.btnShareBusiness.addTarget(self, action: #selector(BusinessListViewController.btnShareClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
  
    
    
    
//TODO: - called when text changes (including clear)
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        
        // The user clicked the [X] button or otherwise cleared the text.
        
        if (searchBar.text!.isEmpty){
            is_searching = false
            searchBarOutlet.performSelector(#selector(UIResponder.resignFirstResponder), withObject: nil, afterDelay: 0.1)
            self.tblBusinessList.hidden = false
            //self.messageLable.hidden = true
            self.tblBusinessList.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        }else{
            is_searching = true
            
            sortedbusinessNameArray.removeAllObjects()
            sortedDescArray.removeAllObjects()
            sortedIDArray.removeAllObjects()
            sortedNameArray.removeAllObjects()
            sortedPhoneArray.removeAllObjects()
            sortedLogoArray.removeAllObjects()
            sortedTotalDealArray.removeAllObjects()
            sortedIsFavArray.removeAllObjects()
            sortedbusinessLongArray.removeAllObjects()
            sortedbusinessLatArray.removeAllObjects()
            sortedBusinessCuisineArray.removeAllObjects()
            sortedBusinessAddressArray.removeAllObjects()
            
            for index in 0 ..< businessNameArray.count 
            {
                let currentString = businessNameArray.objectAtIndex(index) as! String
                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString) != nil{
                    sortedbusinessNameArray.addObject(currentString)
                    sortedDescArray.addObject(businessDescArray[index])
                    sortedIDArray.addObject(businessIDArray[index])
                    sortedNameArray.addObject(businessNameArray[index])
                    sortedPhoneArray.addObject(businessPhoneArray[index])
                    sortedLogoArray.addObject(businessGalleryImageArray[index])
                   // sortedLogoArray.addObject(businessLogoUrlArray[index])
                    sortedTotalDealArray.addObject(businessTotalDealArray[index])
                    sortedIsFavArray.addObject(businessIsFavArray[index])
                    sortedbusinessLatArray.addObject(businessLatArray[index])
                    sortedbusinessLongArray.addObject(businessLongArray[index])
                    sortedBusinessCuisineArray.addObject(businessCuisineArray[index])
                    sortedBusinessAddressArray.addObject(businessAddressArray[index])
                }
            }
             self.tblBusinessList.hidden = false
              self.messageLable.hidden = true
            self.tblBusinessList.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
            
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
       
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //is_searching = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // is_searching = false
        searchBar.resignFirstResponder()
    }
    
    func btnDealCountClick(sender:UIButton){
        
        let dealListVC = self.storyboard?.instantiateViewControllerWithIdentifier("idDealListViewController") as! DealListViewController
        var businessID : String = String()
        var phoneNo : String = String()
        
        if(is_searching){
            businessID =  self.sortedIDArray[sender.tag] as! String
            phoneNo = self.sortedPhoneArray[sender.tag] as! String
        }else{
            businessID =  self.businessIDArray[sender.tag]
            phoneNo = self.businessPhoneArray[sender.tag]
        }
        
        defaults.setValue(businessID, forKey: "businessID")
        defaults.synchronize()
        print("phoneNo1:\(phoneNo)")
        dealListVC.phoneNo = phoneNo
        dealListVC.businessID = businessID
        self.navigationController?.pushViewController(dealListVC, animated: true)
        
    }
    
    
    /**
     create link for google map and redirect using SFSafariViewController
     
     - parameter sender: Button Click event
     */
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
            
            let combineUrl = "https://www.google.com/maps/dir/\(newString1)/\(newDestString1)"
            
            print("combineUrl: >> \(combineUrl)")
            
           
                self.safariVC = SFSafariViewController(URL: NSURL(string: combineUrl)!)
                self.safariVC.delegate = self
                self.presentViewController(self.safariVC, animated: true, completion: nil)
            
            
            
            
        })

        
        
     
        
        
        
        
       /* var title : String = String()
        var lat : Double = Double()
        var long : Double = Double()
        if(is_searching){
            print(self.sortedIDArray[sender.tag])
            title = self.sortedNameArray[sender.tag] as! String
            lat = self.sortedbusinessLatArray[sender.tag] as! Double
            long = self.sortedbusinessLongArray[sender.tag] as! Double
            self.defaults.setValue(self.sortedIDArray[sender.tag], forKey: "viewonmapID")
            
           
        }else{
            print(self.businessIDArray[sender.tag])
            title = self.businessNameArray[sender.tag] as! String
            lat = Double(self.businessLatArray[sender.tag])!// as! Double
            long = Double(self.businessLongArray[sender.tag])! // as! Double
            self.defaults.setValue(self.businessIDArray[sender.tag], forKey: "viewonmapID")
            
        }
        //let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("idHomePageViewController") as! HomePageViewController
        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("idMapDisplayViewController") as! MapDisplayViewController
        
        mapVC.bus_title = title
        mapVC.bus_lat = lat
        mapVC.bus_long = long
        //self.presentViewController(mapVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(mapVC, animated: true)*/
        
    }
    
    func btnShareClick(sender:UIButton){
        print("btnShareClick CLick")
        
        let actionSheet = UIAlertController(title: "Let's Share a Business", message: "Select Business Sharing Method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let fbShare = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            
            self.postImage = self.view.cust_takeSnapshot()
            self.postImageOnFacebook()
            //self.delObj.displayMessage("BuzzDeal", messageText: fbMessage)
        }
        
        let whatsAppShare = UIAlertAction(title: "Share on WhatsApp", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            
            /*var wMessage : String = String()
            if(self.is_searching){
                wMessage = (self.sortedbusinessNameArray[sender.tag] as! String) + "\n" + "" + (self.sortedDescArray[sender.tag] as! String)
            }else{
                wMessage = (self.businessNameArray[sender.tag] as! String) + "\n" + "" + self.businessDescArray[sender.tag]
            }*/
           // WASWhatsAppUtil.getInstance().sendText(wMessage)
            
            //self.delObj.ShareOnWhatsApp(wMessage)
            
            
            let imgTmp = self.view.cust_takeSnapshot()
            UIImageWriteToSavedPhotosAlbum(imgTmp, nil, nil, nil)
            WASWhatsAppUtil.getInstance().sendImage(imgTmp, inView: self.view)
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        actionSheet.addAction(fbShare)
       // actionSheet.addAction(whatsAppShare)
        actionSheet.addAction(cancelButton)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)

    }
    
    //TODO: - POST to Facebook
    func postImageOnFacebook(){
        
        let photoshare : FBSDKSharePhoto = FBSDKSharePhoto()
        photoshare.image = postImage
        photoshare.userGenerated = true
        let content1 : FBSDKSharePhotoContent = FBSDKSharePhotoContent()
        content1.photos = [photoshare]
        
        let dialog : FBSDKShareDialog = FBSDKShareDialog()
        dialog.shareContent = content1
        dialog.fromViewController = self
        dialog.mode = FBSDKShareDialogMode.Automatic
        dialog.delegate = self
        dialog.show()
        
    }

    
    func PostonFacebook(fbMessage : String){
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentTitle =  "BuzzDeal App"
        content.contentDescription = fbMessage
        content.imageURL = NSURL(string:  self.delObj.baseUrl + "fbLogo.png")
        content.contentURL = NSURL(string:"http://www.buzzdeal.net")
        let dialog : FBSDKShareDialog = FBSDKShareDialog()
        dialog.shareContent = content
        dialog.fromViewController = self
        dialog.mode = FBSDKShareDialogMode.Automatic
        dialog.delegate = self
        dialog.show()
        //FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
        
        // Facebook post ends here
    }
    
    func btnFavoriteClick(sender:UIButton){
        print("btnFav CLick")
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            sender.transform = CGAffineTransformMakeScale(1.3, 1.3)
            }) { (Value:Bool) -> Void in
                UIView.animateWithDuration(0.6, animations: { () -> Void in
                    sender.transform = CGAffineTransformIdentity
                    }, completion: nil)
                
                var tmpBusID : String = String()
                if self.is_searching{
                    tmpBusID = self.sortedIDArray[sender.tag] as! String
                }else{
                    tmpBusID = self.businessIDArray[sender.tag]
                }
                
                var isFav : String = String()
                
                print("sender.tag: \(sender.tag)")
                if(self.is_searching){
                    if(self.sortedIsFavArray[sender.tag] as! String == "0"){
                        isFav = "1"
                        self.sortedIsFavArray[sender.tag] = "1"
                        sender.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
                    }else{
                        isFav = "0"
                        self.sortedIsFavArray[sender.tag] = "0"
                        sender.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
                    }
                }else{
                    if(self.businessIsFavArray[sender.tag] == "0"){
                        isFav = "1"
                        self.businessIsFavArray[sender.tag] = "1"
                        sender.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
                    }else{
                        isFav = "0"
                        self.businessIsFavArray[sender.tag] = "0"
                        sender.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
                    }
                }
               
                
                
                Alamofire.request(.POST, self.delObj.baseUrl + "buzzdealservices.php/makebusinessfav", parameters : ["businessid":tmpBusID,"userid":self.userID,"isFav":isFav]).responseJSON{
                    response in
                    
                    print(response.result.value)
                    if(response.result.isSuccess){
                        
                        let jsonOut = JSON(response.result.value!)
                        
                        if(jsonOut["status"] != "1"){
                            
                            print(jsonOut["msg"].stringValue)
                            if(isFav == "0"){
                                // Empty heart
                                sender.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
                                
                                if(self.is_searching){
                                    let arrID : String = self.sortedIDArray[sender.tag] as! String
                                    for ind in 0...self.businessIDArray.count-1{
                                        if(arrID  == self.businessIDArray[ind]){
                                            self.businessIsFavArray[ind] = "0"
                                        }
                                        
                                    }
                                }
                                // End of for loop
                                
                            }else{
                                // fill heart
                                sender.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
                                
                                if(self.is_searching){
                                    let arrID : String = self.sortedIDArray[sender.tag] as! String
                                    for ind in 0...self.businessIDArray.count-1{
                                        if(arrID  == self.businessIDArray[ind]){
                                            self.businessIsFavArray[ind] = "1"
                                        }
                                    } // End of For loop
                                }
                                
                            }
                            
                        }else{
                             print(jsonOut["msg"].stringValue)
                        }
                        
                    }else{
                        
                    }
                }
                
                
        }
        //delObj.displayMessage("BuzzDeal", messageText: "Merchant mark as Favorite")
    }
    
   /* func btnShareClick(sender : UIButton){
        print("btn share click")
         delObj.displayMessage("BuzzDeal", messageText: "Merchant mark as Favorite")
    }
    */
    

//TODO: - Button Action
        
    @IBAction func btnAllActiveDealClick(sender: AnyObject) {
        let allActDealVC = self.storyboard?.instantiateViewControllerWithIdentifier("idHomeDealViewController") as! HomeDealViewController
        self.navigationController?.pushViewController(allActDealVC, animated: true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedBusinessDetails = Dictionary<String, AnyObject>()
        if is_searching{
            selectedBusinessDetails = [//"businessName":self.sortedbusinessNameArray[indexPath.row],
                "businessID" : self.sortedIDArray[indexPath.row],
                //"businessDesc" : self.sortedDescArray[indexPath.row],
                //"businessPhone" : self.sortedPhoneArray[indexPath.row]
            ]
        }else{
            selectedBusinessDetails = [//"businessName":self.businessNameArray[indexPath.row],
                "businessID" : self.businessIDArray[indexPath.row],
               // "businessDesc" : self.businessDescArray[indexPath.row],
               // "businessPhone" : self.businessPhoneArray[indexPath.row]
            ]            
        }
        
        //store business detail in dictonary to carry over next
        defaults.setValue(selectedBusinessDetails, forKey: "selectedBusinessDetails")
        defaults.synchronize()
        let dtVC = self.storyboard?.instantiateViewControllerWithIdentifier("idBusinessDetailViewController") as! BusinessDetailViewController
        self.navigationController?.pushViewController(dtVC, animated: true)
    }
    
//TODO: - Facebook SDK ShareKit delegate methods
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("Facebook Post Completed")
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("Facebook Post fail with error \(error)")
    }
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("Facebook Post cancel")
    }

    
}
