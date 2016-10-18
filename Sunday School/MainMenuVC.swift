//
//  MainMenuVC.swift
//  Sunday School
//
//  Created by David Gunawan on 8/8/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit
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
    
    var isIr1Selected = true
    var isIr2Selected = false
    var isIr3Selected = false
    var isIr4Selected = false
    
    var totalCount = 0
    
    var selectedIbadahRaya: String! = "ibadah1"
    var currentIRDisciples: FIRDatabaseReference! = DataService.ds.REF_SCHEDULES
    
    var absenAnak = [Absen]()
    var absen1 = [Absen]()
    var absen2 = [Absen]()
    var absen3 = [Absen]()
    var absen4 = [Absen]()
    
    var jumlah1 = calc()
    var jumlah2 = calc()
    var jumlah3 = calc()
    var jumlah4 = calc()
    
    var irDisciples: FIRDatabaseReference! = DataService.ds.REF_SCHEDULES
    var handler: UInt!
    var btnHandler: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.addDropShadow()
        
        tableViewAbsen.delegate = self
        tableViewAbsen.dataSource = self
        btnIR1.setTitleColor(UIColor.black, for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        absenAnak.removeAll()
        handler = currentIRDisciples.observe(.childAdded, with: { (snapshot) in
            if let snapDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let anak = Absen(discKey: key, discData: snapDict)
                if anak.ibadah == "ibadah1" {
                    self.jumlah1.addCap(currGrade: anak.grade.lowercased())
                    self.absen1.append(anak)
                } else if anak.ibadah == "ibadah2" {
                    self.jumlah2.addCap(currGrade: anak.grade.lowercased())
                    self.absen2.append(anak)
                } else if anak.ibadah == "ibadah3" {
                    self.jumlah3.addCap(currGrade: anak.grade.lowercased())
                    self.absen3.append(anak)
                } else if anak.ibadah == "ibadah4" {
                    self.jumlah4.addCap(currGrade: anak.grade.lowercased())
                    self.absen4.append(anak)
                }
            }; DispatchQueue.main.async {
                self.totalAnakLbl.text = "\(self.totalCount)"
                self.refreshTable()
            }
        }) { (error) in
            print(error)
        }    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        currentIRDisciples.removeObserver(withHandle: handler)
        absenAnak.removeAll()
        absen1.removeAll()
        absen2.removeAll()
        absen3.removeAll()
        absen4.removeAll()
        jumlah1.emptyAll()
        jumlah2.emptyAll()
        jumlah3.emptyAll()
        jumlah4.emptyAll()
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
    
    func retrieveDisciplesInSchedule(waktuIbadah: String!) {
        self.absenAnak.removeAll()
        
        if waktuIbadah == "ibadah1" {
            self.absenAnak = self.absen1
            fillGradeLabel(currSched: "j1")
        } else if waktuIbadah == "ibadah2" {
            self.absenAnak = self.absen2
            fillGradeLabel(currSched: "j2")
        } else if waktuIbadah == "ibadah3" {
            self.absenAnak = self.absen3
            fillGradeLabel(currSched: "j3")
        } else if waktuIbadah == "ibadah4" {
            self.absenAnak = self.absen4
            fillGradeLabel(currSched: "j4")
        }
        self.absenAnak.sort { $0.name < $1.name }
        tableViewAbsen.reloadData()
    }
   
    func refreshTable() {
        if isIr1Selected {
            self.absenAnak = self.absen1
            fillGradeLabel(currSched: "j1")
        } else if isIr2Selected {
            self.absenAnak = self.absen2
            fillGradeLabel(currSched: "j2")
        } else if isIr3Selected {
            self.absenAnak = self.absen3
            fillGradeLabel(currSched: "j3")
        } else if isIr4Selected {
            self.absenAnak = self.absen4
            fillGradeLabel(currSched: "j4")
        }
        self.absenAnak.sort { $0.name < $1.name }
        tableViewAbsen.reloadData()
    }
    
    func fillGradeLabel(currSched: String!) {
        
        if currSched == "j1" {
            self.kana1Total.text = "\(self.jumlah1.kana1)"
            self.kana2Total.text = "\(self.jumlah1.kana2)"
            self.betlehemTotal.text = "\(self.jumlah1.betlehem)"
            self.yerusalemTotal.text = "\(self.jumlah1.yerusalem)"
            self.sinaiTotal.text = "\(self.jumlah1.sinai)"
            self.yudeaTotal.text = "\(self.jumlah1.yudea)"
            self.galileaTotal.text = "\(self.jumlah1.galilea)"
            self.samariaTotal.text = "\(self.jumlah1.samaria)"
            self.kanaanTotal.text = "\(self.jumlah1.kanaan)"
            self.nazarethTotal.text = "\(self.jumlah1.nazareth)"
            self.yerikhoTotal.text = "\(self.jumlah1.yerikho)"
            self.totalBySchedule.text = "\(self.jumlah1.getTotal(input: 0))"
        } else if currSched == "j2" {
            self.kana1Total.text = "\(self.jumlah2.kana1)"
            self.kana2Total.text = "\(self.jumlah2.kana2)"
            self.betlehemTotal.text = "\(self.jumlah2.betlehem)"
            self.yerusalemTotal.text = "\(self.jumlah2.yerusalem)"
            self.sinaiTotal.text = "\(self.jumlah2.sinai)"
            self.yudeaTotal.text = "\(self.jumlah2.yudea)"
            self.galileaTotal.text = "\(self.jumlah2.galilea)"
            self.samariaTotal.text = "\(self.jumlah2.samaria)"
            self.kanaanTotal.text = "\(self.jumlah2.kanaan)"
            self.nazarethTotal.text = "\(self.jumlah2.nazareth)"
            self.yerikhoTotal.text = "\(self.jumlah2.yerikho)"
            self.totalBySchedule.text = "\(self.jumlah2.getTotal(input: 0))"
        } else if currSched == "j3" {
            self.kana1Total.text = "\(self.jumlah3.kana1)"
            self.kana2Total.text = "\(self.jumlah3.kana2)"
            self.betlehemTotal.text = "\(self.jumlah3.betlehem)"
            self.yerusalemTotal.text = "\(self.jumlah3.yerusalem)"
            self.sinaiTotal.text = "\(self.jumlah3.sinai)"
            self.yudeaTotal.text = "\(self.jumlah3.yudea)"
            self.galileaTotal.text = "\(self.jumlah3.galilea)"
            self.samariaTotal.text = "\(self.jumlah3.samaria)"
            self.kanaanTotal.text = "\(self.jumlah3.kanaan)"
            self.nazarethTotal.text = "\(self.jumlah3.nazareth)"
            self.yerikhoTotal.text = "\(self.jumlah3.yerikho)"
            self.totalBySchedule.text = "\(self.jumlah3.getTotal(input: 0))"
        } else if currSched == "j4" {
            self.kana1Total.text = "\(self.jumlah4.kana1)"
            self.kana2Total.text = "\(self.jumlah4.kana2)"
            self.betlehemTotal.text = "\(self.jumlah4.betlehem)"
            self.yerusalemTotal.text = "\(self.jumlah4.yerusalem)"
            self.sinaiTotal.text = "\(self.jumlah4.sinai)"
            self.yudeaTotal.text = "\(self.jumlah4.yudea)"
            self.galileaTotal.text = "\(self.jumlah4.galilea)"
            self.samariaTotal.text = "\(self.jumlah4.samaria)"
            self.kanaanTotal.text = "\(self.jumlah4.kanaan)"
            self.nazarethTotal.text = "\(self.jumlah4.nazareth)"
            self.yerikhoTotal.text = "\(self.jumlah4.yerikho)"
            self.totalBySchedule.text = "\(self.jumlah4.getTotal(input: 0))"
        }
    }
    
    func deleteDataInSchedule() {
        DataService.ds.REF_SCHEDULES.removeValue()
        absenAnak.removeAll()
        absen1.removeAll()
        absen2.removeAll()
        absen3.removeAll()
        absen4.removeAll()
        tableViewAbsen.reloadData()
    }
    
    func makeZero() {
        kana1Total.text = "0"
        kana2Total.text = "0"
        betlehemTotal.text = "0"
        yerusalemTotal.text = "0"
        sinaiTotal.text = "0"
        yudeaTotal.text = "0"
        samariaTotal.text = "0"
        galileaTotal.text = "0"
        kanaanTotal.text = "0"
        nazarethTotal.text = "0"
        yerikhoTotal.text = "0"
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
        
        performSegue(withIdentifier: SEGUE_SEARCH, sender: UITextField.self)
    }
    
    @IBAction func searchBtnOnClick(_ sender: AnyObject) {
            
        performSegue(withIdentifier: SEGUE_SEARCH, sender: UIButton.self)
    }
    
}

