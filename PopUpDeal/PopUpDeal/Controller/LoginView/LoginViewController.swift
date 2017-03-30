//
//  LoginViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/23/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Security
import CoreData
import Alamofire

class customTextFieldWithPadding : UITextField{
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 5, 5)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 5, 5)
    }
    
}


class LoginViewController: UIViewController,UITextViewDelegate {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    var returnKeyHandler : IQKeyboardReturnKeyHandler = IQKeyboardReturnKeyHandler()
  //  let myKeychainWrapper : KeychainWrapper = KeychainWrapper()
    
    let whiteConst = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
    var is_Autologin : Bool = Bool()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    
//TODO: - Controlls
    
    @IBOutlet weak var imgAppLogo: UIImageView!
    @IBOutlet weak var btnSignUpOutlet: UIButton!
    @IBOutlet weak var btnLoginOutlet: UIButton!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSavePasswordOutlet: UIButton!
    
    
    
    
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //IQKeyboardManager
       returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        
        // False the auto correction and capitalization for uitextfield
        txtUsername.autocapitalizationType = UITextAutocapitalizationType.None
        txtUsername.autocorrectionType = UITextAutocorrectionType.No
        txtUsername.spellCheckingType = UITextSpellCheckingType.No
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
       
       
       // self.txtPassword.text = "suraj"
       // self.txtUsername.text = "suraj"
       
        // SVProgressHUD.showWithStatus("Loading...")
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //Designing part here
        
        //SVProgressHUD.dismiss()
        
        animateAppLogo()
        
        //Set placeholder color here
        txtUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:whiteConst])
        txtPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:whiteConst])
        txtUsername.layer.borderWidth = 1
        txtPassword.layer.borderWidth = 1
        txtUsername.layer.borderColor = whiteConst.CGColor
        txtPassword.layer.borderColor = whiteConst.CGColor
        
        /*let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: placeholderUser)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: cust.FontName, size: 15)!, range: NSMakeRange(0, placeholderUser.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: cust.placeholderTextColor, range: NSMakeRange(0, placeholderUser.characters.count))
        self.txtUsername.attributedPlaceholder = attributedString*/
        
        //Button Corner Radious
        self.btnLoginOutlet.layer.cornerRadius = cust.RounderCornerRadious
        self.btnSignUpOutlet.layer.cornerRadius = cust.RounderCornerRadious
        self.txtUsername.layer.cornerRadius = cust.RounderCornerRadious
        self.txtPassword.layer.cornerRadius = cust.RounderCornerRadious
        
        //LogIn Button Gradient Color
        let gradientColor : CAGradientLayer = CAGradientLayer()
        gradientColor.frame = self.btnLoginOutlet.bounds
        gradientColor.startPoint = CGPointMake(0.7, 0)
        gradientColor.endPoint = CGPointMake(0, 0.7)
        gradientColor.colors = [cust.gradientTopColor.CGColor, cust.gradientBottomColor.CGColor]
        gradientColor.cornerRadius = cust.RounderCornerRadious
        self.btnLoginOutlet.layer.insertSublayer(gradientColor, atIndex: 0)
        
        //SignUp Button Gradient Color
        let signupGradientColor : CAGradientLayer = CAGradientLayer()
        signupGradientColor.frame = self.btnSignUpOutlet.bounds
        signupGradientColor.startPoint = CGPointMake(0.7, 0)
        signupGradientColor.endPoint = CGPointMake(0, 0.7)
        signupGradientColor.colors = [UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0).CGColor, UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0).CGColor]
        signupGradientColor.cornerRadius = cust.RounderCornerRadious
        self.btnSignUpOutlet.layer.insertSublayer(signupGradientColor, atIndex: 0)
        
        
        //Check if Autologin was selected
        
        if(defaults.valueForKey("is_Autologin") != nil){
            is_Autologin = defaults.boolForKey("is_Autologin")
            if is_Autologin{
                self.cust.showLoadingCircle()
              //  SVProgressHUD.showWithStatus("Loading...")
                btnSavePasswordOutlet.setImage(UIImage(named: "check_icon"), forState: UIControlState.Normal)
                self.cust.hideLoadingCircle()
                //SVProgressHUD.dismiss()
                
                let uname = defaults.valueForKey("usernameTemp") as! String
                let pwd = defaults.valueForKey("passwordTemp") as! String
                self.txtUsername.text = uname
                self.txtPassword.text = pwd
                self.doLogin(uname, pswrd: pwd)
            }else{
                is_Autologin = defaults.boolForKey("is_Autologin")
                if(defaults.valueForKey("passwordTemp") != nil){
                    self.txtUsername.text = defaults.valueForKey("usernameTemp") as? String
                    self.txtPassword.text = defaults.valueForKey("passwordTemp") as? String
                }else{
                    self.txtUsername.text = ""
                    self.txtPassword.text = ""
                }
                
                btnSavePasswordOutlet.setImage(UIImage(named: "uncheck_icon"), forState: UIControlState.Normal)
            }
        }else{
            is_Autologin = false
            defaults.setBool(is_Autologin, forKey: "is_Autologin")
        }
        
    }
    
    
    
    func animateAppLogo(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
           
            let hourVal =  CGAffineTransformMakeScale(1.1, 1.1)
            self.imgAppLogo.layer.setAffineTransform(hourVal)
           
            }) { (Value:Bool) -> Void in
                
                UIView.animateWithDuration(0.6, animations: { () -> Void in
                    self.imgAppLogo.transform = CGAffineTransformIdentity
                    }, completion: nil)
        }
    }
    
    func isDataEntered() -> Bool{
        var isData : Bool = Bool()
        if(txtUsername.text == ""){
            delObj.displayMessage("BuzzDeal", messageText: "Please enter Username")
            self.txtUsername.becomeFirstResponder()
            isData = false
        }else if(self.txtPassword.text == ""){
            delObj.displayMessage("BuzzDeal", messageText: "Please enter Password")
            self.txtPassword.becomeFirstResponder()
             isData = false
        }else{
             isData = true
        }
        return isData
    }
    
    
    func doLogin(username:String, pswrd : String){
     
        cust.showLoadingCircle()
        let parameters = ["username": username,"password":pswrd]
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/login", parameters: parameters).responseJSON{
            response in
            
            print("output\(response.result.value)")
            
            if(response.result.isSuccess){
                self.cust.hideLoadingCircle()
               // SVProgressHUD.dismiss()
                let outJSON = JSON(response.result.value!)
                if(outJSON["status"] != "1"){
                    
                  //  self.delObj.displayMessage("BuzzDeal", messageText: outJSON["data"]["photo"].stringValue)
                    
                    self.defaults.setValue(username, forKey: "usernameTemp")
                    self.defaults.setValue(pswrd, forKey: "passwordTemp")
                    //self.myKeychainWrapper.mySetObject(pswrd, forKey: kSecValueData)
                   // self.myKeychainWrapper.writeToKeychain()
                    
                    
                    //self.defaults.setValue(pswrd, forKey: "passwordTemp")
                    self.defaults.setValue(outJSON["data"]["userid"].stringValue, forKey: "appUserID")
                    self.defaults.setBool(self.is_Autologin, forKey: "is_Autologin")
                    
                    //Store user info for profile page
                    let userDetails = ["emailID":outJSON["data"]["emailid"].stringValue,
                        "fname":outJSON["data"]["fname"].stringValue,
                        "lname":outJSON["data"]["lname"].stringValue,
                        "photo":outJSON["data"]["photo"].stringValue,
                        "phone":outJSON["data"]["phone"].stringValue]
                    
                    self.defaults.setValue(userDetails, forKey: "userDetails")
                    
                    self.defaults.synchronize()
                   
                    //clear window
                    self.txtUsername.text = ""
                    self.txtPassword.text = ""
                    let containerVC = self.storyboard?.instantiateViewControllerWithIdentifier("idContainerTabBarController") as! ContainerTabBarController
                    self.navigationController?.pushViewController(containerVC, animated: true)
                    
                }else{
                    
                    self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                    
                }
            }else{
                self.cust.hideLoadingCircle()
                //SVProgressHUD.dismiss()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                
            }
        }
        
        
    }
    
    
