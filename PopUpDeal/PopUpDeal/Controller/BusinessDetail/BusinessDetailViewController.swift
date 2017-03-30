//
//  BusinessDetailViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/24/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SafariServices


extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}


class BusinessDetailTableViewCell : UITableViewCell{
    
//TODO: - Controlls
    
    @IBOutlet weak var lblDealTitle: UILabel!
    @IBOutlet weak var txtDealDescription: UITextView!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var btnShareDeal: UIButton!
    
    @IBOutlet weak var btnDealGet: UIButton!
}


class BusinessDetailViewController: UIViewController,CLLocationManagerDelegate,FBSDKSharingDelegate,SFSafariViewControllerDelegate {

  
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    let convert : Conversions = Conversions()
    
    
    
    var postImage : UIImage = UIImage()
    
    var totalCountOfView : Int = Int()
    var scrollViewWidth:CGFloat = CGFloat()
    var scrollViewHeight:CGFloat = CGFloat()
    var textArray : [String] = []
    
    
    var subView : UIView = UIView()
    var frame: CGRect = CGRectMake(0, 0, 0, 0)
    
    var userID : String = String()
    
    //Response data Variables
    var is_MenuViewDisplay : Bool = Bool()
    var is_favoriteBusiness : Bool = Bool()
    var businessLocation : CLLocation = CLLocation()
    
    //From previous Screen
    var phoneNo : String = String()
    var companyDesc : String = String()
    var companyName : String = String()
     var businessID : String = String()
   
    var phoneTapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
    
    var businessLat : String = String()
    var businessLong : String = String()
    
//TODO: - Controlls
    @IBOutlet weak var lblCompanyName: UILabel!
   // @IBOutlet weak var imgCompanyLogo: UIImageView!
    //@IBOutlet weak var scrollView: UIScrollView!
  //  @IBOutlet weak var contentViewScrl: UIView!
  //  @IBOutlet weak var imgLogo: UIImageView!
   
    @IBOutlet weak var imgWeb: UIImageView!
    @IBOutlet weak var btnWebsite: UIButton!
   
    @IBOutlet weak var imgBusinessLogo: UIImageView!
    @IBOutlet weak var baseViewOutlet: UIView!
    @IBOutlet weak var btnMenuOutlet: UIButton!
    @IBOutlet weak var btnDealOutlet: UIButton!
    
    @IBOutlet weak var btnPhoneNo: UIButton!
    @IBOutlet weak var btnFavOutlet: UIButton!
    @IBOutlet weak var lblSeperator: UILabel!
    @IBOutlet weak var lblPhoneNo: UILabel!
    @IBOutlet weak var lblEmailID: UILabel!
    @IBOutlet weak var txtCompanyDescription: UITextView!

    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var lblDistance: UILabel!
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtCompanyDescription.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        //Display BusinessDetail Obtain from previous page
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        
        if(defaults.valueForKey("selectedBusinessDetails") != nil){
           let businessDetail = defaults.valueForKey("selectedBusinessDetails") as! NSDictionary
          
            businessID = (businessDetail["businessID"] as? String)!
            
        }else{
           print("No Business Selected")
        }
        
        //Initially
        txtCompanyDescription.textAlignment = NSTextAlignment.Left
        txtCompanyDescription.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0)
        self.btnPhoneNo.setTitle("", forState: UIControlState.Normal)//.text = ""
        self.phoneNo = ""
        self.txtCompanyDescription.text = ""
        self.lblCompanyName.text = ""
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
       // self.cust.showLoadingCircle()
        btnDealOutlet.layer.cornerRadius = cust.RounderCornerRadious
        btnMenuOutlet.layer.cornerRadius = cust.RounderCornerRadious
        self.lblCompanyName.layer.cornerRadius = cust.RounderCornerRadious
         self.btnDealOutlet.hidden = true
        
        //Add Observer from appdelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessDetailViewController.updateUserLocation(_:)), name: "postLocationUpdate", object: nil)
        
        self.lblDistance.hidden = true
        self.imgLocation.hidden = true
        self.btnWebsite.hidden = true
        self.imgWeb.hidden = true
       
        loadBusinessDetails()
        
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
      
       
        //Menu Button Gradient Color
        let menuGradientColor : CAGradientLayer = CAGradientLayer()
        menuGradientColor.frame = self.btnMenuOutlet.bounds
        menuGradientColor.startPoint = CGPointMake(0.7, 0)
        menuGradientColor.endPoint = CGPointMake(0, 0.7)
        menuGradientColor.colors = [UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0).CGColor, UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0).CGColor]
        menuGradientColor.cornerRadius = cust.RounderCornerRadious
        self.btnMenuOutlet.layer.insertSublayer(menuGradientColor, atIndex: 0)
        
        
    }
   
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func callMe(sender:AnyObject){
         self.delObj.initiateCallToBusiness((self.btnPhoneNo.titleLabel?.text)!)
    }
    
