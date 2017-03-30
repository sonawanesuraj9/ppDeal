//
//  MyDealsViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/23/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire


class MyDealTableViewCell : UITableViewCell{
    
//TODO: - Controlls
    
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var btnViewOnMap: UIButton!
   // @IBOutlet weak var btnShareDeal: UIButton!
   // @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblPasscode: UILabel!
//@IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblCompanyName: UILabel!
}

class MyDealsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FBSDKSharingDelegate {

    
//TODO: - General
    
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    var userID : String = String()
    var postImage : UIImage = UIImage()
    
    //Response Array 
    var dealAuthCodeArray : [String] = []
    var dealAuthStatusArray : [String] = []
    var businessIDArray : [String] = []
    var dealDescArray : [String] = []
    var dealIdArray : [String] = []
    var dealTitleArray : [String] = []
    var dealEndDateArray : [String] = []
    var dealStartDateArray : [String] = []
    var dealEndTimeArray : [String] = []
    var dealStartTimeArray : [String] = []
    var businessLogoURLArray : [String] = []
    var makeCallArray : [String] = []
    var callNumberArray: [String] = []
    var businessGalleryArray : [String] = []
    var businessNameArray : [String] = []
    
    
//TODO: - Controlls
    
    @IBOutlet weak var dealTable: UITableView!
     var messageLable  : UILabel = UILabel()
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.dealTable.tableFooterView = UIView(frame: CGRectZero)
       
       // SVProgressHUD.showWithStatus("Loading...")
        
        
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        loadAllBusiness()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//TODO: - WebService / API call
    
