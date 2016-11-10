//
//  TweetCell.swift
//  Noon Twitter
//
//  Created by Dhiraj Jadhao on 09/11/16.
//  Copyright © 2016 Dhiraj Jadhao. All rights reserved.
//

import UIKit
import ActiveLabel

class TweetCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: ActiveLabel!
    @IBOutlet var retweetCountLabel: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        

    }

}
