//
//  PostCell.swift
//  DisplayingPosts
//
//  Created by sothea007 on 15/12/25.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var UserIdLabel      : UILabel!
    @IBOutlet weak var UserTitleLabel   : UILabel!
    @IBOutlet weak var UserBodyLabel    : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setupView(post : Post) {
        UserIdLabel.text = "User \(post.id)"
        UserTitleLabel.text = "\(post.title)"
        UserBodyLabel.text = "\(post.body)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
