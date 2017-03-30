//
//  CustomClass_Dev.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/23/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit
import Darwin

class CustomClass_Dev: NSObject {

    //Text color : 322e2d
    
    // defauls 
    
    let RounderCornerRadious : CGFloat = 5
    let placeholderTextColor : UIColor = UIColor(red: 177/255, green: 177/255, blue: 177/255, alpha: 1.0)
    
    let mainBackgroundColor : UIColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0)
    let normalTextColor : UIColor = UIColor(red: 118/255, green: 118/255, blue: 118/255, alpha: 1.0)
    
    let textBackground : UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    let textFieldTextColor : UIColor = UIColor(red: 131/255, green: 131/255, blue: 131/255, alpha: 1.0)
    
    let buttonTextColor : UIColor = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1.0)
    let redButtonBackground : UIColor = UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 1.0)
    let redButtonTextColor : UIColor = UIColor.whiteColor()
    
    let gradientTopColor : UIColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1.0)
    let gradientBottomColor : UIColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
    
    
//    let gradientTopColor : UIColor = UIColor(red: 35/255, green: 33/255, blue: 34/255, alpha: 1.0)
//    let gradientBottomColor : UIColor = UIColor(red: 15/255, green: 14/255, blue: 14/255, alpha: 1.0)
//    
    let FontName : String = "HelveticaNeue-Light"
    let FontSizeText : CGFloat = 15.0
    let FontSizeTitle : CGFloat = 16.0
    let textColor : UIColor = UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1.0)
    
    //Validate EmailID
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    }
    
    //Custom Loading
    var CustomLoading : MZLoadingCircle = MZLoadingCircle()
    var isLoading : Bool = Bool()
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func showLoadingCircle(){
        if(!isLoading){
            CustomLoading = MZLoadingCircle(nibName: nil, bundle: nil)
            CustomLoading.view.backgroundColor = UIColor.clearColor()
            
          /*  let color : UIColor = UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 0.6)
            let color1 : UIColor = UIColor(red: 249/255, green: 64/255, blue: 82/255, alpha: 0.4)*/
            let color : UIColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 0.6)
            let color1 : UIColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 0.4)
            
            CustomLoading.colorCustomLayer = color
            CustomLoading.colorCustomLayer2 = color1
            let CircleSize : CGFloat = 95.0
            var frameView : CGRect = CustomLoading.view.frame
            frameView.size.width = CircleSize
            frameView.size.height = CircleSize
            frameView.origin.x = delObj.screenWidth / 2 - frameView.size.width / 2
            frameView.origin.y = delObj.screenHeight / 2 - frameView.size.height / 2
            CustomLoading.view.frame = frameView
            CustomLoading.view.layer.zPosition = CGFloat(MAXFLOAT)
            UIApplication.sharedApplication().keyWindow?.userInteractionEnabled = false
            UIApplication.sharedApplication().keyWindow?.addSubview(CustomLoading.view)
           // self.addSubview(CustomLoading.view)
            isLoading = true
        }
        
    }
    
    func hideLoadingCircle(){
        if(isLoading){
            isLoading = false
             UIApplication.sharedApplication().keyWindow?.userInteractionEnabled = true
            CustomLoading.view.removeFromSuperview()
        }
        //  CustomLoading = nil
    }

    func rotateCameraImageToProperOrientation(imageSource : UIImage, maxResolution : CGFloat) -> UIImage {
        
        let imgRef = imageSource.CGImage;
        
        let width = CGFloat(CGImageGetWidth(imgRef));
        let height = CGFloat(CGImageGetHeight(imgRef));
        
        var bounds = CGRectMake(0, 0, width, height)
        
        var scaleRatio : CGFloat = 1
        if (width > maxResolution || height > maxResolution) {
            
            scaleRatio = min(maxResolution / bounds.size.width, maxResolution / bounds.size.height)
            bounds.size.height = bounds.size.height * scaleRatio
            bounds.size.width = bounds.size.width * scaleRatio
        }
        
        var transform = CGAffineTransformIdentity
        let orient = imageSource.imageOrientation
        let imageSize = CGSizeMake(CGFloat(CGImageGetWidth(imgRef)), CGFloat(CGImageGetHeight(imgRef)))
        
        
        switch(imageSource.imageOrientation) {
        case .Up :
            transform = CGAffineTransformIdentity
            
        case .UpMirrored :
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            
        case .Down :
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI));
            
        case .DownMirrored :
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            
        case .Left :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0);
            
        case .LeftMirrored :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0);
            
        case .Right :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0);
            
        case .RightMirrored :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0);
            
        default : ()
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        if orient == .Right || orient == .Left {
            CGContextScaleCTM(context, -scaleRatio, scaleRatio);
            CGContextTranslateCTM(context, -height, 0);
        } else {
            CGContextScaleCTM(context, scaleRatio, -scaleRatio);
            CGContextTranslateCTM(context, 0, -height);
        }
        
        CGContextConcatCTM(context, transform);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
        
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return imageCopy;
    }
    
}