//TODO: - WebService / API Call
    
    func loadBusinessDetails(){
        
        //Activity Loader
      //  self.cust.showLoadingCircle()
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/businessdetails", parameters: ["businessid":businessID,"userid":userID]).responseJSON{
            response in
            
            print(response.result)
            
            if(response.result.isSuccess){
                
                //Hide Activity
            //    self.cust.hideLoadingCircle()
                let outJSON = JSON(response.result.value!)
                print("JSON:: \(outJSON)")
                
                if(outJSON["status"] != "1"){
                    
                    //Check for menu availablity
                    if(outJSON["data"]["isMenu"].stringValue == "1"){
                       self.btnMenuOutlet.hidden = false
                    }else{
                        self.btnMenuOutlet.hidden = true
                        //No menu availble
                    }
                    
                    //Check for Favorite Business
                    if(outJSON["data"]["isFav"].stringValue == "1"){
                        self.btnFavOutlet.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
                        self.is_favoriteBusiness = true
                    }else{
                       self.btnFavOutlet.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
                        self.is_favoriteBusiness = false
                    }
                    //Check if deal is availble or not
                    let tmpdealcnt = outJSON["data"]["dealscount"].stringValue
                    if(tmpdealcnt == "0"){
                       self.btnDealOutlet.hidden = true
                    }else{
                        self.btnDealOutlet.hidden = false
                        if(tmpdealcnt == "1"){
                             self.btnDealOutlet.setTitle("\(tmpdealcnt) Deal Available", forState: UIControlState.Normal)
                        }else{
                            self.btnDealOutlet.setTitle("\(tmpdealcnt) Deals Available", forState: UIControlState.Normal)
                        }
                       
                    }
                    
                    let websiteVal = outJSON["data"]["website"].stringValue
                    if( websiteVal != ""){
                        self.btnWebsite.hidden = false
                        self.imgWeb.hidden = false
                        self.btnWebsite.setTitle(outJSON["data"]["website"].stringValue, forState: UIControlState.Normal)
                    }
                    self.btnPhoneNo.setTitle(outJSON["data"]["phone"].stringValue, forState: UIControlState.Normal)//.text =
                    self.phoneNo = outJSON["data"]["phone"].stringValue //self.lblPhoneNo.text!
                    self.txtCompanyDescription.text = outJSON["data"]["business_desc"].stringValue
                    self.lblCompanyName.text = outJSON["data"]["business_name"].stringValue
                    
                    
                    self.businessLat = outJSON["data"]["latitude"].stringValue
                    self.businessLong = outJSON["data"]["longitude"].stringValue
                    
                    //MARK: Google API call to calculate distance
                    self.fetchDistanceBetween()
                    
                    
                    let ur = NSURL(string: outJSON["data"]["photo"].stringValue)
                    self.imgBusinessLogo.sd_setImageWithURL(ur, placeholderImage: self.delObj.businessPlaceHolderImagesquare, options: SDWebImageOptions.RefreshCached)
                    
                    self.lblAddress.text = outJSON["data"]["address"].stringValue
                    self.imgBusinessLogo.layer.cornerRadius = self.cust.RounderCornerRadious
                    self.imgBusinessLogo.layer.masksToBounds = true
                    
                }else{
                    
                    //if status is 0
                    //self.cust.hideLoadingCircle()
                    self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                }
                
            }else{
                //Hide Activity
                //self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
            }
        }
      
    }
    
    
    //Update User location
    func updateUserLocation(notification : NSNotification){
       // calculateDistance()
    }
    
    func fetchDistanceBetween(){
        
       let currentLat = defaults.valueForKey("currentLat") as! Double
       let currentLon = defaults.valueForKey("currentLon") as! Double
        
        //https:/maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615,-73.9976592&key=AIzaSyBG3ywOviyiatBY7h7nPRsKvTMayjdyhaM
        
       // if(self.businessLat != 0){
        
            let gogoleAPIURL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(currentLat),\(currentLon)&destinations=\(self.businessLat),\(self.businessLong)&key=AIzaSyBG3ywOviyiatBY7h7nPRsKvTMayjdyhaM"
        
            Alamofire.request(.POST, gogoleAPIURL).responseJSON{
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
                      
                        let DisplayKM = String(format:"%.2f", self.convert.milesToKilometers(m))
                        
                        //set distance to label
                        self.lblDistance.text = DisplayKM + " KM"
                       
                        
                        
                        self.lblDistance.hidden = false
                        self.imgLocation.hidden = false
                        
                        
                        UIView.animateWithDuration(0.6, animations: { () -> Void in
                            self.imgLocation.transform = CGAffineTransformMakeScale(1.3, 1.3)
                        }) { (Value:Bool) -> Void in
                            UIView.animateWithDuration(0.6, animations: { () -> Void in
                                self.imgLocation.transform = CGAffineTransformIdentity
                                }, completion: nil)
                            
                        }
                        
                    }
                    
                }
                
              
                
                //
            }else{
                //Hide Activity
                //self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
            }
         }
        //}
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

    
//TODO: - Button Action
    
   @IBAction func btnMenuClick(sender: AnyObject) {
        //Display MenuViewController...
        print("MenuCardView Display:")
   // let menuVC = self.storyboard?.instantiateViewControllerWithIdentifier("idMenuScrollViewController") as! MenuScrollViewController
     let menuVC = self.storyboard?.instantiateViewControllerWithIdentifier("idMenuListingViewController") as! MenuListingViewController
    menuVC.businessID = self.businessID
    self.navigationController?.pushViewController(menuVC, animated: true)
    
    }
    
    @IBAction func btnShareClick(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Let's Share a Business", message: "Select Business Detail Sharing Method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
       let fbShare = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            
            
            self.postImage = self.view.cust_takeSnapshot()
            self.postImageOnFacebook()
            //self.PostonFacebook(fbMessage)
        }
        
        let whatsAppShare = UIAlertAction(title: "Share on WhatsApp", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            
            let imgTmp = self.view.cust_takeSnapshot()
            UIImageWriteToSavedPhotosAlbum(imgTmp, nil, nil, nil)
            WASWhatsAppUtil.getInstance().sendImage(imgTmp, inView: self.view)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        actionSheet.addAction(fbShare)
        actionSheet.addAction(whatsAppShare)
        actionSheet.addAction(cancelButton)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func btnDealClick(sender: AnyObject) {
        
        let dealListVC = self.storyboard?.instantiateViewControllerWithIdentifier("idDealListViewController") as! DealListViewController
        
        defaults.setValue(businessID, forKey: "businessID")
        defaults.synchronize()
        print("phoneNo1:\(phoneNo)")
        dealListVC.phoneNo = phoneNo
        dealListVC.businessName = lblCompanyName.text!
        dealListVC.businessID = businessID
        
        self.navigationController?.pushViewController(dealListVC, animated: true)
        
    }
    
    @IBAction func btnFavClick(sender: AnyObject) {
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            self.btnFavOutlet.transform = CGAffineTransformMakeScale(1.3, 1.3)
            }) { (Value:Bool) -> Void in
                UIView.animateWithDuration(0.6, animations: { () -> Void in
                    self.btnFavOutlet.transform = CGAffineTransformIdentity
                    }, completion: nil)
                
                
                var isFav : String = String()
                if(self.is_favoriteBusiness){
                    isFav = "0"
                    self.is_favoriteBusiness = false
                    self.btnFavOutlet.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
                }else{
                    isFav = "1"
                    self.is_favoriteBusiness = true
                    self.btnFavOutlet.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
                }
                
                
                Alamofire.request(.POST, self.delObj.baseUrl + "buzzdealservices.php/makebusinessfav", parameters : ["businessid":self.businessID,"userid":self.userID,"isFav":isFav]).responseJSON{
                    response in
                    
                    print(response.result.value)
                    if(response.result.isSuccess){
                        
                        let jsonOut = JSON(response.result.value!)
                        
                        if(jsonOut["status"] != "1"){
                            
                            print(jsonOut["msg"].stringValue)
                            if(isFav == "0"){
                                // Empty heart
                                sender.setImage(UIImage(named: "heart"), forState: UIControlState.Normal)
                            }else{
                                // fill heart
                                sender.setImage(UIImage(named: "fill_heart"), forState: UIControlState.Normal)
                            }
                            
                        }else{
                            print(jsonOut["msg"].stringValue)
                        }
                        
                    }else{
                        
                    }
                }//End Alamofire here
                
        }
    }
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnWebsiteClick(sender: AnyObject) {       
        
        let myURLString: String = (self.btnWebsite.titleLabel?.text)!
        var myURL: NSURL = NSURL()
        if myURLString.lowercaseString.hasPrefix("http://") {
            myURL = NSURL(string: myURLString)!
        }
        else {
            myURL = NSURL(string: "http://\(myURLString)")!
        }
        print("myURL:\(myURL)")
        if UIApplication.sharedApplication().canOpenURL(myURL) {
            
           // UIApplication.sharedApplication().openURL(myURL)
            if #available(iOS 9.0, *) {
               
               let safariVC = SFSafariViewController(URL: myURL)
                safariVC.delegate = self
                self.presentViewController(safariVC, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
            
        }else{
            self.delObj.displayMessage("BuzzDeal", messageText: "Invalid url")
        }
    }
   
//TODO: - SFSafariViewController Delegate method
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
