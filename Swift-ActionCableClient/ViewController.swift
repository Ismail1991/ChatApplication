//
//  ViewController.swift
//  Swift-ActionCableClient
//
//  Created by Ismail on 22/11/16.
//  Copyright © 2016 Proarch. All rights reserved.
//

import UIKit
import ActionCableClient

class ViewController: UIViewController {
    
    var client: ActionCableClient!// = ActionCableClient(url: URL(string: "ws://domain.tld/cable")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.client = ActionCableClient(url: URL(string: "ws://192.168.20.118:3005/cable")!)
        
        
        
        client.origin = "http://192.168.20.118:3005"
        
        client.headers = [
            "Authorization": "sometoken"
        ]
        
        
        client.connect()
        
        client.onConnected = {
            print("Connected!")
        }
        
        client.onDisconnected = {(error: Error?) in
            print("Disconnected!")
        }
        
        
        
        
        
        
////        // Create the Room Channel
////        let roomChannel = client.create("MessagesChannel") //The channel name must match the class name on the server
//        
//        // More advanced usage
//        let room_identifier = ["room_id" : "1"]
//        let roomChannel = client.create("MessagesChannel", identifier: room_identifier, autoSubscribe: true, bufferActions: true)  //The channel name must match the class name on the server
//        
//        // Receive a message from the server. Typically a Dictionary.
//        roomChannel.onReceive = { (JSON : Any?, error : Error?) in
//            print("Received", JSON, error)
//        }
//        
//        // A channel has successfully been subscribed to.
//        roomChannel.onSubscribed = {
//            print("Yay!")
//        }
//        
//        // A channel was unsubscribed, either manually or from a client disconnect.
//        roomChannel.onUnsubscribed = {
//            print("Unsubscribed")
//        }
//        
//        // The attempt at subscribing to a channel was rejected by the server.
//        roomChannel.onRejected = {
//            print("Rejected")
//        }
//        
//        
////        // Send an action
////        roomChannel["speak"](["message": "ID: 91408 Name: Ismail"])
//        
//        // Alternate less magical way:
//        roomChannel.action("speak", with: ["message": "ID: 91408 Name: Ismail"])
        
        // Note: The `speak` action must be defined already on the server
        
        
    }
    
    @IBOutlet weak var textFiled: UITextField!
    
    @IBAction func sendMessage(_ sender: Any) {
        
        if textFiled.text == "" {
            return
        }
        
        
        //        // Create the Room Channel
        //        let roomChannel = client.create("MessagesChannel") //The channel name must match the class name on the server
        
        // More advanced usage
        let room_identifier = ["room_id" : "1"]
        let roomChannel = client.create("MessagesChannel", identifier: room_identifier, autoSubscribe: true, bufferActions: true)  //The channel name must match the class name on the server
        
        // Receive a message from the server. Typically a Dictionary.
        roomChannel.onReceive = { (JSON : Any?, error : Error?) in
            print("Received", JSON, error)
        }
        
        // A channel has successfully been subscribed to.
        roomChannel.onSubscribed = {
            print("Yay!")
        }
        
        // A channel was unsubscribed, either manually or from a client disconnect.
        roomChannel.onUnsubscribed = {
            print("Unsubscribed")
        }
        
        // The attempt at subscribing to a channel was rejected by the server.
        roomChannel.onRejected = {
            print("Rejected")
        }
        
        // Alternate less magical way:
        roomChannel.action("subscribed", with: ["message": textFiled.text])
        
        textFiled.text = ""
        
        
        
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
