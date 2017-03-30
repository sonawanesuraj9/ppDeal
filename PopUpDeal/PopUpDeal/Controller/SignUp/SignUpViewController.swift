//
//  SignUpViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/23/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Security
import CoreData
import Alamofire


extension UIImage {
    var highestQualityJPEGNSData:NSData { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData:NSData    { return UIImageJPEGRepresentation(self, 0.75)!}
    var mediumQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData:NSData     { return UIImageJPEGRepresentation(self, 0.25)!}
    var lowestQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.0)! }
}



class SignUpViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    let logVC : LoginViewController = LoginViewController()
    let myKeychainWrapper : KeychainWrapper = KeychainWrapper()
    var returnKeyHandler : IQKeyboardReturnKeyHandler = IQKeyboardReturnKeyHandler()
    
     let imgPicker : UIImagePickerController = UIImagePickerController()
    var is_termsClick : Bool = Bool()
    var base64String : String = String()
    var base64Data : NSData = NSData()
    var is_imageUpload : Bool = Bool()
    
    let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
    
//TODO: - Controlls
    
    @IBOutlet weak var btnSaveOutlet: UIButton!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmailID: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
   // @IBOutlet weak var txtPhoneNo: UITextField!
    
    @IBOutlet weak var btnCheckIconOutlet: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    
    
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.roundedImageView()
        
        //IQKeyboardReturnKeyHandler Method
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        
        // False the auto correction and capitalization for uitextfield
        txtUserName.autocapitalizationType = UITextAutocapitalizationType.None
        txtUserName.autocorrectionType = UITextAutocorrectionType.No
        txtUserName.spellCheckingType = UITextSpellCheckingType.No
        
        //imagetap
        self.imgProfile.userInteractionEnabled = true
        tapGesture.addTarget(self, action: #selector(SignUpViewController.profileImageHasBeenTapped))
        self.imgProfile.addGestureRecognizer(tapGesture)
        
        
        is_termsClick = false
    }
    
    
    
    func profileImageHasBeenTapped(){
        print("image tapped")
        self.askToChangeImage()
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        
        
        
        //Button Properties
        btnSaveOutlet.layer.cornerRadius = cust.RounderCornerRadious
       
        self.txtFirstName.layer.cornerRadius = cust.RounderCornerRadious
        self.txtLastName.layer.cornerRadius = cust.RounderCornerRadious
        self.txtConfirmPassword.layer.cornerRadius = cust.RounderCornerRadious
        self.txtEmailID.layer.cornerRadius = cust.RounderCornerRadious
        self.txtPassword.layer.cornerRadius = cust.RounderCornerRadious
       // self.txtPhoneNo.layer.cornerRadius = cust.RounderCornerRadious
        self.txtUserName.layer.cornerRadius = cust.RounderCornerRadious
        
        //Initial Setup
        txtFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        txtLastName.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        txtConfirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        txtEmailID.attributedPlaceholder = NSAttributedString(string: "Email ID", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        txtPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
       // txtPhoneNo.attributedPlaceholder = NSAttributedString(string: "Phone No", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        txtUserName.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        txtEmailID.keyboardType = UIKeyboardType.EmailAddress
       // txtPhoneNo.keyboardType = UIKeyboardType.NumberPad
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
       
    }
    
    
    //Function to check all fields are mandatory
    func isDataEntered() -> Bool{
        
        var isEntered : Bool = Bool()
        if(txtUserName.text == ""){
             delObj.displayMessage("BuzzDeal", messageText: "Please enter Username")
            txtUserName.becomeFirstResponder()
            isEntered = false
        }else if(txtPassword.text == ""){
             delObj.displayMessage("BuzzDeal", messageText: "Please enter Password")
            txtPassword.becomeFirstResponder()
            isEntered = false
        }else if(txtConfirmPassword.text == ""){
             delObj.displayMessage("BuzzDeal", messageText: "Please enter Confirm Password")
            txtConfirmPassword.becomeFirstResponder()
            isEntered = false
        }else if(txtConfirmPassword.text != txtPassword.text){
             delObj.displayMessage("BuzzDeal", messageText: "Confirm password does not match")
            txtConfirmPassword.becomeFirstResponder()
            isEntered = false
        }else if(txtConfirmPassword.text?.characters.count < 8){
            delObj.displayMessage("BuzzDeal", messageText: "Password must contains 8 characters. \n One uppercase letter \n & \n One digit")
            txtConfirmPassword.becomeFirstResponder()
            isEntered = false
        }else if(txtFirstName.text == ""){
            delObj.displayMessage("BuzzDeal", messageText: "Please enter First Name")
            txtFirstName.becomeFirstResponder()
            isEntered = false
        }else if(txtLastName.text == ""){
            delObj.displayMessage("BuzzDeal", messageText: "Please enter Last Name")
            txtLastName.becomeFirstResponder()
            isEntered = false
        }else  if(txtEmailID.text == ""){
             delObj.displayMessage("BuzzDeal", messageText: "Please enter EmailID")
            txtEmailID.becomeFirstResponder()
            isEntered = false
        }else if(!(cust.isValidEmail(txtEmailID.text!))){
            delObj.displayMessage("BuzzDeal", messageText: "Please enter Valid EmailID")
            txtEmailID.becomeFirstResponder()
            isEntered = false
        }/*else if(txtPhoneNo.text == ""){
             delObj.displayMessage("BuzzDeal", messageText: "Please enter Phone Number")
            txtPhoneNo.becomeFirstResponder()
            isEntered = false
        }*/else{
            isEntered = true
        }
        return isEntered
        
    }

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
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
//TODO: - Button Action
    
    
    @IBAction func btnRulesOfUseClick(sender: AnyObject) {
        let termVC = self.storyboard?.instantiateViewControllerWithIdentifier("idTermsAndConditionViewController") as! TermsAndConditionViewController
         termVC.status = "1"
        self.navigationController?.pushViewController(termVC, animated: true)
    }
    
    @IBAction func btnCheckIconClick(sender: AnyObject) {
        if is_termsClick{
            btnCheckIconOutlet.setImage(UIImage(named: "uncheck_icon_red"), forState: UIControlState.Normal)
            is_termsClick = false
        }else{
            
            btnCheckIconOutlet.setImage(UIImage(named: "check_icon_red"), forState: UIControlState.Normal)
            is_termsClick = true
        }
    }
    
    
    @IBAction func btnTermsClick(sender: AnyObject) {
        let termVC = self.storyboard?.instantiateViewControllerWithIdentifier("idTermsAndConditionViewController") as! TermsAndConditionViewController
         termVC.status = "2"
        self.navigationController?.pushViewController(termVC, animated: true)
    }
    
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func btnEditProfilePic(sender: AnyObject) {
        self.askToChangeImage()
    }
    
    func askToChangeImage(){
        let alert = UIAlertController(title: "Let's get a picture", message: "Choose a Picture Method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        self.imgPicker.delegate = self
        
        if(is_imageUpload){
            let removeImageButton = UIAlertAction(title: "Remove profile picture", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
                self.is_imageUpload = false
                self.imgProfile.image = self.delObj.userPlaceHolderImage
            }
            alert.addAction(removeImageButton)
        }else{
            print("No image is selected")
        }
        
        //Add AlertAction to select image from library
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.imgPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.imgPicker.delegate = self
            self.imgPicker.allowsEditing = true
            self.presentViewController(self.imgPicker, animated: true, completion: nil)
        }
        
        //Check if Camera is available, if YES then provide option to camera
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
                self.imgPicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.imgPicker.allowsEditing = true
                self.presentViewController(self.imgPicker, animated: true, completion: nil)
            }
            alert.addAction(cameraButton)
        } else {
            print("Camera not available")
            
        }
        
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            print("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
//TODO: - API/Web service call
    
    @IBAction func btnSaveClick(sender: AnyObject) {
        
        
        //Progress activity loaded
       //  SVProgressHUD.showWithStatus("Loading...")
        self.cust.showLoadingCircle()
        
        //Check fields are enterd or not?
        if isDataEntered(){
            
            //Check for Password entry
            if(checkTextSufficientComplexity(txtConfirmPassword.text!)){
           
                //Check for Terms and condition checkbox
            if is_termsClick{
               
                //IMage Uploading
                var isChangedValue : String = String()
                if is_imageUpload{
                    isChangedValue = "Y"
                }else{
                     isChangedValue = "N"
                }
                
                
                let inputParameters =
                [   //"Method":"signup",
                "fname":self.txtFirstName.text!,
                "lname":self.txtLastName.text!,
                "username":self.txtUserName.text!,
                "password":self.txtConfirmPassword.text!,
                "emailid":self.txtEmailID.text!,
                "photo":base64String,
                "isChanged": isChangedValue,
                //"phone":self.txtPhoneNo.text!,
                "iagree":"1",
                "devicetoken": delObj.deviceTokenToSend,
                "deviceid": delObj.deviceUDID,
                "devicetype" : "iPhone"
                
                ]
                
                 Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/signup", parameters : inputParameters)
                    .responseJSON { response in
                        debugPrint(response)
                        // SVProgressHUD.dismiss()
                        self.cust.hideLoadingCircle()
                        
                        print("res\(response.result.value)")
                       // print(NSString(data: response.request!.HTTPBody!, encoding:NSUTF8StringEncoding)!)
                        
                        
                        if(response.result.isSuccess){
                            let outJson = JSON(response.result.value!)
                            if(outJson["status"] != "1"){
                                print("Jsonprint: \(outJson)")
                                
                                /*self.delObj.displayMessage("Result", messageText:
                                    "\(outJson["data"]["userid"].stringValue)")*/
                                
                                //After Succcessful Signup call Login 
                                self.doLogin(self.txtUserName.text!, pswrd: self.txtConfirmPassword.text!)
                                
                                //self.doLogin(self.txtUserName.text!,pswrd: self.txtConfirmPassword.text!)
                            
                            }else{
                               
                                self.delObj.displayMessage("BuzzDeal", messageText: outJson["msg"].stringValue)
                            }
                            
                        }else{
                            self.delObj.displayMessage("BuzzDeal", messageText: "Please check intenet connection")
                        }
                }
                
            }else{
               // SVProgressHUD.dismiss()
                self.cust.hideLoadingCircle()
                
                delObj.displayMessage("BuzzDeal", messageText: "Please accept Terms and Condition")
            }
          }else{   // Password entry If close
                // SVProgressHUD.dismiss()
                self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Password must contains 8 characters. \n One uppercase letter \n & \n One digit")
          }
        }else{
            self.cust.hideLoadingCircle()
            //SVProgressHUD.dismiss()
        }
    }
    
    func doLogin(username:String, pswrd : String){
        //SVProgressHUD.showWithStatus("Performing Login..")
        self.cust.showLoadingCircle()
        
        let parameters = ["username": username,"password":pswrd]
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/login", parameters: parameters).responseJSON{
            response in
            
            print("output\(response.result.value)")
            
            if(response.result.isSuccess){
                //SVProgressHUD.dismiss()
                self.cust.hideLoadingCircle()
                
                let outJSON = JSON(response.result.value!)
                if(outJSON["status"] != "1"){
                    
                 //   self.delObj.displayMessage("BuzzDeal", messageText: outJSON["data"]["photo"].stringValue)
                    
                    self.defaults.setValue(username, forKey: "usernameTemp")
                    
                    //Keychain Code here
                    self.myKeychainWrapper.mySetObject(self.txtPassword.text!, forKey: kSecValueData)
                    self.myKeychainWrapper.writeToKeychain()
                    //Keychain
                    
                    
                    //self.defaults.setValue(pswrd, forKey: "passwordTemp")
                    self.defaults.setValue(outJSON["data"]["userid"].stringValue, forKey: "appUserID")
                    self.defaults.setBool(true, forKey: "is_Autologin")
                    
                    let userDetails = ["emailID":outJSON["data"]["emailid"].stringValue,
                                        "fname":outJSON["data"]["fname"].stringValue,
                                        "lname":outJSON["data"]["lname"].stringValue,
                                        "photo":outJSON["data"]["photo"].stringValue,
                                        "phone":outJSON["data"]["phone"].stringValue]
                    
                    self.defaults.setValue(userDetails, forKey: "userDetails")
                    self.defaults.synchronize()
                    
                    let containerVC = self.storyboard?.instantiateViewControllerWithIdentifier("idContainerTabBarController") as! ContainerTabBarController
                    self.navigationController?.pushViewController(containerVC, animated: true)
                    
                }else{
                    
                    self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                    
                }
            }else{
                //SVProgressHUD.dismiss()
                self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                
            }
        }
        
        
    }

    
    
