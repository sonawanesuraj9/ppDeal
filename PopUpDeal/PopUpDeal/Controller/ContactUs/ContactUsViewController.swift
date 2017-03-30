//
//  ContactUsViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 3/10/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire


class ContactUsViewController: UIViewController,UITextViewDelegate {

//TODO: - General
    
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    var userID : String = String()
    
//TODO: - Controlls
    
    @IBOutlet weak var txtSubject: UITextField!
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var btnSendOutlet: UIButton!
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        txtMessage.layer.cornerRadius = cust.RounderCornerRadious
        txtMessage.layer.borderColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0).CGColor
        txtMessage.layer.borderWidth = 1.0
        
        initPlaceholderForTextView()
        
        //Display BusinessDetail Obtain from previous page
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.btnSendOutlet.layer.cornerRadius = cust.RounderCornerRadious
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initPlaceholderForTextView(){
        txtMessage.delegate = self
        txtMessage.text = "Message"
        txtMessage.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)

    }
  
//TODO: - Web service / API methods call
    
    func sendInformation(){
        
        cust.showLoadingCircle()
        let parameters = ["userid": userID,"subject":self.txtSubject.text!,"message":self.txtMessage.text!]
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/contactus", parameters: parameters).responseJSON{
            response in
            
            print("output\(response.result.value)")
            
            if(response.result.isSuccess){
                self.cust.hideLoadingCircle()
                // SVProgressHUD.dismiss()
                let outJSON = JSON(response.result.value!)
                if(outJSON["status"] != "1"){
                    self.cust.hideLoadingCircle()
                    
                    let dispAlert = UIAlertController(title: "BuzzDeal", message: outJSON["msg"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                    dispAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (value:UIAlertAction) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    }))
                    
                    self.presentViewController(dispAlert, animated: true, completion: nil)
                }else{
                    self.cust.hideLoadingCircle()
                    self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                    
                }
            }else{
                self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                
            }
        }
        
        
    }
    
    
//TODO: UITextViewDelegate Methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0){
            textView.text = nil
            textView.textColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1.0)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty{
            txtMessage.text = "Message"
            txtMessage.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)
        }
    }
    
//TODO: - Button Action
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func btnSendClick(sender: AnyObject) {
        if(self.txtSubject.text != "" && self.txtMessage.text != ""){
          //  txtFrom.text = nil
           // txtSubject.text = nil
            sendInformation()
            initPlaceholderForTextView()
        }else{
            delObj.displayMessage("BuzzDeal", messageText: "All Fields are mandatory")
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
