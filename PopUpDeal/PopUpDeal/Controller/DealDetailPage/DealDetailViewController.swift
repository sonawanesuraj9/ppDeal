//
//  DealDetailViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/24/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire

extension UIView {
    
    func cust_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}



class DealDetailViewController: UIViewController,FBSDKSharingDelegate {
    
//TODO: - General
    
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var userID : String = String()
    var businessID : String = String()
    var busienssName : String = String()
    var dealID : String = String()
    var is_dealAccpeted : Bool = Bool()
    var is_dealAuthenticated : Bool = Bool()
    var dealAuthcode : String = String()
    var makeCallFlag : Bool = Bool()
    var callNumber : String = String()
    var businesImage : String = String()
    var businessGallery : String = String()
    var postImage : UIImage = UIImage()
    
//TODO: - Controls
    
    
    @IBOutlet weak var btnBusinessName: UIButton!
    @IBOutlet weak var imgBusinessLogo: UIImageView!
    @IBOutlet weak var btnAcceptDealOutlet: UIButton!
    @IBOutlet weak var txtDealDescription: UITextView!
    @IBOutlet weak var lblDealName: UILabel!
    
   // @IBOutlet weak var btnPhoneNoOutlet: UIButton!
    
    @IBOutlet weak var lblEndsTitle: UILabel!
    @IBOutlet weak var lblStartTitle: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var lblDealStartTime: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblDealEndTime: UILabel!
   // @IBOutlet weak var lblPhoneNo: UILabel!
    
    
//TODO: - Let's Play
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnAcceptDealOutlet.layer.cornerRadius = cust.RounderCornerRadious
       
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        if(defaults.valueForKey("businessID") != nil){
            businessID = defaults.valueForKey("businessID") as! String
        }else{
            print("No Business Selected")
        }
        
        self.btnBusinessName.hidden = true
        
        btnAcceptDealOutlet.hidden = true
        //Defaults
        initialSetup()
        
        
        //API Call
        loadDealDetails()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.btnBusinessName.layer.cornerRadius = cust.RounderCornerRadious
        
        self.btnBusinessName.hidden = false
        //Menu Button Gradient Color
        let titleGradientColor : CAGradientLayer = CAGradientLayer()
        titleGradientColor.frame = self.btnBusinessName.bounds
        titleGradientColor.startPoint = CGPointMake(0.7, 0)
        titleGradientColor.endPoint = CGPointMake(0, 0.7)
        titleGradientColor.colors = [UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0).CGColor, UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0).CGColor]
        titleGradientColor.cornerRadius = cust.RounderCornerRadious
        self.btnBusinessName.layer.insertSublayer(titleGradientColor, atIndex: 0)
        
    }
    
    func initialSetup(){
        txtDealDescription.text = ""
        lblDealName.text = ""
        lblEndDate.text = ""
        lblStartDate.text = ""
        lblDealStartTime.text = ""
        lblDealEndTime.text = ""
        lblStartTitle.text = ""
        lblEndsTitle.text = ""
      //  btnPhoneNoOutlet.setTitle("", forState: UIControlState.Normal)
      
        txtDealDescription.textAlignment = NSTextAlignment.Left
        txtDealDescription.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0) //UIEdgeInsetsMake(-4,-8,0,0);
    }
    
    