//TODO: - Button Action
    
    @IBAction func btnSavePasswordClick(sender: AnyObject) {
        
        if is_Autologin{
            btnSavePasswordOutlet.setImage(UIImage(named: "uncheck_icon"), forState: UIControlState.Normal)
            is_Autologin = false
        }else{
            btnSavePasswordOutlet.setImage(UIImage(named: "check_icon"), forState: UIControlState.Normal)
            is_Autologin = true
        }
        
    }
    
    @IBAction func btnForgotPasswordClick(sender: AnyObject) {
        
        let FPVC = self.storyboard?.instantiateViewControllerWithIdentifier("idForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(FPVC, animated: true)
        
    }
    
    
    @IBAction func btnLoginClick(sender: AnyObject) {
       // SVProgressHUD.showWithStatus("Loading...")
        self.cust.showLoadingCircle()
        if isDataEntered(){
            
           /* defaults.setBool(is_Autologin, forKey: "is_Autologin")
            defaults.synchronize()*/
            
            self.cust.hideLoadingCircle()
             //SVProgressHUD.dismiss()
            
            self.doLogin(self.txtUsername.text!,pswrd: self.txtPassword.text!)   //Login function here
        }else{
            self.cust.hideLoadingCircle()
            //SVProgressHUD.dismiss()
            self.displayMessage("BuzzDeal", messageText: "Please enter Username and Password")
        }
    }
    
    
    @IBAction func btnSignUpClick(sender: AnyObject) {
        let suVC = self.storyboard?.instantiateViewControllerWithIdentifier("idSignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(suVC, animated: true)
    }

    
    
    
    
    
//TODO: - Common Function
    
    func displayMessage(titleString : String, messageText : String){
        let alert = UIAlertController(title: titleString, message: messageText, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    

}
