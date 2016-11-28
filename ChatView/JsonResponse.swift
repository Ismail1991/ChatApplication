//
//  JsonResponse.swift
//  Swift-ActionCableClient
//
//  Created by Ismail on 25/11/16.
//  Copyright © 2016 Proarch. All rights reserved.
//

import SwiftyJSON
import Foundation

@objc public protocol interfaceDelegae { // Delegate Creating
    
    // Delegate methods
    
    @objc optional func handleData(respData:NSArray)
    
    //
}

public class JsonResponse {
    
    public var delegate: interfaceDelegae?
    
    func getResponse(url: String) {
        gettingJsonData(url: url, completionHandler: { jsonData in
            self.delegate?.handleData!(respData: jsonData!)
        })
    }
    
    func gettingJsonData(url: String, completionHandler: @escaping (NSArray?) -> Void) {
        
        let url:NSURL = NSURL(string: url)!
        let requestURL:NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        
        let session = URLSession.shared
        let task = session.dataTask(with: requestURL as URLRequest) { data, response, error in
            
            guard error == nil && data != nil else {    // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            do {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 200) {
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:NSArray]
                    completionHandler(jsonData["messages"] as NSArray?)
                }
            } catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
        task.resume()
    }
}
