//
//  LoginViewController.swift
//  Swift-ActionCableClient
//
//  Created by Ismail on 28/11/16.
//  Copyright © 2016 Proarch. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        if userNameLabel.text == "" {
            return
        }        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let destVC = storyboard.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
//        destVC.userName = userNameLabel.text
//        self.present(destVC, animated: false)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        destVC.userName = userNameLabel.text
        navigationController?.pushViewController(destVC, animated: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
