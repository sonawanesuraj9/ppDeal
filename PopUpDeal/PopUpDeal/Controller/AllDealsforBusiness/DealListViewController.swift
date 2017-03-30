//
//  DealListViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 4/7/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire

class dealListTableViewCell : UITableViewCell{
    
    @IBOutlet weak var lblDealDescription: UILabel!
    @IBOutlet weak var btnBuzzIT: UIButton!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var btnShareDeal: UIButton!
  //  @IBOutlet weak var lblDealTime: UILabel!
    //@IBOutlet weak var lblDealDescription: UITextView!
    @IBOutlet weak var lblDealStartTime: UILabel!
    @IBOutlet weak var lblDealStartDate: UILabel!
    @IBOutlet weak var lblDealEndTime: UILabel!
    @IBOutlet weak var lblDealEndDate: UILabel!
    
    
    @IBOutlet weak var lblDealTitle: UILabel!
}

class DealListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FBSDKSharingDelegate {

//TODO: - Generals
    
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var userID : String = String()
    var businessID : String = String()
    var businessName : String = String()
    var phoneNo : String = String()
    
    var postImage : UIImage = UIImage()
    //Response data variables
    
    
    var dealIDArray : [String] = []
    var dealTitleArray : [String] = []
    var dealStartDateArray : [String] = []
    var dealEndDateArray : [String] = []
    var dealStartTimeArray : [String] = []
    var dealEndTimeArray : [String] = []
    var dealDescArray : [String] = []
    
//TODO: - Controlls
    
    
    @IBOutlet weak var tblDeals: UITableView!
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tblDeals.tableFooterView = UIView(frame: CGRectZero)
        
        //Display BusinessDetail Obtain from previous page
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        if(defaults.valueForKey("businessID") != nil){
            businessID = defaults.valueForKey("businessID") as! String
        }else{
            print("No Business Selected")
        }
        print("phoneNo:\(phoneNo)")
        loadAllDeals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
//TODO: - WebService / API Call
    
    func clearAllArray(){
        dealIDArray.removeAll(keepCapacity: false)
        dealTitleArray.removeAll(keepCapacity: false)
        dealStartTimeArray.removeAll(keepCapacity: false)
        dealEndTimeArray.removeAll(keepCapacity: false)
        dealStartDateArray.removeAll(keepCapacity: false)
        dealEndDateArray.removeAll(keepCapacity: false)
        dealDescArray.removeAll(keepCapacity: false)
       
    }
    
    func loadAllDeals(){
        
        //Activity Loader
        self.cust.showLoadingCircle()
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/deallist", parameters: ["businessid":businessID,"userid":userID]).responseJSON{
            response in
       
            print(response.result)
            self.clearAllArray()
            if(response.result.isSuccess){
                
                //Hide Activity
                self.cust.hideLoadingCircle()
                let outJSON = JSON(response.result.value!)
                print("JSON \(outJSON)")
                
                if(outJSON["status"] != "1"){
                   
                    
                      let count = outJSON["data"].array?.count
                    print("count\(count)")
                    
                    let dealCount = outJSON["data"].array?.count
                    
                    if(dealCount != 0){
                    if let dc = dealCount{
                    for index in 0...dc-1{
                    
                        if(outJSON["data"][index]["dealconfirmed"].stringValue == "N"){
                        self.dealIDArray.append(outJSON["data"][index]["dealid"].stringValue)
                        self.dealTitleArray.append(outJSON["data"][index]["deal_title"].stringValue)
                        self.dealStartDateArray.append(outJSON["data"][index]["start_date"].stringValue)
                        self.dealEndDateArray.append(outJSON["data"][index]["end_date"].stringValue)
                        self.dealStartTimeArray.append(outJSON["data"][index]["start_time"].stringValue)
                        self.dealEndTimeArray.append(outJSON["data"][index]["end_time"].stringValue)
                        self.dealDescArray.append(outJSON["data"][index]["deal_description"].stringValue)
                       // dealid
                            //
                            }
                        }
                        
                        }
                        print("dealIDArray\(self.dealIDArray)")
                      self.tblDeals.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                    }
                    
                }else{
                    
                    //if status is 0
                    self.cust.hideLoadingCircle()
                    self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                    self.tblDeals.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                }
                
            }else{
                //Hide Activity
                self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                self.tblDeals.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.None)
            }
        }
        
    }
    
