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
        //Sending SMS
        let param = ["telephoneNumber": telephoneTextField.text]
        
        Alamofire.request("https://nexmo-verify.glitch.me/request", parameters: param as Any).responseJSON { response in
            
            print("--- Sent SMS API ----")
            print("Response: \(response)")
            
            if let json = response.result.value as? [String:AnyObject] {
                
                self.responseId = json["request_id"] as! String
                self.performSegue(withIdentifier: "authenticateWith2FA", sender: self)
            }
        }
    }
    
    func cancelRequest() {
        
        //Sending SMS
        let param = ["response_id": responseId]
        
        Alamofire.request("https://nexmo-verify.glitch.me/request", parameters: param as Any).responseJSON { response in
            
            print("--- Sent SMS API ----")
            print("Response: \(response)")
            
            if let json = response.result.value as? [String:AnyObject] {
                
                self.responseId = json["request_id"] as! String
                self.performSegue(withIdentifier: "authenticateWith2FA", sender: self)
            }
        }
        
        
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let confirmationVC = segue.destination as! ConfirmationViewController
        confirmationVC.responseId = responseId
     }

    
}
