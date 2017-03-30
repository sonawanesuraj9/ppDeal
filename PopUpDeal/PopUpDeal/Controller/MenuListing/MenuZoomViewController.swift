//
//  MenuZoomViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC3 on 21/09/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire

class MenuZoomViewController: UIViewController,UIScrollViewDelegate {

//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let cust : CustomClass_Dev = CustomClass_Dev()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    //Previous Data
    var imageURL : String = String()

//TODO: - Controls
    
    @IBOutlet weak var mainScrollview: UIScrollView!
   
    @IBOutlet weak var imgMenu: UIImageView!
    
//TODO: - Let's Buzz
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
      
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.mainScrollview.delegate = self
        self.mainScrollview.minimumZoomScale = 1.0
        self.mainScrollview.maximumZoomScale = 6.0

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        SDImageCache.sharedImageCache().queryDiskCacheForKey(imageURL) { ( img:UIImage!, cacheType:SDImageCacheType) -> Void in
            if(img != nil){
                
                print("image in cache")
                //self.imgProfilePic.image = img
                self.imgMenu.image =  img
                
            }else{
                self.cust.showLoadingCircle()
                
                Alamofire.request(.GET,self.imageURL)
                    .response { request, response, data, error in
                        print(request)
                        
                        if(data != nil){
                            self.cust.hideLoadingCircle()
                            
                            let image = UIImage(data: data! )
                            SDImageCache.sharedImageCache().storeImage(image, forKey: self.imageURL)
                            self.imgMenu.image =  image
                            
                        }else{
                            self.cust.hideLoadingCircle()
                            self.imgMenu.image = self.delObj.businessPlaceHolderImage
                            //Display placeholder
                            
                        }
                }
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imgMenu
    }    
   
//TODO: - UIButton Action
    
    @IBAction func btnBackClick(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
