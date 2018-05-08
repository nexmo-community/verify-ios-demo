//
//  URLRequestManager.swift
//  nexmo-verify-ios-demo
//
//  Created by Eric on 07/05/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import Foundation

struct URLRequestManager {

    static func getRequest(_ url: String, parameters: [String:Any]) -> URLRequest? {
        
        var urlRequest = try? URLRequest(url: url, method: .post)
        
        // HTTP standards for the body of our request
        urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        if let data = data {
            let json = String(data: data, encoding: String.Encoding.utf8)
            
            if let json = json {
                print("JSON: ", json)
                urlRequest?.httpBody = json.data(using: String.Encoding.utf8)
            }
        }

        return urlRequest
    }
}