//TODO: - Web service / API implemenation 
    
    
    func loadDealDetails(){
        
        //Activity Loader
           // self.cust.showLoadingCircle()
            
            Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/dealdetails", parameters: ["dealid":dealID,"userid":userID]).responseJSON{
                response in
                
                print(response.result)
                print("dealID:\(self.dealID), userID:\(self.userID)")
                
                if(response.result.isSuccess){
                    
                    //Hide Activity
                    //self.cust.hideLoadingCircle()
                    let outJSON = JSON(response.result.value!)
                    print("JSON \(outJSON)")
                    
                    if(outJSON["status"] != "1"){
                       
                        let tempDesc = outJSON["response"]["deal_desc"].stringValue
                        self.txtDealDescription.text = tempDesc
                        self.txtDealDescription.font = UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)
                        self.txtDealDescription.textColor = self.cust.textColor
                        
                        self.lblDealName.text = outJSON["response"]["deal_title"].stringValue
                        self.busienssName = outJSON["response"]["business_name"].stringValue
                        self.btnBusinessName.setTitle(self.busienssName, forState: UIControlState.Normal)
                        self.businessID = outJSON["response"]["businessid"].stringValue
                        self.lblStartTitle.hidden = false
                        self.lblEndsTitle.hidden = false
                        self.lblDealEndTime.text = outJSON["response"]["endtime"].stringValue
                        self.lblEndDate.text = outJSON["response"]["enddate"].stringValue
                        self.lblDealStartTime.text = outJSON["response"]["starttime"].stringValue
                        self.lblStartDate.text = outJSON["response"]["startdate"].stringValue
                        self.businessGallery = outJSON["response"]["businessgallery"].stringValue
                        
                        self.lblDealEndTime.layer.cornerRadius = self.cust.RounderCornerRadious
                        self.lblDealEndTime.clipsToBounds = true
                        self.lblDealStartTime.layer.cornerRadius = self.cust.RounderCornerRadious
                        self.lblDealStartTime.clipsToBounds = true
                        
                        self.callNumber = outJSON["response"]["busi_phone"].stringValue
                        //self.btnPhoneNoOutlet.setTitle(outJSON["response"]["busi_phone"].stringValue, forState: UIControlState.Normal)
                        self.dealAuthcode = outJSON["response"]["authcode"].stringValue
                        
                        self.businesImage = outJSON["response"]["photo"].stringValue
                        let ur = NSURL(string: self.businesImage)
                        self.imgBusinessLogo.sd_setImageWithURL(ur, placeholderImage: self.delObj.businessPlaceHolderImage, options: SDWebImageOptions.RefreshCached)
                        
                        self.imgBusinessLogo.layer.cornerRadius = self.cust.RounderCornerRadious
                        self.imgBusinessLogo.clipsToBounds = true
                        
                        if(outJSON["response"]["makecall"].stringValue == "1"){
                            self.makeCallFlag = true
                        }else{
                           self.makeCallFlag = false
                        }
                        
                        // //authenticated
                        if(outJSON["response"]["dealconfirmed"].stringValue == "Y"){
                            self.is_dealAuthenticated = true
                            self.btnAcceptDealOutlet.hidden = true
                        }else{
                            
                            if(outJSON["response"]["accpeted"].stringValue == "Y"){
                                self.is_dealAccpeted = true
                                self.btnAcceptDealOutlet.hidden = false
                                self.btnAcceptDealOutlet.setTitle("Validate Deal", forState: UIControlState.Normal)
                            }else{
                                self.is_dealAccpeted = false
                                self.btnAcceptDealOutlet.hidden = false
                                self.btnAcceptDealOutlet.setTitle("Authenticate Deal", forState: UIControlState.Normal)
                            }
                            
                        }
                        
                       
                        
                    }else{
                        
                        //if status is 0
                      //  self.cust.hideLoadingCircle()
                        self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                    }
                    
                }else{
                    //Hide Activity
                    //self.cust.hideLoadingCircle()
                    self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                }
            }
            
        
    }
    
    
    func activateDeal(){
        
        //Activity Loader
        self.cust.showLoadingCircle()
        
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/activatedeal", parameters: ["userid":userID,"dealid":dealID]).responseJSON{
            response in
            
            print(response.response)
            
            if(response.result.isSuccess){
                
                //Hide Activity
                self.cust.hideLoadingCircle()
                let outJSON = JSON(response.result.value!)
                print("JSON \(outJSON)")
                
                if(outJSON["status"] != "1"){
                 
                    let dealACT = self.storyboard?.instantiateViewControllerWithIdentifier("idDealActivatedViewController") as! DealActivatedViewController
                    dealACT.dealAuthcode =  outJSON["response"]["authcode"].stringValue
                    dealACT.makeCallFlag = self.makeCallFlag
                    dealACT.dealNumber = self.callNumber
                    dealACT.businessName = self.busienssName
                    dealACT.businessLogoURL = self.businessGallery//self.businesImage
                    dealACT.is_from_myDeal = false
                    self.navigationController?.pushViewController(dealACT, animated: true)
                    
                }else{
                    
                    //if status is 0
                    self.cust.hideLoadingCircle()
                    self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                }
                
            }else{
                //Hide Activity
                self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
            }
        }
        
        
    }
    
    
    
    
    
