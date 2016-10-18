//
//  HomeVC.swift
//  Sunday School
//
//  Created by David Gunawan on 8/8/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit
import Firebase
import PMAlertController

class HomeVC: UIViewController {

    
    @IBOutlet weak var usernameTxt: FancyField!
    @IBOutlet weak var passwordTxt: FancyField!    
    @IBOutlet weak var headerView: HeaderView!
    var lastUsage: FIRDatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addDropShadow()
        
        hideKeyboardWhenTappedAround()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: KEY_UID) != nil {
            self.checkLogTime()
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
        }
    }

    @IBAction func logBtn(_ sender: AnyObject) {
        
        if let email = usernameTxt.text, let pwd = passwordTxt.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.checkLogTime()
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    let alert = PMAlertController(title: "Email / Password Wrong", description: "Please kindly check your email / password again", image: UIImage(named: "acc.png"), style: .alert)
                    
                    alert.addAction(PMAlertAction(title: "Ok", style: .default, action: { () in
                        print("Ok")
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
        
        }
    }
    
    func checkLogTime() {
        let userID = FIRAuth.auth()?.currentUser?.uid
        lastUsage = DataService.ds.REF_USERS.child(userID!)
        let calendar = NSCalendar.current
        let timeStamp = NSDate().timeIntervalSince1970
        lastUsage.observeSingleEvent(of: .value, with: { (snapshot) in
            let timeFromServer = snapshot.value as! [String : AnyObject]
            let timeInDecimal = timeFromServer["logTime"] as! Double
            let date = NSDate(timeIntervalSince1970: timeInDecimal)
            let currDate = NSDate(timeIntervalSince1970: timeStamp)
            let compServer = calendar.dateComponents([.year, .month, .day, .hour], from: date as Date)
            let compCurrent = calendar.dateComponents([.year, .month, .day, .hour], from: currDate as Date)
            let serverDay = compServer.day
            let currentDay = compCurrent.day
            if serverDay != currentDay {
                let editLog: Dictionary<String, AnyObject> = [
                    "logTime": timeStamp as AnyObject
                ]
                let firebaseEditTime = DataService.ds.REF_USERS.child(userID!)
                firebaseEditTime.updateChildValues(editLog)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        UserDefaults.standard.set(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
    }
        
}

