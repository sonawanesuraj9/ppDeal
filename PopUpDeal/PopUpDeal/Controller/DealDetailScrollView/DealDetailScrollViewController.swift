//
//  DealDetailScrollViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 3/4/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire


class DealDetailScrollViewController: UIViewController,UIScrollViewDelegate {

    
//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    var userID : String = String()
    var businessID : String = String()
    
    
//TODO: - Controlls
    
    @IBOutlet weak var containerView: UIView!
    var scrollView : UIScrollView = UIScrollView()
    var pageControl : UIPageControl = UIPageControl()
    var imageNameArray : [String] = [] //["logo1.jpg","logo2.png","logo3.jpg","logo4.jpg"]
    

    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if(defaults.valueForKey("appUserID") != nil){
            userID = defaults.valueForKey("appUserID") as! String
        }
        
        if(defaults.valueForKey("businessID") != nil){
            businessID = defaults.valueForKey("businessID") as! String
        }else{
            print("No Business Selected")
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        removeControllsFromSubView()
        loadImageDetails()
        
    }
    
    func createScroll(){
        let originalWidth : CGFloat = self.containerView.frame.size.width
        let originalHeight : CGFloat = self.containerView.frame.size.height
        
        
        for  i in 0...imageNameArray.count-1{
            print(i)
            let viewback: UIView = UIView(frame: CGRectMake(originalWidth * CGFloat(i),0,originalWidth,originalHeight))
            
            let imageView : UIImageView = UIImageView(frame: CGRectMake(self.containerView.frame.origin.x,self.containerView.frame.origin.y,self.containerView.frame.size.width*1,self.containerView.frame.size.height*0.90))
          
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            
            let ur = NSURL(string: self.imageNameArray[i])
           imageView.sd_setImageWithURL(ur, placeholderImage: self.delObj.businessPlaceHolderImage, options: SDWebImageOptions.RefreshCached)
            
                /*SDImageCache.sharedImageCache().queryDiskCacheForKey(self.imageNameArray[i]) { ( img:UIImage!, cacheType:SDImageCacheType) -> Void in
                if(img != nil){
                    
                    print("image in cache")
                    imageView.image =  img
                    
                }else{
                    self.cust.showLoadingCircle()
                    //SVProgressHUD.showWithStatus("Loading...")
                    Alamofire.request(.GET, self.imageNameArray[i])
                        .response { request, response, data, error in
                            print(request)
                           
                            if(data != nil){
                                self.cust.hideLoadingCircle()
                                // SVProgressHUD.dismiss()
                                let image = UIImage(data: data! )
                                SDImageCache.sharedImageCache().storeImage(image, forKey: self.imageNameArray[i])
                                imageView.image =  image
                                
                            }else{
                                self.cust.hideLoadingCircle()
                                imageView.image = self.delObj.businessPlaceHolderImage
                                
                                //Display placeholder
                                
                            }
                    }
                }
            }*/
            
            viewback.addSubview(imageView)
            self.scrollView.delegate = self
            self.scrollView.addSubview(viewback)
            
        }
        
    }
    
    func removeControllsFromSubView()
    {
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
        
    }
    
    func loadImageDetails(){
        
        //Activity Loader
       // self.cust.showLoadingCircle()
        imageNameArray.removeAll(keepCapacity: false)
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/businessgallery", parameters: ["businessid":businessID,"userid":userID]).responseJSON{
            response in
            
            print(response.result)
            
            if(response.result.isSuccess){
                
                //Hide Activity
             //   self.cust.hideLoadingCircle()
                let outJSON = JSON(response.result.value!)
                print("JSON \(outJSON)")
                
                if(outJSON["status"] != "1"){
                    
                    
                    let count = outJSON["data"]["dealsarray"].array?.count
                    print("count\(count)")
                    
                    let galleryCout = outJSON["data"]["businessgallery"].array?.count
                    
                    if(galleryCout != 0){
                        if let gc = galleryCout{
                            for index in 0...gc-1{
                                
                                self.imageNameArray.insert(outJSON["data"]["businessgallery"][index].stringValue, atIndex: index)
                            }
                        }
                        
                        print("businessImgGallery\(self.imageNameArray)")
                        
                    }
                    
                    print("gallary\(galleryCout)")
                    self.updateGalleryImages()
                    print("**")
                    
                }else{
                    
                    //if status is 0
                   // self.cust.hideLoadingCircle()
                    self.delObj.displayMessage("BuzzDeal", messageText: outJSON["msg"].stringValue)
                }
                
            }else{
                //Hide Activity
               // self.cust.hideLoadingCircle()
                self.delObj.displayMessage("BuzzDeal", messageText: "Please check internet connection")
            }
        }
        
    }

    func updateGalleryImages(){
        //Code to write here
        
        if(self.imageNameArray.count > 0){
            //            imageNameArray = defaults.valueForKey("businessImgGallery") as! [String]
            //
            removeControllsFromSubView()
            
            firstMethods()
        }else{
            
        }
        
    }
    
    
    func firstMethods(){
        
        self.scrollView = UIScrollView(frame: self.containerView.frame)
        self.scrollView.pagingEnabled = true
        self.containerView.addSubview(self.scrollView)
        
        //PageControl
        self.pageControl = UIPageControl(frame: CGRectMake(0,self.containerView.frame.size.height*0.915,self.containerView.frame.size.width,10))
        self.pageControl.pageIndicatorTintColor = UIColor.blackColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 0.921, green: 0.2, blue: 0.294, alpha: 1.0)
        self.view.addSubview(self.pageControl)
        
        createScroll()
        
        self.pageControl.numberOfPages = imageNameArray.count
        self.scrollView.contentSize = CGSizeMake(self.containerView.frame.width*CGFloat(imageNameArray.count), self.scrollView.frame.height)
        let scrollPoint : CGPoint = CGPointMake(0, 0)
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
//TODO: - UIScrollViewDelegate Method
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth : CGFloat = CGRectGetWidth(scrollView.bounds)
        let pageFraction : CGFloat = self.scrollView.contentOffset.x / pageWidth
        self.pageControl.currentPage = Int(pageFraction)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
