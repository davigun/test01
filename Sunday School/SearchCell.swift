//
//  SearchCell.swift
//  Sunday School
//
//  Created by David Gunawan on 8/15/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    
    var anak: Anak!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(anak: Anak){
        self.nameLbl.text = anak.name
        self.gradeLbl.text = anak.grade
    }

}