//TODO: - UIImagePickerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let pickedImage : UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imgProfile.image = cust.rotateCameraImageToProperOrientation(pickedImage, maxResolution: 360)// pickedImage
        
         /*pickedImage = Toucan(image: pickedImage).resize(CGSize(width: 80, height: 80), fitMode: Toucan.Resize.FitMode.Crop).image
        pickedImage = Toucan(image: pickedImage).maskWithRoundedRect(cornerRadius: 7).image*/
        //getImage = cropImage(getImage!)
     
        
        //=======
        //let imageData = UIImageJPEGRepresentation(pickedImage, 0.8)
        let imageData : NSData = UIImageJPEGRepresentation(self.imgProfile.image!,0.8)!
        base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        is_imageUpload = true
        // imageDataToUpload = UIImagePNGRepresentation(imgProfPic.image)
        //let base64String = imageData.base64EncodedStringWithOptions(.allZeros)
        

       // print(base64String)
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        is_imageUpload = false
        dismissViewControllerAnimated(true, completion: nil)
        
    }

     
    
    
//TODO: - Common Methods
    
    func roundedImageView(){
        self.imgProfile.layer.cornerRadius = cust.RounderCornerRadious //self.imgProfile.frame.size.width/2
        self.imgProfile.clipsToBounds = true
    }

}