//TODO: -  UITableViewDatasource Method implementation
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dealIDArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath) as! dealListTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.borderView.layer.borderWidth = 1.0
        cell.borderView.layer.borderColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.6).CGColor
        cell.borderView.layer.cornerRadius = cust.RounderCornerRadious
        
        cell.lblDealTitle.text = self.dealTitleArray[indexPath.row]
        cell.lblDealStartTime.text = self.dealStartTimeArray[indexPath.row]
        cell.lblDealStartDate.text = self.dealStartDateArray[indexPath.row]
        cell.lblDealEndDate.text = self.dealEndDateArray[indexPath.row]
        cell.lblDealEndTime.text = self.dealEndTimeArray[indexPath.row]
       
        cell.lblDealStartTime.layer.cornerRadius = cust.RounderCornerRadious
        cell.lblDealStartTime.clipsToBounds = true
        cell.lblDealEndTime.layer.cornerRadius = cust.RounderCornerRadious
        cell.lblDealEndTime.clipsToBounds = true
        
        cell.lblDealDescription.text = self.dealDescArray[indexPath.row]
        
        if(cell.lblDealDescription.text!.utf16.count >= 100){
            let abc : String = (cell.lblDealDescription.text! as NSString).substringWithRange(NSRange(location: 0, length: 100))
            
            let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: abc)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: self.cust.FontName, size: self.cust.FontSizeText)!, range: NSMakeRange(0, abc.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: cust.textColor, range: NSMakeRange(0, abc.characters.count))
            
            let moreString = NSMutableAttributedString(string: " ...")
            moreString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0), range: NSMakeRange(1, 3))
            
            attributedString.appendAttributedString(moreString)
           // cell.lblDealDescription.textColor = cust.textColor
            cell.lblDealDescription.attributedText = attributedString
            
            
        }else{
            let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: cell.lblDealDescription.text!)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: cust.FontSizeText)!, range: NSMakeRange(0, cell.lblDealDescription.text!.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value:  cust.textColor, range: NSMakeRange(0, cell.lblDealDescription.text!.characters.count))
           // cell.lblDealDescription.textColor = cust.textColor
            cell.lblDealDescription.attributedText = attributedString
        }
        
      
        cell.btnBuzzIT.layer.cornerRadius = cust.RounderCornerRadious
        cell.btnBuzzIT.tag = indexPath.row
        cell.btnBuzzIT.addTarget(self, action: #selector(DealListViewController.btnDealGetClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnShareDeal.tag = indexPath.row
        cell.btnShareDeal.addTarget(self, action: #selector(DealListViewController.btnShareDealClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let dealDTVC = self.storyboard?.instantiateViewControllerWithIdentifier("idDealDetailViewController") as! DealDetailViewController
        
        dealDTVC.dealID = self.dealIDArray[indexPath.row]
        
        defaults.setValue(businessID, forKey: "businessID")
        self.navigationController?.pushViewController(dealDTVC, animated: true)
        
        print("Deal details click")
    }
    
    
//TODO: - Button Action
    
    @IBAction func btnShareDealClick(sender: AnyObject) {
        
        let actionSheet = UIAlertController(title: "Let's Share a Deal", message: "Select Deal Sharing Method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let fbShare = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            self.postImage = self.view.cust_takeSnapshot()
            self.postImageOnFacebook()
           // self.PostonFacebook(fbMessage)
        }
        
        let whatsAppShare = UIAlertAction(title: "Share on WhatsApp", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
          // let wMessage = (self.dealTitleArray[sender.tag]) + "\n " + (self.dealDescArray[sender.tag])
            //  WASWhatsAppUtil.getInstance().sendText(wMessage)
          // self.delObj.ShareOnWhatsApp(wMessage)
            
            let imgTmp = self.view.cust_takeSnapshot()
            UIImageWriteToSavedPhotosAlbum(imgTmp, nil, nil, nil)
            WASWhatsAppUtil.getInstance().sendImage(imgTmp, inView: self.view)
          
            
          /*  let msg = wMessage
            let urlWhats = "whatsapp://send?text=\(msg)"
            if let urlString = urlWhats.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                if let whatsappURL = NSURL(string: urlString) {
                    if UIApplication.sharedApplication().canOpenURL(whatsappURL) {
                        UIApplication.sharedApplication().openURL(whatsappURL)
                    } else {
                        let alertController = UIAlertController(title: "BuzzDeal", message: "Whatsapp is not install on your device from Deal List", preferredStyle: .Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        
                        alertController.addAction(defaultAction)
                       self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
            */
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        actionSheet.addAction(fbShare)
        actionSheet.addAction(whatsAppShare)
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

    
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func btnDealGetClick(sender : UIButton){
        
        let index = sender.tag
        let dealDTVC = self.storyboard?.instantiateViewControllerWithIdentifier("idDealDetailViewController") as! DealDetailViewController
        
        dealDTVC.dealID = self.dealIDArray[index]
        
        defaults.setValue(businessID, forKey: "businessID")
        self.navigationController?.pushViewController(dealDTVC, animated: true)
        
        print("Deal details click")
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
