//
//  DealActivatedViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 3/5/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire



class DealActivatedViewController: UIViewController,UITextFieldDelegate {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    var userID : String = String()
    var businessID : String = String()
    let limitLength = 6
    
    var dealAuthcode : String = String()
    var makeCallFlag : Bool = Bool()
    var dealNumber : String = String()
    var businessLogoURL : String = String()
    var businessName : String = String()
    
    var is_from_myDeal : Bool = Bool()
    
//TODO: - Controlls
    @IBOutlet weak var lblDisplayText: UILabel!
    @IBOutlet weak var imgBusinessLogo: UIImageView!
    
    @IBOutlet weak var lblBookingTItle: UILabel!
    @IBOutlet weak var txtPassCode: UITextField!
    @IBOutlet weak var btnValidateDealOutlet: UIButton!
    @IBOutlet weak var lblPasscode: UILabel!
    
    @IBOutlet weak var imgTelephone: UIImageView!
    @IBOutlet weak var btnInitiateCallOutlet: UIButton!
    
    @IBOutlet weak var lblBusinesOwnerName: UILabel!
    
    @IBOutlet weak var lblBusinessName: UILabel!
    
    
    @IBOutlet weak var lblBusinessInfo: UILabel!
    @IBOutlet weak var infoView: UIView!
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblDisplayText.text = "Show the above passcode at business location"
        lblBusinesOwnerName.text = "Please ask \(businessName) to enter their passcode here"
        lblBusinessInfo.text = "Please ask \(businessName) to enter their passcode here"
        self.lblBusinessName.text = businessName
        if makeCallFlag {
            imgTelephone.hidden = false
            lblBookingTItle.hidden = false
            self.btnInitiateCallOutlet.hidden = false
            lblBookingTItle.text = "To confirm your reservation please call the number below."
            self.btnInitiateCallOutlet.setTitle(dealNumber, forState: UIControlState.Normal)
        }else{
            imgTelephone.hidden = true
            lblBookingTItle.hidden = true
            self.btnInitiateCallOutlet.hidden = true
        }
        
        self.txtPassCode.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.btnValidateDealOutlet.layer.cornerRadius = cust.RounderCornerRadious
        self.btnValidateDealOutlet.setTitle("Deal Confirmed", forState: UIControlState.Normal)
        txtPassCode.keyboardType = UIKeyboardType.NumberPad
        
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        if(defaults.valueForKey("businessID") != nil){
            businessID = defaults.valueForKey("businessID") as! String
        }else{
            print("No Business Selected")
        }
        
        
        //Hide bottom view, if navigated from other than myDeal page.
        if(is_from_myDeal){
            infoView.hidden = true
        }else{
            infoView.hidden = false
        }
        
        //Display Business Image
        let ur = NSURL(string: businessLogoURL)
        self.imgBusinessLogo.sd_setImageWithURL(ur, placeholderImage: self.delObj.businessPlaceHolderImagesquare, options: SDWebImageOptions.RefreshCached)
        
        
        self.lblPasscode.text = dealAuthcode
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
//TODO: - UITextFieldDelegate Method Implementation
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard txtPassCode.text != nil else {return true}
        let newLenght = (txtPassCode.text?.characters.count)! + string.characters.count - range.length
        return newLenght <= limitLength
    }
    
    
//TODO: - Web service / API Implementation
    
    func validateDeal(){
        if(txtPassCode.text != ""){
       
 
        //Activity Loader
        self.cust.showLoadingCircle()
        
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/validatedeal", parameters: ["authcode":dealAuthcode,"userid":userID,"passcode":self.txtPassCode.text!]).responseJSON{
            response in
            print("dealAuthcode:\(self.dealAuthcode),userID:\(self.userID),self.txtPassCode.text:\(self.txtPassCode.text!)")
            print(response.response)
            
            if(response.result.isSuccess){
                
                //Hide Activity
                self.cust.hideLoadingCircle()
                let outJSON = JSON(response.result.value!)
                print("JSON \(outJSON)")
                
                if(outJSON["status"] != "1"){
                    
                    self.cust.hideLoadingCircle()
                    //self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                    
                    let actDealAlert = UIAlertController(title: "BuzzDeal", message: outJSON["msg"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                    actDealAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (value:UIAlertAction) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    }))
                    self.presentViewController(actDealAlert, animated: true, completion: nil)
                    
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
            delObj.displayMessage("BuzzDeal", messageText: "Please enter passcode")
        }
    }
    
    
//TODO: - Button Action

    @IBAction func btnInitiateCallClick(sender: AnyObject) {
        let confAlert = UIAlertController(title: "BuzzDeal", message: "Do you want to initiate call?", preferredStyle: UIAlertControllerStyle.Alert)
        confAlert.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.Default, handler: { (value:UIAlertAction) -> Void in
            print(self.btnInitiateCallOutlet.titleLabel?.text)
            self.delObj.initiateCallToBusiness((self.btnInitiateCallOutlet.titleLabel?.text)!)
        }))
        
        confAlert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: nil))
      self.presentViewController(confAlert, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func btnValidateDealClick(sender: AnyObject) {
        validateDeal()
    }
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
