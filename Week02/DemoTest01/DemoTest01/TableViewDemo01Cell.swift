//
//  tableViewCell.swift
//  DemoTest01
//
//  Created by sothea007 on 8/12/25.
//

import UIKit

class TableViewDemo01Cell: UITableViewCell {

    
    @IBOutlet weak var imageViewDemo    : UIImageView!
    @IBOutlet weak var TitleLable       : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
