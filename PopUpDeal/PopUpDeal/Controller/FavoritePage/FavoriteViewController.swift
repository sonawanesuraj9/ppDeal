//
//  FavoriteViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/23/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import CoreLocation

class FavoriteTableViewCell : UITableViewCell{
//TODO: - Controlls
    
    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var lblCousine: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
   // @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var btnViewOnMap: UIButton!
    @IBOutlet weak var btnShareClick: UIButton!
    @IBOutlet weak var btnFavorite: UIButton!
   // @IBOutlet weak var lblDealCount: UILabel!
    
    @IBOutlet weak var lblDealCount: UIButton!
}
@available(iOS 9.0, *)
class FavoriteViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,FBSDKSharingDelegate,SFSafariViewControllerDelegate {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    //SearchBar Generals
    var is_searching : Bool = Bool()
    var businessNameArray : NSMutableArray = NSMutableArray()
    var sortedbusinessNameArray : NSMutableArray = NSMutableArray()
    
    var userID : String = String()
    
    //Reponse Array 
    var businessLatArray : [String] = []
    var businessLongArray : [String] = []
    var businessIDArray : [String] = []
    var businessPhoneArray : [String] = []
    var businessPicArray : [String] = []
    var businessDescArray : [String] = []
    var businessTotalDealArray : [String] = []
    var businessIsFavArray : [String] = []
    var businessGallaryArray : [String] = []
    var businessCuisineArray : [String] = []
    var businessAddressArray : [String] = []
    
    
    var sortedbusinessLatArray : NSMutableArray = NSMutableArray()
    var sortedbusinessLongArray : NSMutableArray = NSMutableArray()
    var sortedNameArray : NSMutableArray = NSMutableArray()
    var sortedIDArray : NSMutableArray = NSMutableArray()
    var sortedDescArray : NSMutableArray = NSMutableArray()
    var sortedPhoneArray : NSMutableArray = NSMutableArray()
    var sortedImageArray : NSMutableArray = NSMutableArray()
    var sortedLogoArray : NSMutableArray = NSMutableArray()
    var sortedTotalDealArray : NSMutableArray = NSMutableArray()
    var sortedIsFavArray : NSMutableArray = NSMutableArray()
    var sortedBusinessCuisineArray : NSMutableArray = NSMutableArray()
    var sortedBusinessAddressArray : NSMutableArray = NSMutableArray()

    
//TODO: - Controlls
    
    @IBOutlet weak var searchBarDelegate: UISearchBar!
    
    @IBOutlet weak var favoriteTable: UITableView!
    var messageLable  : UILabel = UILabel()
    var  safariVC : SFSafariViewController!

//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //SVProgressHUD.showWithStatus("Loading...")
      //  self.cust.showLoadingCircle()
       self.favoriteTable.tableFooterView = UIView(frame: CGRectZero)
        
        //Display BusinessDetail Obtain from previous page
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
     //   defaults.setValue(nil, forKey: "viewonmapID")
        
        self.favoriteTable.hidden = true
        self.messageLable.hidden = true
        displayNoBusinessMessage()
        
        loadUserFavBusiness()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
       //  self.cust.hideLoadingCircle()
       // SVProgressHUD.dismiss()
        //searchBar defaults
        searchBarDelegate.delegate = self
        searchBarDelegate.text = ""
        
        is_searching = false
        sortedbusinessNameArray = []
        resignFirstResponder()
        self.favoriteTable.reloadData()
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//TODO: - Web service / API call
    
    
    func clearAll(){
        
        self.businessPicArray.removeAll()
        self.businessDescArray.removeAll()
        self.businessNameArray.removeAllObjects()
        self.businessIDArray.removeAll()
        self.businessPhoneArray.removeAll()
        self.businessTotalDealArray.removeAll()
        self.businessIsFavArray.removeAll()
        self.businessGallaryArray.removeAll()
        self.businessLatArray.removeAll()
        self.businessLongArray.removeAll()
        self.businessCuisineArray.removeAll()
        self.businessAddressArray.removeAll()
    }
    
    
    
