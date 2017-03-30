//
//  ProfileViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/23/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Darwin


import Alamofire


class ProfileViewController: UIViewController {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    let logVC : LoginViewController = LoginViewController()
    var userID : String = String()
    
//TODO: - Controlls
    
    @IBOutlet weak var btnSignOutOutlet: UIButton!
    @IBOutlet weak var btnChangePasswordOutlet: UIButton!
    @IBOutlet weak var imgProfilePic: UIImageView!
    
    
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblEmailID: UILabel!
    
    @IBOutlet weak var btnContactUsOutlet: UIButton!
    @IBOutlet weak var lblPhoneNo: UILabel!
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnChangePasswordOutlet.layer.cornerRadius = cust.RounderCornerRadious
        btnSignOutOutlet.layer.cornerRadius = cust.RounderCornerRadious
        btnContactUsOutlet.layer.cornerRadius = cust.RounderCornerRadious
        
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.roundedImageView()
        var profURL : String = String()
        
        if(defaults.valueForKey("userDetails") != nil){
            let userDetails = defaults.valueForKey("userDetails") as! NSDictionary
            lblEmailID.text = userDetails["emailID"] as? String
            let fname  = userDetails["fname"] as? String
            let lname = userDetails["lname"] as? String
            lblFirstName.text = fname! + " " + lname!
            lblPhoneNo.text = userDetails["phone"] as? String
            
            //profURL = NSURL(string: "htt://supraint.com/works/buzz-deal/mobwebservice/ios/p1_1459772124.png")!
            
            profURL = (userDetails["photo"] as? String)!
        }
    

        if(profURL != ""){
            
        
        SDImageCache.sharedImageCache().queryDiskCacheForKey(profURL) { ( img:UIImage!, cacheType:SDImageCacheType) -> Void in
            if(img != nil){
                
              //  self.imgProfilePic.image = self.rotateImageToActual(img)
               self.imgProfilePic.image = self.cust.rotateCameraImageToProperOrientation(img,maxResolution: 360)
            }else{
                //self.cust.showLoadingCircle()
                //SVProgressHUD.showWithStatus("Loading...")
                Alamofire.request(.GET, profURL)
                    .response { request, response, data, error in
                        print(request)
                        print(response)
                        print(data)
                        print(error)
                        
                        if(data != nil){
                           //  self.cust.hideLoadingCircle()
                           // SVProgressHUD.dismiss()
                            let image = UIImage(data: data! )
                            SDImageCache.sharedImageCache().storeImage(image, forKey: profURL)
                            self.imgProfilePic.image = self.cust.rotateCameraImageToProperOrientation(image!,maxResolution: 360)
                          //  self.imgProfilePic.image = self.rotateImageToActual(image!)
                            
                        }else{
                           //  self.cust.hideLoadingCircle()
                           
                            //Display placeholder
                            self.imgProfilePic.image = self.delObj.userPlaceHolderImage
                        }
                }
            }
        }
        }else{
            self.imgProfilePic.image = self.delObj.userPlaceHolderImage
        }
        
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
    
//TODO: - Common Methods
    
    func roundedImageView(){
        self.imgProfilePic.layer.cornerRadius = cust.RounderCornerRadious //self.imgProfilePic.frame.size.width/2
       // self.imgProfilePic.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2));
        self.imgProfilePic.clipsToBounds = true
    }
    
    
//TODO: - Button Action
    
    @IBAction func btnRulesOfUseClick(sender: AnyObject) {
        let termVC = self.storyboard?.instantiateViewControllerWithIdentifier("idTermsAndConditionViewController") as! TermsAndConditionViewController
        termVC.status = "1"
        self.navigationController?.pushViewController(termVC, animated: true)
    }
    @IBAction func btnTermsClick(sender: AnyObject) {
        
        let termVC = self.storyboard?.instantiateViewControllerWithIdentifier("idTermsAndConditionViewController") as! TermsAndConditionViewController
         termVC.status = "2"
        self.navigationController?.pushViewController(termVC, animated: true)
    }
    @IBAction func btnRulesClick(sender: AnyObject) {
        let termVC = self.storyboard?.instantiateViewControllerWithIdentifier("idTermsAndConditionViewController") as! TermsAndConditionViewController
        termVC.status = "3"
        self.navigationController?.pushViewController(termVC, animated: true)
    }
   
    @IBAction func btnContactUsClick(sender: AnyObject) {
        let contactVC = self.storyboard?.instantiateViewControllerWithIdentifier("idContactUsViewController") as! ContactUsViewController
        self.navigationController?.pushViewController(contactVC, animated: true)
        
    }
    @IBAction func btnEditProfileClick(sender: AnyObject) {
        
        let editVC = self.storyboard?.instantiateViewControllerWithIdentifier("idEditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(editVC, animated: true)
        
        
    }
    @IBAction func btnChangePassword(sender: AnyObject) {
        let changePwVC = self.storyboard?.instantiateViewControllerWithIdentifier("idChangePasswordViewController") as! ChangePasswordViewController
        self.navigationController?.pushViewController(changePwVC, animated: true)
    }
    
    @IBAction func btnSignOut(sender: AnyObject) {
       //Pop to root view controller.
        
        let confAlert = UIAlertController(title: "BuzzDeal", message: "Do you really want to Sign Out?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let fbShare = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (value:UIAlertAction) -> Void in
            
            self.updateDeviceToken()
        }
        
        let cancelButton = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        
        confAlert.addAction(fbShare)
        confAlert.addAction(cancelButton)
        
        self.presentViewController(confAlert, animated: true, completion: nil)
        
       
    }

//TODO: - Update Device Token API / Webservice
    func updateDeviceToken(){
        SVProgressHUD.showWithStatus("Please wait...")
        Alamofire.request(.POST, self.delObj.baseUrl + "buzzdealservices.php/updatetoken", parameters : ["userid":self.userID,"devicetoken":""]).responseJSON{
            response in
            
            print(response.result.value)
            
            if(response.result.isSuccess){
                print("Device token updated")
                SVProgressHUD.dismiss()
                //Remove all Cached Images
                self.delObj.imageCache.removeAllObjects()
                
                self.defaults.setBool(false, forKey: "is_Autologin")
                self.defaults.synchronize()
               /* if(self.defaults.valueForKey("is_Autologin") != nil){
                   let is_Autologin = self.defaults.boolForKey("is_Autologin")
                    if(is_Autologin){
                         self.defaults.setValue(nil, forKey: "passwordTemp")
                       // self.logVC.myKeychainWrapper.resetKeychainItem()
                    }else{
                        
                    }
                }*/
                self.navigationController?.popToRootViewControllerAnimated(true)
                
            }else{
                SVProgressHUD.dismiss()
                print("Device token updation failed")
                self.delObj.displayMessage("BuzzDeal", messageText: "Unable to logut, please try later")
            }
        }
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
