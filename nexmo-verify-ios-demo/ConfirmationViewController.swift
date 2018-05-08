//
//  ConfirmationViewController.swift
//  nexmo-verify-ios-demo
//
//  Created by Eric Giannini on 5/2/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import Alamofire

class ConfirmationViewController: UIViewController {
    
    var responseId = String()
    var pinCode = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func verifyPinViaAPI() {
        
        guard let requestId = requestId,
            let code = codeTextField.text else { return }
        
        let url = "https://nexmo-verify.glitch.me/check"
        let parameters = ["request_id": requestId,
                          "code": code]
        
        guard let request = URLRequestManager.getRequest(url, parameters: parameters) else { return }
        
        Alamofire.request(request).responseJSON { [weak self] response in
            
            print("--- Verify SMS API ----")
            print("Response: \(response)")
            
            if let json = response.result.value as? [String:AnyObject],
                let status = json["status"] as? String {
                
                // if status is zero, then success; if not something
                // went wrong
                if Int(status) == 0 {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true)
                        
                    }
                }
            }
        }s


}