struct calc {
    
    var kana1 = 0
    var kana2 = 0
    var betlehem = 0
    var yerusalem = 0
    var sinai = 0
    var yudea = 0
    var galilea = 0
    var samaria = 0
    var kanaan = 0
    var nazareth = 0
    var yerikho = 0
    
    var total = 0
    
    mutating func addCap(currGrade: String!){
        
        if currGrade == KANA1 {
            kana1 += 1
        } else if currGrade == KANA2 {
            kana2 += 1
        } else if currGrade == BETLEHEM {
            betlehem += 1
        } else if currGrade == YERUSALEM {
            yerusalem += 1
        } else if currGrade == SINAI {
            sinai += 1
        } else if currGrade == YUDEA {
            yudea += 1
        } else if currGrade == SAMARIA {
            samaria += 1
        } else if currGrade == GALILEA {
            galilea += 1
        } else if currGrade == KANAAN {
            kanaan += 1
        } else if currGrade == NAZARETH {
            nazareth += 1
        } else if currGrade == YERIKHO {
            yerikho += 1
        }
    }
    
    mutating func getTotal(input: Int) -> Int {
        
        total = kana1 + kana2 + betlehem + yerusalem + sinai + yudea + galilea + samaria + kanaan + nazareth + yerikho
        return total
    }
    
    mutating func emptyAll() {
        
        kana1 = 0
        kana2 = 0
        betlehem = 0
        yerusalem = 0
        sinai = 0
        yudea = 0
        galilea = 0
        samaria = 0
        kanaan = 0
        nazareth = 0
        yerikho = 0
    }
}
