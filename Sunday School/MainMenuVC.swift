//
//  MainMenuVC.swift
//  Sunday School
//
//  Created by David Gunawan on 8/8/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit
import PMAlertController
import Firebase
import SwiftyTimer

class MainMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var btnIR1: UIButton!
    @IBOutlet weak var btnIR2: UIButton!
    @IBOutlet weak var btnIR3: UIButton!
    @IBOutlet weak var btnIR4: UIButton!
    @IBOutlet weak var tableViewAbsen: UITableView!
    @IBOutlet weak var totalAnakLbl: UILabel!
    
    @IBOutlet weak var kana1Total: UILabel!
    @IBOutlet weak var kana2Total: UILabel!
    @IBOutlet weak var betlehemTotal: UILabel!
    @IBOutlet weak var yerusalemTotal: UILabel!
    @IBOutlet weak var sinaiTotal: UILabel!
    @IBOutlet weak var yudeaTotal: UILabel!
    @IBOutlet weak var samariaTotal: UILabel!
    @IBOutlet weak var galileaTotal: UILabel!
    @IBOutlet weak var kanaanTotal: UILabel!
    @IBOutlet weak var nazarethTotal: UILabel!
    @IBOutlet weak var yerikhoTotal: UILabel!
    @IBOutlet weak var totalBySchedule: UILabel!
    
    var isIr1Selected = false
    var isIr2Selected = false
    var isIr3Selected = false
    var isIr4Selected = false
    
    var kana1Count: Int = 0
    var kana2Count: Int = 0
    var betlehemCount: Int = 0
    var yerusalemCount: Int = 0
    var sinaiCount: Int = 0
    var yudeaCount: Int = 0
    var samariaCount: Int = 0
    var galileaCount: Int = 0
    var kanaanCount: Int = 0
    var nazarethCount: Int = 0
    var yerikhoCount: Int = 0
    var totalCount: Int = 0
    
    var selectedIbadahRaya: String!
    var currentDisciples: FIRDatabaseReference!
    var checkDisciples: FIRDatabaseQuery!
    var lastUsage: FIRDatabaseReference!
    
    
    var absenAnak = [Anak]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.addDropShadow()
        
        tableViewAbsen.delegate = self
        tableViewAbsen.dataSource = self
        
        checkLogTime()
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        return absenAnak.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableViewAbsen {
            let cellAbsen = tableView.dequeueReusableCell(withIdentifier: "absenCell", for: indexPath) as! AbsenCell
            let anak = absenAnak[indexPath.row]
            cellAbsen.configureCell(anak: anak)
            return cellAbsen
        } else {
            return AbsenCell()
        }
    }
    
    func showAlert() {
        
        let alert = PMAlertController(title: "Schedule not selected", description: "Choose Ibadah Raya time for absent.", image: UIImage(named: "clock.png"), style: .alert)
        
        alert.addAction(PMAlertAction(title: "Ok", style: .default, action: { () in
            print("Ok")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func retrieveDisciplesInSchedule(waktuIbadah: String!) {
        
        currentDisciples = DataService.ds.REF_SCHEDULES.child(waktuIbadah).child("scheduleName").child("disciplesHere")
        checkDisciples = DataService.ds.REF_DISCIPLES.queryOrdered(byChild: "name")
        self.absenAnak.removeAll()
        self.tableViewAbsen.reloadData()
        currentDisciples.observe( .value, with: {(snapshotschedule) in
            if let snapshotSched = snapshotschedule.children.allObjects as? [FIRDataSnapshot] {
                for snap1 in snapshotSched {
                    self.absenAnak.removeAll() // might not be the best
                    self.makeZero() // this too
                    let discKey = snap1.key
                    self.checkDisciples.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                            for snap in snapshot {
                                if let anakDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    if key == discKey {
                                        let anak = Anak(discKey: key, discData: anakDict)
                                        self.countGrade(discGrade: anak.grade.lowercased())
                                        self.absenAnak.append(anak)
                                    }
                                }
                            }
                        }
                        self.totalBySchedule.text = "\(self.totalCount)"
                        self.tableViewAbsen.reloadData()
                    })
                }
            }
        })
    }
    
    func checkLogTime() {
        let userID = FIRAuth.auth()?.currentUser?.uid
        lastUsage = DataService.ds.REF_USERS.child(userID!)
        let timeStamp = NSDate().timeIntervalSince1970
        lastUsage.observeSingleEvent(of: .value, with: { (snapshot) in
            let timeFromServer = snapshot.value as! [String : AnyObject]
            let timeInDecimal = timeFromServer["logTime"] as! Double
            let date = NSDate(timeIntervalSince1970: timeInDecimal)
            let elapsedTime = NSDate().timeIntervalSince(date as Date)
            let duration = Int(elapsedTime)
            if duration > 86400 {
                let editLog: Dictionary<String, AnyObject> = [
                    "logTime": timeStamp as AnyObject
                ]
                let firebaseEditTime = DataService.ds.REF_USERS.child(userID!)
                firebaseEditTime.updateChildValues(editLog)
                self.deleteDataInSchedule()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func deleteDataInSchedule() {
        let ibadah1Clear = DataService.ds.REF_SCHEDULES.child("ibadah1").child("scheduleName").child("disciplesHere")
        ibadah1Clear.removeValue()
        let ibadah2Clear = DataService.ds.REF_SCHEDULES.child("ibadah2").child("scheduleName").child("disciplesHere")
        ibadah2Clear.removeValue()
        let ibadah3Clear = DataService.ds.REF_SCHEDULES.child("ibadah3").child("scheduleName").child("disciplesHere")
        ibadah3Clear.removeValue()
        let ibadah4Clear = DataService.ds.REF_SCHEDULES.child("ibadah4").child("scheduleName").child("disciplesHere")
        ibadah4Clear.removeValue()
    }
    
    func countGrade(discGrade: String!) {
        
        if discGrade == KANA1 {
            kana1Count += 1
            totalCount += 1
            kana1Total.text = "\(kana1Count)"
        } else if discGrade == KANA2 {
            kana2Count += 1
            totalCount += 1
            kana2Total.text = "\(kana2Count)"
        } else if discGrade == BETLEHEM {
            betlehemCount += 1
            totalCount += 1
            betlehemTotal.text = "\(betlehemCount)"
        } else if discGrade == YERUSALEM {
            yerusalemCount += 1
            totalCount += 1
            yerusalemTotal.text = "\(yerusalemCount)"
        } else if discGrade == SINAI {
            sinaiCount += 1
            totalCount += 1
            sinaiTotal.text = "\(sinaiCount)"
        } else if discGrade == YUDEA {
            yudeaCount += 1
            totalCount += 1
            yudeaTotal.text = "\(yudeaCount)"
        } else if discGrade == SAMARIA {
            samariaCount += 1
            totalCount += 1
            samariaTotal.text = "\(samariaCount)"
        } else if discGrade == GALILEA {
            galileaCount += 1
            totalCount += 1
            galileaTotal.text = "\(galileaCount)"
        } else if discGrade == KANAAN {
            kanaanCount += 1
            totalCount += 1
            kanaanTotal.text = "\(kanaanCount)"
        } else if discGrade == NAZARETH {
            nazarethCount += 1
            totalCount += 1
            nazarethTotal.text = "\(nazarethCount)"
        } else if discGrade == YERIKHO {
            yerikhoCount += 1
            totalCount += 1
            yerikhoTotal.text = "\(yerikhoCount)"
        }
        
    }
    
    func makeZero() {
        kana1Count = 0
        kana1Total.text = "0"
        kana2Count = 0
        kana2Total.text = "0"
        betlehemCount = 0
        betlehemTotal.text = "0"
        yerusalemCount = 0
        yerusalemTotal.text = "0"
        sinaiCount = 0
        sinaiTotal.text = "0"
        yudeaCount = 0
        yudeaTotal.text = "0"
        samariaCount = 0
        samariaTotal.text = "0"
        galileaCount = 0
        galileaTotal.text = "0"
        kanaanCount = 0
        kanaanTotal.text = "0"
        nazarethCount = 0
        nazarethTotal.text = "0"
        yerikhoCount = 0
        yerikhoTotal.text = "0"
        totalCount = 0
        totalBySchedule.text = "0"
    }
    
    @IBAction func btnIR1Pressed(_ sender: UIButton) {
        
        if isIr1Selected == false {
            btnIR1.setTitleColor(UIColor.black, for: .normal)
            isIr1Selected = true
            makeZero()
            selectedIbadahRaya = "ibadah1"
            retrieveDisciplesInSchedule(waktuIbadah: selectedIbadahRaya)
            searchTxt.isUserInteractionEnabled = true
    
            btnIR2.setTitleColor(UIColor.lightGray, for: .normal)
            isIr2Selected = false
            btnIR3.setTitleColor(UIColor.lightGray, for: .normal)
            isIr3Selected = false
            btnIR4.setTitleColor(UIColor.lightGray, for: .normal)
            isIr4Selected = false
        }
        self.view.endEditing(true)
        
    }
    @IBAction func btnIR2Pressed(_ sender: UIButton) {
        
        if isIr2Selected == false {
            btnIR2.setTitleColor(UIColor.black, for: .normal)
            isIr2Selected = true
            makeZero()
            selectedIbadahRaya = "ibadah2"
            retrieveDisciplesInSchedule(waktuIbadah: selectedIbadahRaya)
            searchTxt.isUserInteractionEnabled = true
        
            btnIR1.setTitleColor(UIColor.lightGray, for: .normal)
            isIr1Selected = false
            btnIR3.setTitleColor(UIColor.lightGray, for: .normal)
            isIr3Selected = false
            btnIR4.setTitleColor(UIColor.lightGray, for: .normal)
            isIr4Selected = false
        }
        self.view.endEditing(true)
    }
    @IBAction func btnIR3Pressed(_ sender: UIButton) {
        
        if isIr3Selected == false {
            btnIR3.setTitleColor(UIColor.black, for: .normal)
            isIr3Selected = true
            makeZero()
            selectedIbadahRaya = "ibadah3"
            retrieveDisciplesInSchedule(waktuIbadah: selectedIbadahRaya)
            searchTxt.isUserInteractionEnabled = true
        
            btnIR2.setTitleColor(UIColor.lightGray, for: .normal)
            isIr2Selected = false
            btnIR1.setTitleColor(UIColor.lightGray, for: .normal)
            isIr1Selected = false
            btnIR4.setTitleColor(UIColor.lightGray, for: .normal)
            isIr4Selected = false
        }
        self.view.endEditing(true)
    }
    @IBAction func btnIR4Pressed(_ sender: UIButton) {
        
        if isIr4Selected == false {
            btnIR4.setTitleColor(UIColor.black, for: .normal)
            isIr4Selected = true
            makeZero()
            selectedIbadahRaya = "ibadah4"
            retrieveDisciplesInSchedule(waktuIbadah: selectedIbadahRaya)
            searchTxt.isUserInteractionEnabled = true
        
            btnIR2.setTitleColor(UIColor.lightGray, for: .normal)
            isIr2Selected = false
            btnIR3.setTitleColor(UIColor.lightGray, for: .normal)
            isIr3Selected = false
            btnIR1.setTitleColor(UIColor.lightGray, for: .normal)
            isIr1Selected = false
        }
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_SEARCH {
            if let searchVC = segue.destination as? SearchVC {
                searchVC.selectedSchedule = selectedIbadahRaya
            }
        }
    }
    
    
    @IBAction func searchOnClick(_ sender: AnyObject) {
        
        if isIr1Selected == false && isIr2Selected == false && isIr3Selected == false && isIr4Selected == false {
            
            showAlert()
            
        } else {
        
            performSegue(withIdentifier: SEGUE_SEARCH, sender: UITextField.self)
        }
    }
    
    @IBAction func searchBtnOnClick(_ sender: AnyObject) {
        
        if isIr1Selected == false && isIr2Selected == false && isIr3Selected == false && isIr4Selected == false {
            
            showAlert()
            
        } else {
            
            performSegue(withIdentifier: SEGUE_SEARCH, sender: UIButton.self)
        }
    }
    
}