    func clearAllArray(){
        dealAuthCodeArray.removeAll(keepCapacity: false)
        dealAuthStatusArray.removeAll(keepCapacity: false)
         businessIDArray.removeAll(keepCapacity: false)
        dealDescArray.removeAll(keepCapacity: false)
         dealIdArray.removeAll(keepCapacity: false)
         dealTitleArray.removeAll(keepCapacity: false)
         dealEndTimeArray.removeAll(keepCapacity: false)
         dealStartTimeArray.removeAll(keepCapacity: false)
        businessLogoURLArray.removeAll(keepCapacity: false)
        makeCallArray.removeAll(keepCapacity: false)
        callNumberArray.removeAll(keepCapacity: false)
        businessGalleryArray.removeAll(keepCapacity: false)
        businessNameArray.removeAll(keepCapacity: false)
        // self.dealTable.reloadData()
        //self.dealTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func loadAllBusiness(){
        //self.cust.showLoadingCircle()
        //SVProgressHUD.showWithStatus("Loading...")
        
        Alamofire.request(.POST,delObj.baseUrl + "buzzdealservices.php/mydeals",parameters: ["userid": userID]).responseJSON{
            response in
            print(response.result.value)
            
            if(response.result.isSuccess){
                let jsonOut = JSON(response.result.value!)
                
                if(jsonOut["status"] != "1"){
                    //SVProgressHUD.dismiss()
                 //   self.cust.hideLoadingCircle()
                    
                    let count = jsonOut["response"].array?.count
                    
                    if(count != 0){
                        
                        //clear all data before loading new one
                        self.clearAllArray()
                        
                        
                        if let ct = count{
                            for index in 0...ct-1{
                                
                                self.dealAuthCodeArray.insert(jsonOut["response"][index]["authenticatecode"].stringValue, atIndex: index)
                                self.dealAuthStatusArray.insert(jsonOut["response"][index]["authenticated_status"].stringValue, atIndex: index)
                                self.businessIDArray.insert(jsonOut["response"][index]["businessid"].stringValue, atIndex: index)
                               self.businessNameArray.insert(jsonOut["response"][index]["business_name"].stringValue, atIndex: index)
                                self.dealDescArray.insert(jsonOut["response"][index]["deal_description"].stringValue, atIndex: index) //
                                self.dealIdArray.insert(jsonOut["response"][index]["deal_id"].stringValue, atIndex: index)
                                self.dealTitleArray.insert(jsonOut["response"][index]["deal_title"].stringValue, atIndex: index)
                                self.dealEndTimeArray.insert(jsonOut["response"][index]["end_time"].stringValue, atIndex:  index)
                                self.dealStartTimeArray.insert(jsonOut["response"][index]["start_time"].stringValue, atIndex:  index)
                                self.dealEndDateArray.insert(jsonOut["response"][index]["end_date"].stringValue, atIndex:  index)
                                self.dealStartDateArray.insert(jsonOut["response"][index]["start_date"].stringValue, atIndex:  index)
                                self.businessLogoURLArray.insert(jsonOut["response"][index]["photo"].stringValue, atIndex: index)
                                self.makeCallArray.insert(jsonOut["response"][index]["makecall"].stringValue, atIndex: index)
                                self.callNumberArray.insert(jsonOut["response"][index]["phone"].stringValue, atIndex: index)
                                self.businessGalleryArray.insert(jsonOut["response"][index]["businessgallery"].stringValue, atIndex: index)
                                
                            }//end for loop
                            
                            print("dealAuthStatusArray: \(self.dealAuthStatusArray)")
                        }//end ct loop
                     
                       self.messageLable.removeFromSuperview()
                        self.dealTable.hidden = false
                       // self.dealTable.reloadData()
                        self.dealTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                    }
                    if(jsonOut["dealcount"].stringValue == "0"){
                       self.displayNoBusinessMessage()
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
        messageLable.text = "You have not accepted any deal"
        messageLable.textColor = UIColor.lightGrayColor()
        messageLable.font = UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)
        self.dealTable.hidden = true
        self.view.addSubview(messageLable)
    }
    
    
    
    
    
//TODO: - UITableViewDatasource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dealIdArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath) as! MyDealTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.borderView.layer.borderWidth = 1.0
        cell.borderView.layer.borderColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.6).CGColor
        cell.borderView.layer.cornerRadius = cust.RounderCornerRadious
        
        cell.lblCompanyName.text = self.dealTitleArray[indexPath.row]
        cell.lblPasscode.text = self.dealAuthCodeArray[indexPath.row]
        
        cell.txtDescription.text = dealDescArray[indexPath.row]
        
         cell.btnViewOnMap.tag = indexPath.row
        cell.btnViewOnMap.addTarget(self, action: #selector(MyDealsViewController.btnViewOnMapClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        if(cell.txtDescription.text!.utf16.count >= 100){
            let abc : String = (cell.txtDescription.text! as NSString).substringWithRange(NSRange(location: 0, length: 100))
            
            let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: abc)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)!, range: NSMakeRange(0, abc.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: cust.textColor, range: NSMakeRange(0, abc.characters.count))
            
            let moreString = NSMutableAttributedString(string: " ...")
            moreString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0), range: NSMakeRange(0, 3))
            
            attributedString.appendAttributedString(moreString)
            cell.txtDescription.attributedText = attributedString
            
            
        }else{
            let abc : String = dealDescArray[indexPath.row]
            let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: abc)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)!, range: NSMakeRange(0, abc.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: cust.textColor, range: NSMakeRange(0, abc.characters.count))
            cell.txtDescription.attributedText = attributedString
        }

        
       // var tmpImgUrl : String = String()
      //  tmpImgUrl = self.businessLogoUrlArray[indexPath.row]
        
        //Business image
        /*SDImageCache.sharedImageCache().queryDiskCacheForKey(tmpImgUrl) { (img:UIImage!, cacheType:SDImageCacheType) -> Void in
            if(img != nil){
                //Check image in cache
               cell.imgLogo.image = img
                
            }else{
                //image not availble in cache, go to download it.
                
                Alamofire.request(.GET, tmpImgUrl).response{
                    request, response, data, error in
                    print(request)
                    // print(response)
                    //  print(data)
                    // print(error)
                    
                    if(data != nil){
                        //Yeahh..! You got the image
                        let image = UIImage(data: data!)
                        SDImageCache.sharedImageCache().storeImage(image, forKey: tmpImgUrl)
                        cell.imgLogo.image = image
                        
                    }else{
                        
                        cell.imgLogo.image = self.delObj.businessPlaceHolderImage
                        //No image available, Display place holder
                    }
                }
                
            }
        }*/
        

       
        //cell.btnShareDeal.addTarget(self, action: #selector(MyDealsViewController.btnShareDealClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(dealAuthStatusArray[indexPath.row] == "N"){
            
            //Navigate to passcode screen
            let dealDTVC = self.storyboard?.instantiateViewControllerWithIdentifier("idDealActivatedViewController") as! DealActivatedViewController
            
            
            dealDTVC.dealAuthcode = self.dealAuthCodeArray[indexPath.row]
            var callFlag : Bool = Bool()
            if(self.makeCallArray[indexPath.row] == "1"){
                callFlag = true
            }else{
                callFlag = false
            }
            dealDTVC.makeCallFlag = callFlag
            dealDTVC.businessName = self.businessNameArray[indexPath.row]
            dealDTVC.dealNumber = self.callNumberArray[indexPath.row]
            dealDTVC.businessLogoURL = self.businessGalleryArray[indexPath.row]//self.businessLogoURLArray[indexPath.row]
            dealDTVC.is_from_myDeal = true
            defaults.setValue(self.businessIDArray[indexPath.row], forKey: "businessID")
            self.navigationController?.pushViewController(dealDTVC, animated: true)
            
        }else {
            
            // Navigate to Deal Details
            
             self.delObj.displayMessage("BuzzDeal", messageText: "You have already validated deal")
            
            /*let dealDTVC = self.storyboard?.instantiateViewControllerWithIdentifier("idDealDetailViewController") as! DealDetailViewController
            
            dealDTVC.dealID = self.dealIdArray[indexPath.row]
            defaults.setValue(self.businessIDArray[indexPath.row], forKey: "businessID")
            
            self.navigationController?.pushViewController(dealDTVC, animated: true)*/
        }
        
    }
    
    
//TODO: - Button Action
    
    func btnShareDealClick(sender:UIButton){
        print("btnFav CLick")
        
        let actionSheet = UIAlertController(title: "Let's Share a Deal", message: "Select Deal Sharing Method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
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

    func btnViewOnMapClick(sender:UIButton){
      
        print(self.businessIDArray[sender.tag])
        self.defaults.setValue(self.businessIDArray[sender.tag], forKey: "viewonmapID")
        
        let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("idHomePageViewController") as! HomePageViewController
        self.navigationController?.pushViewController(mapVC, animated: true)

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
        content.imageURL = NSURL(string: self.delObj.baseUrl + "fbLogo.png")
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
