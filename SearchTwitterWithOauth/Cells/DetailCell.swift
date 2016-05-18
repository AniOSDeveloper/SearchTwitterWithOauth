//
//  DetailCell.swift
//  SearchTwitterWithOauth
//
//  Created by Larry on 16/5/16.
//  Copyright © 2016年 Larry. All rights reserved.
//

import UIKit
import SDWebImage

class DetailCell: UITableViewCell {
    
    @IBOutlet weak var headerIcon: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configCells(twitte:TwitteModel) {
        
        if twitte.nickName != nil {
            nickName.text   = twitte.nickName!
        }else{
            nickName.text   = ""
        }
        
        if twitte.userName != nil {
            userName.text   = "@" + twitte.userName!
        }else{
            userName.text   = ""
        }
        
        timeAgo.text    = twitte.timeAgo
        tweetLabel.text = twitte.tweet
        
        headerIcon.sd_setImageWithURL(NSURL(string:twitte.headerIcon), placeholderImage: UIImage(named: "cat.png"))
    }
}
