//
//  MenuScrollViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 3/12/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Alamofire


class MenuScrollViewController: UIViewController,UIScrollViewDelegate {

//TODO: - General
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    let defaults = NSUserDefaults.standardUserDefaults()
    var is_zoomViewDisplay : Bool = Bool()
    var userID : String = String()
    var businessID : String = String()
    
    
//TODO: - Controls
    @IBOutlet weak var containerView: UIView!
    var scrollView : UIScrollView = UIScrollView()
    var pageControl : UIPageControl = UIPageControl()
    var imageNameArray : [String] = []// ["Stylish-Menu-Card.jpg","menu_temp_2.jpg","menu_temp_3.jpg","temp_4.jpg","temp_5.jpg","temp_6.jpg","temp_7.jpg"]
    var tempScrollView : UIScrollView = UIScrollView()
    var  tempImageView : UIImageView = UIImageView()
    @IBOutlet weak var menuView: UIView!
    
//TODO: - Let's Play
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.cust.showLoadingCircle()
       // SVProgressHUD.showWithStatus("Loading...")
        is_zoomViewDisplay = false
        
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
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
         self.cust.hideLoadingCircle()
      //  SVProgressHUD.dismiss()
        removeControllsFromSubView()
      //  loadMenuImages()
      
        
    }

    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
       print("double tapped\(self.pageControl.currentPage )")
        self.cust.showLoadingCircle()
       // SVProgressHUD.showWithStatus("Loading...")
        // 1
        let pointInView = recognizer.locationInView(tempImageView)
        
        // 2
        var newZoomScale = tempScrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, tempScrollView.maximumZoomScale)
        
        
        // 3
        let scrollViewSize = tempScrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        tempScrollView.zoomToRect(rectToZoomTo, animated: true)        
        
        createDynamicView()
    }
    
    func scrollViewAgainDoubleTapped(recognizer: UITapGestureRecognizer) {
         is_zoomViewDisplay = false
        tempScrollView.removeFromSuperview()
       // removeControllsFromSubView()
       // firstMethods()
    }
    
    
    func createDynamicView(){
        
//        self.tempScrollView.minimumZoomScale = 1.0
//        self.tempScrollView.maximumZoomScale = 6.0
       // tempScrollView.backgroundColor = UIColor.purpleColor()
        
        //2
        print("imageNameArray : \(imageNameArray)")
        print("self.pageControl.currentPage: \(self.pageControl.currentPage)")
        var imageT = UIImage() // UIImage(named: imageNameArray[self.pageControl.currentPage])
        
        
        SDImageCache.sharedImageCache().queryDiskCacheForKey(self.imageNameArray[self.pageControl.currentPage]) { ( img:UIImage!, cacheType:SDImageCacheType) -> Void in
            if(img != nil){
                
                print("image in cache")
                imageT =  img
            }
        }
    
        
        tempImageView .image = imageT
        tempImageView.frame = CGRectMake(0, 0, (imageT.size.width), (imageT.size.height))
        tempImageView.contentMode = UIViewContentMode.ScaleToFill
        
        //3
        tempScrollView = UIScrollView(frame: CGRectMake(self.containerView.frame.origin.x,self.containerView.frame.origin.y,self.containerView.frame.size.width,self.containerView.frame.size.height))
        tempScrollView.backgroundColor = UIColor.whiteColor()
         self.tempScrollView.contentSize = CGSizeMake(tempImageView.frame.width, self.tempImageView.frame.height)
        
        //4
        let scrollViewFrame = tempScrollView.frame
        let scaleWidth = scrollViewFrame.size.width / tempScrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / tempScrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        tempScrollView.minimumZoomScale = minScale;
        
        // 5
        tempScrollView.maximumZoomScale = 1.0
        tempScrollView.zoomScale = minScale;
        
        // 6
        centerScrollViewContents()
       
        tempScrollView.addSubview(tempImageView)
        self.view.addSubview(tempScrollView)
        is_zoomViewDisplay = true
         self.cust.hideLoadingCircle()
        
        //add exit tap
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(MenuScrollViewController.scrollViewAgainDoubleTapped(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        // doubleTapGesture.numberOfTouchesRequired = 1
        tempScrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    
    func centerScrollViewContents() {
        let boundsSize = tempScrollView.bounds.size
        var contentsFrame = tempImageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        tempImageView.frame = contentsFrame
    }
    
    
    
    func createScroll(){
        removeControllsFromSubView()
        let originalWidth : CGFloat = self.containerView.frame.size.width
        let originalHeight : CGFloat = self.containerView.frame.size.height
        
        //2
        let lblTitle : UILabel = UILabel(frame: CGRectMake(self.containerView.frame.origin.x,10,self.containerView.frame.size.width*1,self.containerView.frame.size.height*0.1))
        lblTitle.textColor = UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0)
        lblTitle.font = UIFont(name: cust.FontName, size: 15)
        lblTitle.textAlignment = NSTextAlignment.Center
        lblTitle.text = "Double tap on image to zoom"        
         self.containerView.addSubview(lblTitle)
        
        print(self.containerView.frame.size.width)
        for  i in 0...imageNameArray.count-1{
            print(i)
            //1
            let viewback: UIView = UIView(frame: CGRectMake(originalWidth * CGFloat(i),0,originalWidth,originalHeight))
            
            //3
            let imageView : UIImageView = UIImageView(frame: CGRectMake(self.containerView.frame.origin.x,self.containerView.frame.origin.y-50,self.containerView.frame.size.width*1,(self.containerView.frame.size.height*0.90)+50))
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
           
            
            SDImageCache.sharedImageCache().queryDiskCacheForKey(self.imageNameArray[i]) { ( img:UIImage!, cacheType:SDImageCacheType) -> Void in
                if(img != nil){
                    
                    print("image in cache")
                    //self.imgProfilePic.image = img
                     imageView.image =  img
                    
                }else{
                    self.cust.showLoadingCircle()
                    
                    Alamofire.request(.GET, self.imageNameArray[i])
                        .response { request, response, data, error in
                            print(request)
                            //  print(response)
                            //  print(data)
                            //  print(error)
                            
                            if(data != nil){
                                self.cust.hideLoadingCircle()
                                
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
            }
            
           /* let ur = NSURL(string: self.imageNameArray[i])
            imageView.sd_setImageWithURL(ur, placeholderImage: self.delObj.businessPlaceHolderImage, options: SDWebImageOptions.RefreshCached)
            */
            
            
           
            viewback.addSubview(imageView)
            self.scrollView.delegate = self
            
            self.scrollView.addSubview(viewback)
            
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func removeControllsFromSubView()
    {
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
        
    }
    
    
//TODO: - UIScrollViewDeleagte Method implementation
    
    
//TODO: - Web service / API 
    func loadMenuImages(){
        
        //Activity Loader
        self.cust.showLoadingCircle()
        imageNameArray.removeAll(keepCapacity: false)
        
        Alamofire.request(.POST, delObj.baseUrl + "buzzdealservices.php/menugallery", parameters: ["businessid":businessID,"userid":userID]).responseJSON{
            response in
            
            print(response.result)
            
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
                    self.updateGalleryImages()
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
    
    
    func updateGalleryImages(){
        //Code to write here
        
        if(self.imageNameArray.count > 0){
            
          /*  for index in 0...imageNameArray.count-1{
                
                SDImageCache.sharedImageCache().queryDiskCacheForKey(self.imageNameArray[index]) { ( img:UIImage!, cacheType:SDImageCacheType) -> Void in
                    if(img != nil){
                        
                        print("image in cache")
                        //self.imgProfilePic.image = img
                        
                    }else{
                        self.cust.showLoadingCircle()
                        
                        Alamofire.request(.GET, self.imageNameArray[index])
                            .response { request, response, data, error in
                                print(request)
                                //  print(response)
                                //  print(data)
                                //  print(error)
                                
                                if(data != nil){
                                    self.cust.hideLoadingCircle()
                                    
                                    let image = UIImage(data: data! )
                                    SDImageCache.sharedImageCache().storeImage(image, forKey: self.imageNameArray[index])
                                    
                                    
                                }else{
                                    self.cust.hideLoadingCircle()
                                    //Display placeholder
                                    
                                }
                        }
                    }
                }
            }*/
            
            removeControllsFromSubView()
            
            firstMethods()
        }
        
        
        
    }
    
    
    func firstMethods(){
        self.scrollView = UIScrollView(frame: self.containerView.frame)
        self.scrollView.pagingEnabled = true
        self.view.addSubview(self.scrollView)
        
        //PageControl
        self.pageControl = UIPageControl(frame: CGRectMake(0,self.containerView.frame.size.height*0.9999,self.containerView.frame.size.width,10))
        self.pageControl.pageIndicatorTintColor = UIColor.blackColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 0.921, green: 0.2, blue: 0.294, alpha: 1.0)
        self.view.addSubview(self.pageControl)
        
        createScroll()
        
        self.pageControl.numberOfPages = imageNameArray.count
        self.scrollView.contentSize = CGSizeMake(self.containerView.frame.width*CGFloat(imageNameArray.count), self.scrollView.frame.height)
        let scrollPoint : CGPoint = CGPointMake(0, 0)
        self.scrollView.setContentOffset(scrollPoint, animated: true)
        
        
        //3
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(MenuScrollViewController.scrollViewDoubleTapped(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    
//TODO: - Button Action
    
    @IBAction func btnBackClick(sender: AnyObject) {
        if is_zoomViewDisplay{
            is_zoomViewDisplay = false
            tempScrollView.removeFromSuperview()
        }else{
           self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    
//TODO: - UIScrollViewDelegate Method
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth : CGFloat = CGRectGetWidth(scrollView.bounds)
        let pageFraction : CGFloat = self.scrollView.contentOffset.x / pageWidth
        self.pageControl.currentPage = Int(pageFraction)
    }
   
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return tempImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
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
