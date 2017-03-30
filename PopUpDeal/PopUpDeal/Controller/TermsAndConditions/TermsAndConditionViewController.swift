//
//  TermsAndConditionViewController.swift
//  BuzzDeal
//
//  Created by Suraj MAC2 on 3/9/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit

class TermsAndConditionViewController: UIViewController,UIWebViewDelegate {

//TODO: - General
    
    let delObj = UIApplication.sharedApplication().delegate as! AppDelegate
    let cust : CustomClass_Dev = CustomClass_Dev()
    
    var url =  String()
    var urlToLoad : NSURL = NSURL()
    
    var status : String = String()
//TODO: - Controlls
    
    @IBOutlet weak var webViewOutlet: UIWebView!
    
//TODO: - Let's Play
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //MARK: if status == 1 >> Privacy, Else Terms
        if(status == "1"){
            url = "\(self.delObj.baseUrl)privacy.html"
            urlToLoad = NSURL(string: url)!
        }else if(status == "2"){
            url = "\(self.delObj.baseUrl)terms.html"
            urlToLoad = NSURL(string: url)!
        }else if(status == "3"){
            url = "\(self.delObj.baseUrl)rules.html"
            urlToLoad = NSURL(string: url)!
        }
       
        let theRequestUrl = NSURLRequest(URL: urlToLoad)
        webViewOutlet.loadRequest(theRequestUrl)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//TODO: - Button Action
    
    @IBAction func btnBackClick(sender: AnyObject) {        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
//TODO: - UIWebViewDelegate Method Implementation
    func webViewDidStartLoad(webView: UIWebView){
        self.cust.showLoadingCircle()
       // SVProgressHUD.showWithStatus("Loading...")
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
         self.cust.hideLoadingCircle()
       // SVProgressHUD.dismiss()
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