    func loadUserFavBusiness(){
        
      //  self.cust.showLoadingCircle()
        clearAll()
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/myfavbusiness", parameters:  ["userID":userID]).responseJSON{
            response in
            
            print(response.result)
            
            if(response.result.isSuccess){
                
                //Hide Activity
               // self.cust.hideLoadingCircle()
                
                let outJSON = JSON(response.result.value!)
                print("JSON \(outJSON)")
                
                let count = outJSON["response"].array?.count
                
                if(count != 0){
                    if let ct = count{
                        for index in 0...ct-1{
                        if(outJSON["response"][index]["flag"].stringValue != "1" || outJSON["response"][index]["flag"].stringValue != "2"){
                            
                            self.businessIDArray.insert(outJSON["response"][index]["userid"].stringValue, atIndex: index)
                            self.businessDescArray.insert(outJSON["response"][index]["business_desc"].stringValue, atIndex: index)
                            self.businessNameArray.insertObject(outJSON["response"][index]["business_name"].stringValue, atIndex: index)
                            self.businessPhoneArray.insert(outJSON["response"][index]["phone"].stringValue, atIndex: index)
                            self.businessTotalDealArray.insert(outJSON["response"][index]["dealcount"].stringValue, atIndex: index)
                            self.businessIsFavArray.insert(outJSON["response"][index]["isFav"].stringValue, atIndex:  index)
                            self.businessPicArray.insert(outJSON["response"][index]["photo"].stringValue, atIndex: index)
                            self.businessGallaryArray.insert(outJSON["response"][index]["businessgallery"].stringValue, atIndex: index)
                            self.businessLatArray.insert(outJSON["response"][index]["latitude"].stringValue, atIndex: index)
                            self.businessLongArray.insert(outJSON["response"][index]["longitude"].stringValue, atIndex: index)
                             self.businessCuisineArray.insert(outJSON["response"][index]["cuisine"].stringValue, atIndex: index)
                            self.businessAddressArray.insert(outJSON["response"][index]["address"].stringValue, atIndex: index)
                            //End of inner If
                            }else{
                                print("Business is Expired or Credit is 0")
                            }
                        
                        }//end for loop
                        
                        print("DataArray: \(self.businessNameArray)")
                    
                    }//end ct loop
                   
                    self.searchBarDelegate.hidden = false
                    self.favoriteTable.hidden = false
                    self.messageLable.hidden = true
                    self.favoriteTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                }
                if(outJSON["rowcount"].stringValue == "0"){
                    self.favoriteTable.hidden = true
                    self.messageLable.hidden = false
                }
            }else{
                //Hide Activity
                //self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
            }
        }
        
    }
    
    

    func displayNoBusinessMessage(){
        messageLable = UILabel(frame: CGRectMake(10,self.view.frame.size.height/2,self.view.frame.size.width*0.8,self.view.frame.size.height*0.5))
        messageLable.center = self.view.center
        messageLable.textAlignment = .Center
        messageLable.text = "No Favorite Business"
        messageLable.textColor = UIColor.lightGrayColor()
        messageLable.font = UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)
        self.searchBarDelegate.hidden = true
        self.view.addSubview(messageLable)
    }
    
