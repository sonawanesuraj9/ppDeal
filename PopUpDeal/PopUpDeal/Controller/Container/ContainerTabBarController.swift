//
//  ContainerTabBarController.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/23/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit

extension UIImage {
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class ContainerTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: CGFloat(0.97), green: CGFloat(0.25), blue: CGFloat(0.32), alpha: CGFloat(1))], forState: UIControlState.Normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(1))], forState: UIControlState.Selected)
        
               //Uncomment below to set box background
        
    //    UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1.0), size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height))

        
//        UITabBar.appearance().translucent = false
//      //  UITabBar.appearance().barTintColor = UIColor.purpleColor()
//        UITabBar.appearance().tintColor = UIColor.whiteColor()
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
