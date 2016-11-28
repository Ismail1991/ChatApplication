//
//  Copyright (c) 2016 Daniel Rhodes <rhodes.daniel@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
//  USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import ActionCableClient //https://github.com/danielrhodes/Swift-ActionCableClient
import SnapKit //https://github.com/SnapKit/SnapKit
import SwiftyJSON //https://github.com/SwiftyJSON/SwiftyJSON


class ChatViewController: UIViewController {
    static var MessageCellIdentifier = "MessageCell"
    static var ChannelIdentifier = "MessagesChannel"//ChatChannel
    static var ChannelAction = "talk"
    
    let client = ActionCableClient(url: URL(string:"ws://192.168.20.118:3005/cable")!)//"wss://actioncable-echo.herokuapp.com/cable"
    
    var channel: Channel?
    
    var history: Array<ChatMessage> = Array()
    var userName: String?
    
    var chatView: ChatView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chat"
        
        client.origin = "http://192.168.20.118:3005"
        
        chatView = ChatView(frame: view.bounds)//view.bounds//frame: CGRect(x: 0, y: 500, width: view.bounds.width, height: view.bounds.height-50)
        view.addSubview(chatView!)
        
        chatView?.snp.remakeConstraints({ (make) -> Void in
            make.top.equalTo(0)
            make.bottom.left.right.equalTo(self.view)
        })
        
        chatView?.tableView.delegate = self
        chatView?.tableView.dataSource = self
        chatView?.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        chatView?.tableView.allowsSelection = false
        chatView?.tableView.register(ChatCell.self, forCellReuseIdentifier: ChatViewController.MessageCellIdentifier)
        chatView?.tableView.separatorStyle = .none
        
        chatView?.textField.delegate = self
        
        setupClient()
        
        let leftItem = UIBarButtonItem(title: "Logout",
                                       style: UIBarButtonItemStyle.plain,
                                       target: self,
                                       action: #selector(ChatViewController.Logout))
        self.navigationItem.rightBarButtonItem = leftItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let alert = UIAlertController(title: "Chat", message: "What's Your Name?", preferredStyle: UIAlertControllerStyle.alert)
//        
//        var nameTextField: UITextField?
//        alert.addTextField(configurationHandler: {(textField: UITextField!) in
//            textField.placeholder = "Name"
//            nameTextField = textField
//        })
//        
//        alert.addAction(UIAlertAction(title: "Start", style: UIAlertActionStyle.default) {(action: UIAlertAction) in
//            self.userName = nameTextField?.text
            self.chatView?.textField.becomeFirstResponder()
            
            let interface : JsonResponse = JsonResponse()
            interface.delegate = self
            interface.getResponse(url: "http://192.168.20.118:3005/messages/1/list.json")
//        })
//        
//        self.present(alert, animated: true, completion: nil)
    }
    
    func Logout() {
        self.navigationController?.popToRootViewController(animated: false)
    }
}

// MARK: ActionCableClient
extension ChatViewController {
    
    func setupClient() -> Void {
      
          self.client.willConnect = {
              print("Will Connect")
          }
          
          self.client.onConnected = {
              print("Connected to \(self.client.url)")
          }
          
          self.client.onDisconnected = {(error: ConnectionError?) in
              print("Disconected with error: \(error)")
          }
          
          self.client.willReconnect = {
              print("Reconnecting to \(self.client.url)")
              return true
          }
          
          self.channel = client.create(ChatViewController.ChannelIdentifier)
          self.channel?.onSubscribed = {
              print("Subscribed to \(ChatViewController.ChannelIdentifier)")
          }
        
          self.channel?.onReceive = {(data: Any?, error: Error?) in
            if let _ = error {
                print(error)
                return
            }
            
            let JSONObject = JSON(data!)
            let msg = ChatMessage(name: JSONObject["user"].string!, message: JSONObject["message"].string!)
            
            self.history.append(msg)
            self.chatView?.tableView.reloadData()
            
            
            // Scroll to our new message!
//            if (msg.name == self.name) {
            let indexPath = IndexPath(row: self.history.count - 1, section: 0)
            self.chatView?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//            }
        }
        
        self.client.connect()
    }
    
    func sendMessage(_ message: String) {
        let prettyMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!prettyMessage.isEmpty) {
//            print("Sending Message: \(ChatViewController.ChannelIdentifier)#\(ChatViewController.ChannelAction)")
//            let _ = self.channel?.action(ChatViewController.ChannelAction, with:
//              ["name": self.name!, "message": prettyMessage]
//           )
            
            
            let url:NSURL = NSURL(string: "http://192.168.20.118:3005/messages.json")!
            let request:NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            let username = self.userName!
            
            let parameters = ["message":["content":prettyMessage,"chatroom_id":"1"], "username":username] as [String : Any]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print(error)
            }
            
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                guard data != nil else {
                    print("no data found: \(error!)")
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "Request time out.", message: "Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                    return
                }
                
                // Added from stack over flow
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        let success = json["success"] as? Int                                  // Okay, the `json` is here, let's get the value for 'success' out of it
                        print("Success: \(success)")
                    } else {
                        let jsonStr = String(data: data!, encoding: .utf8)    // No error thrown, but not dictionary
                        print("Error could not parse JSON: \(jsonStr)")
                    }
                } catch let parseError {
                    print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                    let jsonStr = String(data: data!, encoding: .utf8)
                    print("Error could not parse JSON: '\(jsonStr)'")
                }
            }
            task.resume()
        }
    }
}

//MARK: UITextFieldDelegate
extension ChatViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.history.count > 0 {
            DispatchQueue.main.async() {
                let indexPath = IndexPath(row: self.history.count - 1, section: 0)
                self.chatView?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendMessage(textField.text!)
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
}

//MARK: UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = history[(indexPath as NSIndexPath).row]
        let height = message.heightForView(width: ChatCell.width)
        return height + (ChatCell.Inset * 2) //2.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.frame.width, height: 25)))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 25))
        label.text = ChatViewController.ChannelIdentifier
        label.textAlignment = .center
        headerView.addSubview(label)
        label.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        return headerView
    }
}

//MARK: UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatViewController.MessageCellIdentifier, for: indexPath) as! ChatCell
        let msg = history[(indexPath as NSIndexPath).row]
        cell.message = msg
        cell.chatCell(name: self.userName!)        
        return cell
    }
}

//MARK: interfaceDelegae method
extension ChatViewController: interfaceDelegae {
    func handleData(respData:NSArray) {
        for index in stride(from: 0, to: respData.count, by: 1) {
            let data = respData[index] as! NSDictionary
            let msg = ChatMessage(name: data["username"]! as! String, message: data["content"]! as! String)
            self.history.append(msg)
        }
        DispatchQueue.main.async() {
            self.chatView?.tableView.reloadData()
            let indexPath = IndexPath(row: self.history.count - 1, section: 0)
            self.chatView?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
}

//MARK: ChatMessage
struct ChatMessage {
    var name: String
    var message: String
    
    func heightForView(width: CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width, height:CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.text = message
        
        label.sizeToFit()
        return label.frame.height
    }
}