//TODO: - UITableViewDataSource Method implementation
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if is_searching{
           
            if(sortedbusinessNameArray.count == 0){
                self.favoriteTable.hidden = true
                self.messageLable.hidden = false
            }else{
                self.favoriteTable.hidden = false
                self.messageLable.hidden = true
            }
            return sortedbusinessNameArray.count
        }else{
            
         return businessNameArray.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID") as! FavoriteTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.borderView.layer.borderWidth = 1.0
        cell.borderView.layer.borderColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.6).CGColor
        cell.borderView.layer.cornerRadius = cust.RounderCornerRadious
        
         var tmpImgUrl : String = String()
        
        if is_searching{
             cell.lblCompanyName.text = sortedbusinessNameArray[indexPath.row] as? String
            
            if(sortedTotalDealArray[indexPath.row] as! String == "0"){
                cell.lblDealCount.hidden = true
            }else{
                cell.lblDealCount.hidden = false
                var dealVar : String = String()
                if(sortedTotalDealArray[indexPath.row] as! String == "1"){
                    dealVar = " Deal"
                }else{
                    dealVar = " Deals"
                }
                cell.lblDealCount.setTitle((sortedTotalDealArray[indexPath.row] as! String) + dealVar, forState: UIControlState.Normal)
            }
            
            cell.lblCousine.text = " \(self.sortedBusinessCuisineArray[indexPath.row] as? String) "
            cell.txtDescription.text = self.sortedDescArray[indexPath.row] as? String
            if(cell.txtDescription.text!.utf16.count >= 100){
                let abc : String = (cell.txtDescription.text! as NSString).substringWithRange(NSRange(location: 0, length: 100))
                
                let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: abc)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)!, range: NSMakeRange(0, abc.characters.count))
                attributedString.addAttribute(NSForegroundColorAttributeName, value:  cust.textColor, range: NSMakeRange(0, abc.characters.count))
                
                let moreString = NSMutableAttributedString(string: " ...")
                moreString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0), range: NSMakeRange(0, 3))
                
                attributedString.appendAttributedString(moreString)
                cell.txtDescription.attributedText = attributedString
                
                
            }else{
                let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: cell.txtDescription.text!)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: cust.FontSizeText)!, range: NSMakeRange(0, cell.txtDescription.text!.characters.count))
                attributedString.addAttribute(NSForegroundColorAttributeName, value:  cust.textColor, range: NSMakeRange(0, cell.txtDescription.text!.characters.count))
                cell.txtDescription.attributedText = attributedString
            }

            
            //Check if location data is available
            if(sortedbusinessLatArray[indexPath.row] as! String == "0.0"){
                cell.btnViewOnMap.hidden = true
            }else{
                cell.btnViewOnMap.hidden = false
            }
            
            
            //Business image
            tmpImgUrl = self.sortedLogoArray[indexPath.row] as! String
            if(self.sortedIsFavArray[indexPath.row] as! String == "0"){
                print("Not Favorite")
                cell.btnFavorite.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
            }else{
                print("Favorite business")
                cell.btnFavorite.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
            }
            
            cell.lblDealCount.tag = indexPath.row
             cell.btnViewOnMap.tag = indexPath.row
            cell.btnShareClick.tag = indexPath.row
            cell.btnFavorite.tag = indexPath.row
        }else{
           
            cell.lblCompanyName.text = businessNameArray[indexPath.row] as? String // "Company name goes here"
            
            if(businessTotalDealArray[indexPath.row] == "0"){
                cell.lblDealCount.hidden = true
            }else{
                cell.lblDealCount.hidden = false
                var dealcntVar : String = String()
                if(businessTotalDealArray[indexPath.row] == "1"){
                    dealcntVar = " Deal"
                }else{
                    dealcntVar = " Deals"
                }
               cell.lblDealCount.setTitle(businessTotalDealArray[indexPath.row] + dealcntVar, forState: UIControlState.Normal)
            }
            
            cell.lblCousine.text = " \(self.businessCuisineArray[indexPath.row]) "
            
            cell.txtDescription.text = self.businessDescArray[indexPath.row]
            
            if(cell.txtDescription.text!.utf16.count >= 100){
                let abc : String = (cell.txtDescription.text! as NSString).substringWithRange(NSRange(location: 0, length: 100))
                
                let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: abc)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)!, range: NSMakeRange(0, abc.characters.count))
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1.0), range: NSMakeRange(0, abc.characters.count))
                
                let moreString = NSMutableAttributedString(string: " ...")
                moreString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0), range: NSMakeRange(0, 3))
                
                attributedString.appendAttributedString(moreString)
                cell.txtDescription.attributedText = attributedString
                
                
            }else{
                let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: cell.txtDescription.text!)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: cust.FontSizeText)!, range: NSMakeRange(0, cell.txtDescription.text!.characters.count))
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1.0), range: NSMakeRange(0, cell.txtDescription.text!.characters.count))
                cell.txtDescription.attributedText = attributedString
            }

            //Check if location data is available
            if(businessLatArray[indexPath.row] == "0.0"){
                cell.btnViewOnMap.hidden = true
            }else{
                cell.btnViewOnMap.hidden = false
            }
            
            //Business image
            tmpImgUrl = self.businessGallaryArray[indexPath.row] //self.businessPicArray[indexPath.row]
            if(self.businessIsFavArray[indexPath.row] == "0"){
                print("Not Favorite")
                cell.btnFavorite.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
            }else{
                print("Favorite business")
                cell.btnFavorite.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
            }
            
            cell.lblDealCount.tag = indexPath.row
            cell.btnViewOnMap.tag = indexPath.row
            cell.btnShareClick.tag = indexPath.row
            cell.btnFavorite.tag = indexPath.row
        }
        
        cell.imgLogo.layer.cornerRadius = self.cust.RounderCornerRadious
        cell.imgLogo.layer.masksToBounds = true
        
        
        //Business image
        
        let ur = NSURL(string: tmpImgUrl)
         cell.imgLogo.sd_setImageWithURL(ur, placeholderImage: self.delObj.businessPlaceHolderImage, options: SDWebImageOptions.RefreshCached)
        
        cell.lblDealCount.addTarget(self, action: #selector(FavoriteViewController.btnDealCountClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnViewOnMap.addTarget(self, action: #selector(FavoriteViewController.btnViewOnMapClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.btnShareClick.addTarget(self, action: #selector(FavoriteViewController.btnShareClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnFavorite.addTarget(self, action: #selector(FavoriteViewController.btnFavoriteClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(indexPath.row)
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
    
    
    
    
//TODO: - UISearchBarDelegate Method
    
    // called when text changes (including clear)
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        
        // The user clicked the [X] button or otherwise cleared the text.
        
        if (searchBar.text!.isEmpty){
            is_searching = false
            searchBarDelegate.performSelector(#selector(UIResponder.resignFirstResponder), withObject: nil, afterDelay: 0.1)
            self.favoriteTable.hidden = false
            self.messageLable.hidden = true
           self.favoriteTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
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
            sortedbusinessLatArray.removeAllObjects()
            sortedbusinessLongArray.removeAllObjects()
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
                    // sortedLogoArray.addObject(businessPicArray[index])
                    sortedLogoArray.addObject(businessGallaryArray[index])
                    sortedTotalDealArray.addObject(businessTotalDealArray[index])
                    sortedIsFavArray.addObject(businessIsFavArray[index])
                    sortedbusinessLatArray.addObject(businessLatArray[index])
                    sortedbusinessLongArray.addObject(businessLongArray[index])
                    sortedBusinessCuisineArray.addObject(businessCuisineArray[index])
                    sortedBusinessAddressArray.addObject(businessAddressArray[index])
                }
            }
            self.favoriteTable.hidden = false
            self.messageLable.hidden = true
             self.favoriteTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
            
        }
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.favoriteTable.hidden = false
        self.messageLable.hidden = true
         self.favoriteTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //is_searching = false
        searchBar.resignFirstResponder()
        self.favoriteTable.hidden = false
        self.messageLable.hidden = true
         self.favoriteTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
       // is_searching = false
        searchBar.resignFirstResponder()
        self.favoriteTable.hidden = false
        self.messageLable.hidden = true
         self.favoriteTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
    }
    
    
    /**
     Creat URL and navigate to google map using SFSafariviewcontroller
     
     - parameter sender: UIButton
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
            
            // if(UIApplication.sharedApplication().canOpenURL(NSURL(string: combineUrl)){
            
            self.safariVC = SFSafariViewController(URL: NSURL(string: combineUrl)!)
            self.safariVC.delegate = self
            self.presentViewController(self.safariVC, animated: true, completion: nil)
            
            // }
            
            
            
            
            
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
        
        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("idMapDisplayViewController") as! MapDisplayViewController
        
        mapVC.bus_title = title
        mapVC.bus_lat = lat
        mapVC.bus_long = long
        self.navigationController?.pushViewController(mapVC, animated: true)
       */
       
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
    
    func btnShareClick(sender:UIButton){
        print("btnShareClick")
        let actionSheet = UIAlertController(title: "Let's Share a Business", message: "Select Business Sharing Method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let fbShare = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            
            var fbMessage : String = String()
            if(self.is_searching){
                fbMessage =  (self.sortedbusinessNameArray[sender.tag] as! String) + "\n" + (self.sortedDescArray[sender.tag] as! String)
            }else{
                fbMessage = (self.businessNameArray[sender.tag] as! String) + "\n" + self.businessDescArray[sender.tag]
            }
            self.PostonFacebook(fbMessage)
            //self.delObj.displayMessage("BuzzDeal", messageText: fbMessage)
        }
        
        let whatsAppShare = UIAlertAction(title: "Share on WhatsApp", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            
            var wMessage : String = String()
            if(self.is_searching){
                wMessage = (self.sortedbusinessNameArray[sender.tag] as! String) + "\n" + (self.sortedDescArray[sender.tag] as! String)
            }else{
                wMessage = (self.businessNameArray[sender.tag] as! String) + "\n" + self.businessDescArray[sender.tag]
            }
              WASWhatsAppUtil.getInstance().sendText(wMessage)
             //self.delObj.ShareOnWhatsApp(wMessage)
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        actionSheet.addAction(fbShare)
       // actionSheet.addAction(whatsAppShare)
        actionSheet.addAction(cancelButton)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
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
                            
                            if(self.is_searching){
                                print(self.businessIDArray)
                                for ind in 0...self.businessIDArray.count-1{
                                    if(self.businessIDArray[ind] == tmpBusID){
                                        
                                        //Remove value from main Array
                                        
                                        self.businessPicArray.removeAtIndex(ind)
                                        self.businessDescArray.removeAtIndex(ind)
                                        self.businessNameArray.removeObjectAtIndex(ind)
                                        self.businessIDArray.removeAtIndex(ind)
                                        self.businessPhoneArray.removeAtIndex(ind)
                                        self.businessTotalDealArray.removeAtIndex(ind)
                                        self.businessIsFavArray.removeAtIndex(ind)
                                        
                                        //Remove value from sorted array too
                                        
                                    self.sortedbusinessNameArray.removeObjectAtIndex(sender.tag)
                                    self.sortedDescArray.removeObjectAtIndex(sender.tag)
                                    self.sortedIDArray.removeObjectAtIndex(sender.tag)
                                    self.sortedNameArray.removeObjectAtIndex(sender.tag)
                                self.sortedPhoneArray.removeObjectAtIndex(sender.tag)
                                    self.sortedLogoArray.removeObjectAtIndex(sender.tag)
                                self.sortedTotalDealArray.removeObjectAtIndex(sender.tag)
                                self.sortedIsFavArray.removeObjectAtIndex(sender.tag)
                                        
                                        break
                                    }
                                }
                                
                            }else{
                                
                                self.businessPicArray.removeAtIndex(sender.tag)
                                self.businessDescArray.removeAtIndex(sender.tag)
                                self.businessNameArray.removeObjectAtIndex(sender.tag)
                                self.businessIDArray.removeAtIndex(sender.tag)
                                self.businessPhoneArray.removeAtIndex(sender.tag)
                                self.businessTotalDealArray.removeAtIndex(sender.tag)
                                self.businessIsFavArray.removeAtIndex(sender.tag)

                            }
                            
                            
                            if(isFav == "0"){
                                // Empty heart
                                sender.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
                            }else{
                                // fill heart
                                sender.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
                            }
                            self.favoriteTable.hidden = false
                            self.messageLable.hidden = true
                             self.favoriteTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                            
                        }else{
                            print(jsonOut["msg"].stringValue)
                        }
                        
                    }else{
                        
                    }
                }
                
                
        }
      //  delObj.displayMessage("BuzzDeal", messageText: "Merchant mark as Favorite")
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
