//
//  ForgotPasswordViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 3/7/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire



class ForgotPasswordViewController: UIViewController {

    
//TODO: - Generals
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    
    
//TODO: - Controlls
    
    @IBOutlet weak var btnSubmitOutlet: UIButton!
   // @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtEmailID: UITextField!
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.btnSubmitOutlet.layer.cornerRadius = cust.RounderCornerRadious
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
  
    
//TODO: - Web service / API implementation
    
    func callToForgotPassword(){
        if(self.txtEmailID.text != ""){
            
            if(self.cust.isValidEmail(self.txtEmailID.text!)){
         
                //Activity Loader
                self.cust.showLoadingCircle()
            
                Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/forgotpass", parameters: ["email":self.txtEmailID.text!]).responseJSON{
                    response in
                
                    print(response.result)
                
                    if(response.result.isSuccess){
                    
                        //Hide Activity
                        self.cust.hideLoadingCircle()
                        let outJSON = JSON(response.result.value!)
                        print("JSON \(outJSON)")
                    
                        if(outJSON["status"] != "1"){
                        
                        self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                        
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
                
            }else{
                self.delObj.displayMessage("BuzzDeal", messageText: "Please enter valid Email ID")
            }
            
        }else{
            self.delObj.displayMessage("BuzzDeal", messageText: "All fields are mandatory")
        }
    }
    
//TODO: - Button Action
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSubmitClick(sender: AnyObject) {
       callToForgotPassword()
        // delObj.displayMessage("BuzzDeal", messageText: "Please check your email for new password")
        
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