//TODO: - Button Action
    
    @IBAction func btnShareClick(sender: AnyObject) {
        
        let actionSheet = UIAlertController(title: "Let's Share a Deal", message: "Select Deal Sharing Method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let fbShare = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            
           //self.postImage = self.view.cust_takeSnapshot()
            let tmpImage = self.view.cust_takeSnapshot()
            self.postImage = tmpImage
            self.postImageOnFacebook()
           // UIImageWriteToSavedPhotosAlbum(self.postImage, nil, nil, nil)
          // self.PostonFacebook(fbMessage)
        }
        
        let whatsAppShare = UIAlertAction(title: "Share on WhatsApp", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
           // var wMessage : String = String()
          //  wMessage = self.lblDealName.text! + "\n" + self.txtDealDescription.text!
            
           //   WASWhatsAppUtil.getInstance().sendText(wMessage)
            self.postImage = self.view.cust_takeSnapshot()
            UIImageWriteToSavedPhotosAlbum(self.postImage, nil, nil, nil)
            WASWhatsAppUtil.getInstance().sendImage(self.postImage, inView: self.view)            
           // self.delObj.ShareOnWhatsApp(wMessage)
            //self.delObj.displayMessage("BuzzDeal", messageText: wMessage)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        actionSheet.addAction(fbShare)
        actionSheet.addAction(whatsAppShare)
        actionSheet.addAction(cancelButton)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)

    }
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnAcceptDealClick(sender: AnyObject) {
        if(!is_dealAuthenticated){
            if(!is_dealAccpeted){
                activateDeal()
            }else{
                let dealACT = self.storyboard?.instantiateViewControllerWithIdentifier("idDealActivatedViewController") as! DealActivatedViewController
                dealACT.dealAuthcode = dealAuthcode
                dealACT.makeCallFlag = self.makeCallFlag
                dealACT.dealNumber = self.callNumber
                dealACT.businessName = self.busienssName
                dealACT.businessLogoURL = self.businessGallery //self.businesImage
                dealACT.is_from_myDeal = false
                self.navigationController?.pushViewController(dealACT, animated: true)
            }
        }else{
            self.delObj.displayMessage("BuzzDeal", messageText: "You have already Authenticated deal")
        }
    }
    
    @IBAction func btnBusinessNameClick(sender: AnyObject) {
        
      let  selectedBusinessDetails = [//"businessName":self.businessNameArray[indexPath.row],
            "businessID" : businessID
            
        ]
        self.defaults.setValue(selectedBusinessDetails, forKey: "selectedBusinessDetails")
        
        let businessDetailsVC = self.storyboard?.instantiateViewControllerWithIdentifier("idBusinessDetailViewController") as! BusinessDetailViewController
        self.navigationController?.pushViewController(businessDetailsVC, animated: true)
        
        
    }
    
//TODO:- Save screenshot
    
     func saveImage(image: UIImage, withName name: String) {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        print("documentsDirectory\(documentsDirectory)")
        let data: NSData = UIImageJPEGRepresentation(image, 1.0)!
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        
        let fullPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(name)
        fileManager.createFileAtPath(fullPath.absoluteString, contents: data, attributes: nil)
        print("fullPath\(fullPath)")
    }
    
     func loadImage(name: String) -> UIImage {
        let fullPath: String = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(name).absoluteString
        let img:UIImage = UIImage(contentsOfFile: fullPath)!
        return img
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
    
    
    /*@IBAction func btnPhoneNoClick(sender: AnyObject) {
        print(self.btnPhoneNoOutlet.titleLabel?.text)
        self.delObj.initiateCallToBusiness((self.btnPhoneNoOutlet.titleLabel?.text)!)
    }*/
    
    
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
