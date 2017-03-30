//
//  EditProfileViewController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/24/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire

class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let imgPicker : UIImagePickerController = UIImagePickerController()
    let defaults = NSUserDefaults.standardUserDefaults()
    let cust : CustomClass_Dev = CustomClass_Dev()
    
    
    var userID : String = String()
    var base64Data : String = String()
    var is_imageChanges : Bool = Bool()
    var is_imgUpload : Bool = Bool()
    let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
//TODO: - Controlls
    @IBOutlet weak var imgProfilePic: UIImageView!
    
    @IBOutlet weak var txtEmailID: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    //@IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var btnSaveOutlet: UIButton!
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.roundedImageView()
        btnSaveOutlet.layer.cornerRadius = cust.RounderCornerRadious
        
        //Setup user profile from userdefaults
        var profURL : String = String()
        
        if(defaults.valueForKey("userDetails") != nil){
            let userDetails = defaults.valueForKey("userDetails") as! NSDictionary
            txtEmailID.text  = userDetails["emailID"] as? String
            txtFirstName.text  = userDetails["fname"] as? String
            txtLastName.text = userDetails["lname"] as? String
           // txtPhoneNo.text = userDetails["phone"] as? String
            
       
             profURL = (userDetails["photo"] as? String)!
        }
        
        //imagetap
        self.imgProfilePic.userInteractionEnabled = true
        tapGesture.addTarget(self, action: #selector(EditProfileViewController.profileImageHasBeenTapped))
        self.imgProfilePic.addGestureRecognizer(tapGesture)
        
        if(profURL != ""){
           // is_imageChanges = true
        SDImageCache.sharedImageCache().queryDiskCacheForKey(profURL) { ( img:UIImage!, cacheType:SDImageCacheType) -> Void in
            if(img != nil){
                self.is_imageChanges = true
                self.imgProfilePic.image = img
                
            }else{
                self.cust.showLoadingCircle()
               // SVProgressHUD.showWithStatus("Loading...")
                Alamofire.request(.GET, profURL)
                    .response { request, response, data, error in
                        print(request)
                        print(response)
                        print(data)
                        print(error)
                        
                        if(data != nil){
                            self.cust.hideLoadingCircle()
                            //SVProgressHUD.dismiss()
                            let image = UIImage(data: data! )
                            SDImageCache.sharedImageCache().storeImage(image, forKey: profURL)
                            self.imgProfilePic.image = image
                            
                        }else{
                             self.cust.hideLoadingCircle()
                            //SVProgressHUD.dismiss()
                            //Display placeholder
                            self.is_imageChanges = true
                            self.imgProfilePic.image = self.delObj.userPlaceHolderImage
                        }
                }
            }
        }
        }else{
            is_imageChanges = false
            self.imgProfilePic.image = self.delObj.userPlaceHolderImage
        }
        
    }

    func profileImageHasBeenTapped(){
        print("image tapped")
        self.askToChangeImage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.txtFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        self.txtLastName.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
//        self.txtPhoneNo.attributedPlaceholder = NSAttributedString(string: "Phone No", attributes: [NSForegroundColorAttributeName:cust.placeholderTextColor])
        
        //is_imageChanges = false
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }

       
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func roundedImageView(){
        self.imgProfilePic.layer.cornerRadius = cust.RounderCornerRadious//self.imgProfilePic.frame.size.width/2
      //  self.imgProfilePic.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2));
        self.imgProfilePic.clipsToBounds = true
    }
    

    func checkAllFields() -> Bool{
        var flag : Bool = Bool()
        
        if(self.txtFirstName.text! == ""){
            self.delObj.displayMessage("BuzzDeal", messageText: "Please enter First Name")
            flag = false
        }else if(self.txtLastName.text! == ""){
            self.delObj.displayMessage("BuzzDeal", messageText: "Please enter Last Name")
            flag = false
        }else if(!(cust.isValidEmail(txtEmailID.text!))){
            delObj.displayMessage("BuzzDeal", messageText: "Please enter Valid EmailID")
            txtEmailID.becomeFirstResponder()
            flag = false
        }/*else if(self.txtPhoneNo.text! == ""){
            self.delObj.displayMessage("BuzzDeal", messageText: "Please enter the Phone Number")
            flag = false
        }*/else{
            flag = true
        }
        
        return flag
    }
    
    
    
    
    
    
//TODO: - Button Action
    
    @IBAction func btnBackClick(sender: AnyObject) {        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnEditProfilePicClick(sender: AnyObject) {
        
        self.askToChangeImage()
    }
    
    func askToChangeImage(){
        let alert = UIAlertController(title: "Lets get a picture", message: "Choose a Picture Method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        self.imgPicker.delegate = self
        
        if(is_imageChanges){
            let removeImageButton = UIAlertAction(title: "Remove profile picture", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
                self.is_imageChanges = false
                self.imgProfilePic.image = self.delObj.userPlaceHolderImage
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
    
    @IBAction func btnSaveClick(sender: AnyObject) {
        
        if(checkAllFields()){
            var parameters = Dictionary<String,String>()
            var isChangeTemp : String = String()
            
            if is_imgUpload{
                isChangeTemp = "Y"
            }else{
                isChangeTemp = "N"
            }
            
            if(is_imageChanges){
                parameters = ["userid":userID,"fname":self.txtFirstName.text!,"lname":self.txtLastName.text!,"photo":base64Data as String,"devicetoken":self.delObj.deviceTokenToSend,"email":self.txtEmailID.text!,"isChanged":isChangeTemp]
            }else{
                parameters = ["userid":userID,"fname":self.txtFirstName.text!,"lname":self.txtLastName.text!,"photo":"","devicetoken":self.delObj.deviceTokenToSend,"email":self.txtEmailID.text!,"isChanged":isChangeTemp]
            }
            
            self.cust.showLoadingCircle()
            Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/updateprofile", parameters: parameters).responseJSON{
                response in
                 debugPrint(response)
                print(parameters)
                print(response.result.value)
                self.cust.hideLoadingCircle()
                
                if(response.result.isSuccess){
                    
                    
                    
                    let outJSON = JSON(response.result.value!)
                    
                    if(outJSON["status"].stringValue != "1"){
                       
                        //Store user info for profile page
                        let userDetails = ["emailID":outJSON["email"].stringValue,
                            "fname":outJSON["response"]["fname"].stringValue,
                            "lname":outJSON["response"]["lname"].stringValue,
                            "photo":outJSON["response"]["photo"].stringValue,
                            "phone":outJSON["response"]["phone"].stringValue]
                        self.defaults.setValue(userDetails, forKey: "userDetails")
                        self.defaults.synchronize()

                        
                        
                        let alert = UIAlertController(title: "BuzzDeal", message: outJSON["msg"].stringValue, preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let OKbtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (value:UIAlertAction) -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                        alert.addAction(OKbtn)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        
                    }else{
                        self.delObj.displayMessage("Buzz Deal", messageText: outJSON["msg"].stringValue)
                    }
                    

                    
                }else{
                    self.cust.hideLoadingCircle()
                    self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
                    
                }
            }
        }
        
       
    }
    
    
    
    
    
//TODO: - UIImagePickerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let pickedImage : UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
       self.imgProfilePic.image = cust.rotateCameraImageToProperOrientation(pickedImage, maxResolution: 360)
        
        let imageData = UIImageJPEGRepresentation(self.imgProfilePic.image!,0.8)
        base64Data = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        is_imageChanges = true
        is_imgUpload = true
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        dismissViewControllerAnimated(true, completion: nil)
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
