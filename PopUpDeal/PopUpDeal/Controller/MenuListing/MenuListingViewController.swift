//
//  MenuListingViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC3 on 21/09/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire

class menuCollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var imgMenuThumb: UIImageView!
}

//======================================================

class MenuListingViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var userID : String = String()
    var businessID : String = String()
    
    
    //Response Array 
      var imageNameArray : [String] = []
//TODO: - Controls
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
//TODO: - Let's Buzz
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //imageNameArray = ["https://b.zmtcdn.com/data/menus/132/7401132/b1b4f825bf9755cfb46fb048467e7d37.jpg","https://b.zmtcdn.com/data/menus/531/16565531/d9fc2ddaa140faa4ce45767e116c710e.jpg","https://media-cdn.tripadvisor.com/media/photo-s/0b/69/c4/2a/restaurant-menu.jpg","https://s3-media3.fl.yelpcdn.com/bphoto/CM09qAw3hzqBnfKFNYR3sQ/ls.jpg"]
        loadMenuImages()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        
        
        if(defaults.valueForKey("selectedBusinessDetails") != nil){
            let businessDetail = defaults.valueForKey("selectedBusinessDetails") as! NSDictionary
            businessID = (businessDetail["businessID"] as? String)!
            
        }else{
            print("No Business Selected")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
//TODO: - UICollectionViewDatasource Method implementation
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return imageNameArray.count
    }
    
    
   func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellID", forIndexPath: indexPath) as! menuCollectionViewCell
    
    
    //Display thumb image here
        SDImageCache.sharedImageCache().queryDiskCacheForKey(self.imageNameArray[indexPath.row]) { ( img:UIImage!, cacheType:SDImageCacheType) -> Void in
            if(img != nil){
            
                print("image in cache")
            //self.imgProfilePic.image = img
                cell.imgMenuThumb.image =  img
            
            }else{
                self.cust.showLoadingCircle()
            
                Alamofire.request(.GET, self.imageNameArray[indexPath.row])
                    .response { request, response, data, error in
                        print(request)
                    
                    if(data != nil){
                        self.cust.hideLoadingCircle()
                        
                        let image = UIImage(data: data! )
                        SDImageCache.sharedImageCache().storeImage(image, forKey: self.imageNameArray[indexPath.row])
                        cell.imgMenuThumb.image =  image
                        
                    }else{
                        self.cust.hideLoadingCircle()
                        cell.imgMenuThumb.image = self.delObj.businessPlaceHolderImage
                        //Display placeholder
                        
                    }
            }
        }
    }
    
        return cell
    }
    
    //Use for size
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.width * 0.3125, UIScreen.mainScreen().bounds.width * 0.3125)
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        print(indexPath.row)
        
        let menuZoom = self.storyboard?.instantiateViewControllerWithIdentifier("idMenuZoomViewController") as! MenuZoomViewController
        menuZoom.imageURL = self.imageNameArray[indexPath.row]
        self.navigationController?.pushViewController(menuZoom, animated: true)
    }
    
    
//TODO: - Web service / API
    func loadMenuImages(){
        
        //Activity Loader
        self.cust.showLoadingCircle()
        imageNameArray.removeAll(keepCapacity: false)
          print("********:\(self.businessID)")
        Alamofire.request(.POST, "http://buzzdeal.net/mobwebservice/ios/buzzdealservices.php/menugallery", parameters: ["businessid":businessID]).responseJSON{
            response in
            
            print("businessid:\(self.businessID)")
           // print("userID:\(self.userID)")
            //print(response.result.value)
            
            if(response.result.isSuccess){
                
                //Hide Activity
                self.cust.hideLoadingCircle()
                let outJSON = JSON(response.result.value!)
                print("JSON \(outJSON)")
                
                if(outJSON["status"] != "1"){
                    
                    let galleryCout = outJSON["data"]["menugallery"].array?.count
                    
                    if(galleryCout != 0){
                        if let gc = galleryCout{
                            for index in 0...gc-1{
                                
                                self.imageNameArray.insert(outJSON["data"]["menugallery"][index].stringValue, atIndex: index)
                            }
                        }
                        
                        print("businessImgGallery\(self.imageNameArray)")
                        
                    }
                    
                    print("gallary\(galleryCout)")
                    self.mainCollectionView.reloadData()
                    print("**")
                    
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
    }
    
    
//TODO: - UIButton Action
    
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
