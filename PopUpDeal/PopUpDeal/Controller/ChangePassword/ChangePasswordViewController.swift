//
//  ChangePasswordViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/24/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire


class ChangePasswordViewController: UIViewController {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
   //   let myKeychainWrapper : KeychainWrapper = KeychainWrapper()
    var userID : String = String()
    
//TODO: - Controlls
    @IBOutlet weak var btnResetPasswordOutlet: UIButton!
    
    @IBOutlet weak var txtConfPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtOldPassword: UITextField!
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnResetPasswordOutlet.layer.cornerRadius = cust.RounderCornerRadious
        
        //Display BusinessDetail Obtain from previous page
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.txtOldPassword.attributedPlaceholder = NSAttributedString(string: "Old Password", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        self.txtNewPassword.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        self.txtConfPassword.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//TODO: - Webservice / API Call
    
    func changePasswordCall(){
        
        if(!checkForEmptyText()){
            //Check for Password entry
            if(checkTextSufficientComplexity(self.txtConfPassword.text!)){
                
                self.cust.showLoadingCircle()
        
                Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/changepwd", parameters : ["userid":userID,"oldpass":self.txtOldPassword.text!,"newpass":self.txtConfPassword.text!]).responseJSON{
                        response in
            
                        print(response.result.value)
            
                        if(response.result.isSuccess){
                            let outJSON = JSON(response.result.value!)
                
                            self.cust.hideLoadingCircle()
                            if(outJSON["status"] != "1"){
                    
                                if(self.defaults.valueForKey("is_Autologin") != nil){
                                    let is_Autologin = self.defaults.boolForKey("is_Autologin")
                                    if(is_Autologin){
                                         self.defaults.setValue(self.txtConfPassword.text, forKey: "passwordTemp")
                                         self.defaults.synchronize()
                                        //self.myKeychainWrapper.mySetObject(self.txtConfPassword.text, forKey: kSecValueData)
                                        //self.myKeychainWrapper.writeToKeychain()
                                        
                                    }else{
                                        
                                    }
                                }
                                
                               
                    
                                
                                
                                let alert = UIAlertController(title: "BuzzDeal", message: outJSON["msg"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                                
                                let OKbtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (value:UIAlertAction) -> Void in
                                    self.navigationController?.popViewControllerAnimated(true)
                                }
                                alert.addAction(OKbtn)
                                
                                self.presentViewController(alert, animated: true, completion: nil)
                                

                                
                    
                            }else{
                    
                                    self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                            }
                
                        }else{
                            self.cust.hideLoadingCircle()
                            self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                    }
            
                }
            }else{
                self.delObj.displayMessage("BuzzDeal", messageText: "New Password must contains 8 characters. \n One uppercase letter \n & \n One digit")
            }
        }else{
            self.delObj.displayMessage("BuzzDeal", messageText: "Please enter the details")
        }
        
    }
    
//TODO: - Common Function
    
    //Function to check password validation
    func checkTextSufficientComplexity( text : String) -> Bool{
        
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluateWithObject(text)
        print("\(capitalresult)")
        
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluateWithObject(text)
        print("\(numberresult)")
        
        
        /* let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        var texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        
        var specialresult = texttest2!.evaluateWithObject(text)
        println("\(specialresult)")*/
        
        return capitalresult && numberresult //|| specialresult
        
    }
    
    func checkForEmptyText() -> Bool{
        var is_empty : Bool = Bool()
        if(self.txtOldPassword.text == ""){
            self.delObj.displayMessage("BuzzDeal", messageText: "Please enter Old Password")
            is_empty = true
        }else if(self.txtNewPassword.text == ""){
            self.delObj.displayMessage("BuzzDeal", messageText: "Plesae enter New Password")
            is_empty = true
        }else if(self.txtConfPassword.text == ""){
            self.delObj.displayMessage("BuzzDeal", messageText: "Please enter Confirm Password")
            is_empty = true
        }else if(self.txtConfPassword.text != self.txtNewPassword.text){
            self.delObj.displayMessage("BuzzDeal", messageText: "Passwords does not match")
            is_empty = true
        }else{
            is_empty = false
        }
        
        return is_empty
    }
    
//TODO: - Button Action
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnResetPasswordClick(sender: AnyObject) {
        
        changePasswordCall()

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
