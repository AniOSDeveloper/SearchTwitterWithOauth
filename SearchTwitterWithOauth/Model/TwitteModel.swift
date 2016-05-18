//
//  TwitteModel.swift
//  SearchTwitterWithOauth
//
//  Created by Larry on 16/5/16.
//  Copyright © 2016年 Larry. All rights reserved.
//

import UIKit

class TwitteModel: NSObject {

    var headerIcon: String
    var nickName: String?
    var userName: String?
    var timeAgo: String
    var tweet : String
    var id : Int
    
    
    init(headerIcon: String, nickName: String, userName: String, timeAgo: String, tweet : String, id:Int){
        
        self.headerIcon = headerIcon
        self.nickName   = nickName
        self.userName   = userName
        self.timeAgo    = timeAgo
        self.tweet      = tweet
        self.id         = id
    }
   
}
