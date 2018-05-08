//
//  VerificationViewController.swift
//  nexmo-verify-ios-demo
//
//  Created by Eric Giannini on 5/3/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import Alamofire



class VerificationViewController: UIViewController {
    
    var responseId = String()
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var telephoneTextField: UITextField!
    
    @IBAction func loginBtn(_ sender: Any) {
        self.requestVerificationWithAPI()
        
    }

    @IBAction func cancelBtn(_ sender: Any) {
        self.cancelBtn()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestVerificationWithAPI()
    {
        guard let number = telephoneTextField.text else { return }
        
        //Sending SMS
        let parameters = ["number": number]
        let url = "https://nexmo-verify.glitch.me/request"
        
        guard let request = URLRequestManager.getRequest(url, parameters: parameters) else { return }
        
        Alamofire.request(request).responseJSON { [weak self] response in
            
            print("--- Sent SMS API ----")
            print("Response: \(response)")
            
            if let json = response.result.value as? [String:AnyObject] {
                
                guard let requestId = json["request_id"] as? String else { return }
                
                self?.performSegue(withIdentifier: "AuthenticateWith2FA", sender: requestId)
            }
        }
    }
    
    func cancelRequest() {
        
        guard let requestId = requestId else { return }
        
        let parameters = ["request_id": requestId]
        let url = "https://nexmo-verify.glitch.me/cancel"
        
        guard let request = URLRequestManager.getRequest(url, parameters: parameters) else { return }
        
        Alamofire.request(request).responseJSON { response in
            
            print("--- Cancel Request API ----")
            print("Response: \(response)")
            
            if let json = response.result.value as? [String:AnyObject],
                let status = json["status"] as? String {
                
                if Int(status) == 0 {
                    print("Request Cancelled Successfully")
                }
            }
        }
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let confirmationVC = segue.destination as! ConfirmationViewController
        confirmationVC.responseId = responseId
     }

    
}
