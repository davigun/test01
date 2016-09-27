//
//  SearchVC.swift
//  Sunday School
//
//  Created by David Gunawan on 8/15/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var enterBtn: UIButton!
    
    var searchAnak = [Anak]()
    var filteredAnak = [Anak]()
    var selectedAnak: Anak!
    var inSearchMode = false
    var schedRef: FIRDatabaseReference!
    var currentDisciples: FIRDatabaseReference! = DataService.ds.REF_DISCIPLES
    var selectedSchedule: String!
    var isEntered = false
    var handleSearch: UInt!

    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.addDropShadow()
        searchBar.returnKeyType = UIReturnKeyType.done
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handleSearch = currentDisciples.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let anakDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let anak = Anak(discKey: key, discData: anakDict)
                        self.searchAnak.append(anak)
                    }
                }
            }
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        currentDisciples.removeObserver(withHandle: handleSearch)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredAnak.count
        }
        
        return searchAnak.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? SearchCell {
            
            let anak2: Anak!
            
            if inSearchMode {
                anak2 = filteredAnak[indexPath.row]
                cell.configureCell(anak: anak2)
            } else {
                anak2 = searchAnak[indexPath.row]
                cell.configureCell(anak: anak2)
            }
            return cell
        } else {
            return SearchCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedAnak = filteredAnak[indexPath.row]
        
        searchBar.text = selectedAnak.name
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            enterBtn.isUserInteractionEnabled = false
            tableView.isHidden = true
            view.endEditing(true)
            
        } else {
            
            inSearchMode = true
            enterBtn.isUserInteractionEnabled = true
            tableView.isHidden = false
            filteredAnak = searchAnak.filter({ (text) -> Bool in
                let tmp: Anak = text
                let range = tmp.name.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return (range != nil)
            })
            self.tableView.reloadData()
        }
        
    }
    
    
    @IBAction func backBtn(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func enterBtnTapped(_ sender: AnyObject) {
            
            KRProgressHUD.showSuccess(progressHUDStyle: .white, maskType: nil, activityIndicatorStyle: .white, font: nil, message: "Enrolled")
            
            schedRef = DataService.ds.REF_SCHEDULES.child(selectedSchedule).child("scheduleName").child("disciplesHere").child(selectedAnak.discKey)
            self.schedRef.setValue(true)
            
            KRProgressHUD.dismiss(nil)
            
            searchBar.text = ""
            
            self.view.endEditing(true)
            
            filteredAnak.removeAll()
            tableView.reloadData()
        }
}
