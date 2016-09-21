//
//  AddMenuVC.swift
//  Sunday School
//
//  Created by David Gunawan on 8/22/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD
import DeviceKit

class AddMenuVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var nameField: FancyField!
    @IBOutlet weak var addressField: FancyField!
    @IBOutlet weak var birthField: FancyField!
    @IBOutlet weak var phoneField: FancyField!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var addBtn: FancyBtn!
    
    
    var pickerData: [String] = [String]()
    var selectedClass: String!
    var origin = "PRJ"
    let device = Device()

    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.addDropShadow()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerData = ["Kana1", "Kana2", "Betlehem", "Yerusalem", "Sinai", "Yudea", "Galilea", "Samaria", "Nazareth", "Kanaan", "Yerikho"]
        
        genderSwitch.addTarget(self, action: #selector(switchChanged(genderSwitch:)), for: .valueChanged)
        genderSwitch.tintColor = UIColor.init(hexString: "#FF5855")
        genderSwitch.layer.cornerRadius = 16
        genderSwitch.backgroundColor = UIColor.init(hexString: "#FF5855")
        
        if device == .iPhone5 || device == .iPhone5s {
            
             NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
             NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        
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
        selectedClass = pickerData[row]
        self.view.endEditing(true)
    }
    
    func switchChanged(genderSwitch: UISwitch) {
        if genderSwitch.isOn {
            genderLbl.text = "Male"
        } else {
            genderLbl.text = "Female"
        }
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
    
    
    @IBAction func addBtnTapped(_ sender: AnyObject) {
        
        KRProgressHUD.showSuccess(progressHUDStyle: .white, maskType: nil, activityIndicatorStyle: .white, font: nil, message: "Added")
        
        let add: Dictionary<String, AnyObject> = [
            "name": nameField.text! as AnyObject,
            "address": addressField.text! as AnyObject,
            "birthday": birthField.text! as AnyObject,
            "phone": phoneField.text! as AnyObject,
            "gender": genderLbl.text!.lowercased() as AnyObject,
            "class": selectedClass! as AnyObject,
            "origin": origin as AnyObject
        ]
        
        let firebaseAdd = DataService.ds.REF_DISCIPLES.childByAutoId()
        firebaseAdd.setValue(add)
        
        
        nameField.text = ""
        addressField.text = ""
        birthField.text = ""
        phoneField.text = ""
        
        KRProgressHUD.dismiss(nil)
        
        self.view.endEditing(true)
    }

}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
