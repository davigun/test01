//
//  HomeVC.swift
//  Sunday School
//
//  Created by David Gunawan on 8/8/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {

    
    @IBOutlet weak var usernameTxt: FancyField!
    @IBOutlet weak var passwordTxt: FancyField!    
    @IBOutlet weak var headerView: HeaderView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addDropShadow()
        
        hideKeyboardWhenTappedAround()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: KEY_UID) != nil {
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
        }
    }

    @IBAction func logBtn(_ sender: AnyObject) {
        
        if let email = usernameTxt.text, let pwd = passwordTxt.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("DAVID: Email User authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("DAVID: Unable to authenticated with Firebase")
                        } else {
                            print("DAVID: Email User created in Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        UserDefaults.standard.set(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
    }
        
}

