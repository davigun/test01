//
//  TweakMenuVC.swift
//  Sunday School
//
//  Created by David Gunawan on 8/8/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD
import PMAlertController

class TweakMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var editBtn: FancyBtn!
    
    var pickerData: [String] = [String]()
    var selectedClass: String!
    var dataAnak = [Anak]()
    var disciplesOnClass: FIRDatabaseReference!
    var editedKey: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.addDropShadow()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerData = ["Kana1", "Kana2", "Betlehem", "Yerusalem", "Sinai", "Yudea", "Galilea", "Samaria", "Nazareth", "Kanaan", "Yerikho"]
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        hideKeyboardWhenTappedAround()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedClass = pickerData[row].lowercased()
        dataAnak.removeAll()
        retrieveDisciplesInClass(selectedClass: selectedClass)
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAnak.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cellData = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as? DataCell {
            let anak = dataAnak[indexPath.row]
            cellData.configureCell(anak: anak)
            return cellData
        } else {
            return AbsenCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data: Anak!
        
        data = dataAnak[indexPath.row]
        
        nameField.text = data.name
        nameField.isEnabled = true
        addressField.text = data.address
        addressField.isEnabled = true
        birthField.text = data.birthday
        birthField.isEnabled = true
        phoneField.text = data.phone
        phoneField.isEnabled = true
        
        editedKey = data.discKey
    }
    
    func retrieveDisciplesInClass(selectedClass: String!) {
        
        disciplesOnClass = DataService.ds.REF_DISCIPLES
        
        disciplesOnClass.observe( .value, with:  { (snapshot) in
            self.dataAnak.removeAll()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let anakDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let anak = Anak(discKey: key, discData: anakDict)
                        if anak.grade.lowercased() == selectedClass {
                            self.dataAnak.append(anak)
                        }
                    }
                }
            }
            self.dataAnak.sort { $0.name < $1.name }
            self.tableView.reloadData()
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func upBtnTapped(_ sender: AnyObject) {
        
        let alert = PMAlertController(title: "Upgrade", description: "By pressing this button, you will upgrade their grade", image: UIImage(named: "clock.png"), style: .alert)
        
        alert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
            print("Cancel")
        }))
        
        alert.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
            print("Ok")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func editBtnTapped(_ sender: AnyObject) {
        
        KRProgressHUD.showSuccess(progressHUDStyle: .white, maskType: nil, activityIndicatorStyle: .white, font: nil, message: "Updated")
        
        let edit: Dictionary<String, AnyObject> = [
            "name": nameField.text! as AnyObject,
            "address": addressField.text! as AnyObject,
            "birthday": birthField.text! as AnyObject,
            "phone": phoneField.text! as AnyObject
        ]
        
        let firebaseEditName = DataService.ds.REF_DISCIPLES.child(editedKey)
        firebaseEditName.updateChildValues(edit)
        
        nameField.text = ""
        addressField.text = ""
        birthField.text = ""
        phoneField.text = ""
        
        KRProgressHUD.dismiss(nil)
        
        self.view.endEditing(true)
        
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
