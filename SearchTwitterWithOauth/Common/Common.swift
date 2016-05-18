//
//  Common.swift
//  SearchTwitterWithOauth
//
//  Created by Larry on 16/5/14.
//  Copyright © 2016年 Larry. All rights reserved.
//

import Foundation

    public var queryHeader = ""

    public var onlySearchNearByTweets = false

    public var longitude = ""

    public var latitude = ""

    public var radius = "1000km"

    public var language = "en"

    //获取Twitter数据有关‘page’的参数，默认获取15条推
    public var sinceID = 0
    public var maxID = 0

    public var settedRadius:Float = 100//默认的搜索距离，单位km

struct Constants {
    
    struct TwitterApi {
        static let BaseUrl   = "https://api.twitter.com/"
        static let Oauth2    = "https://api.twitter.com/oauth2/token"
        static let SearchUrl = "https://api.twitter.com/1.1/search/tweets.json"
    }
    
    struct TwitterOauthKeys {
        static let ConsumerKey = "你的ConsumerKey"
        static let ConsumerSecret = "你的ConsumerSecret"
        
        static func encodeConsumerKey() -> String {
            
            let ConsumerKeyAndConsumerSecret = ConsumerKey + ":" + ConsumerSecret
            
            let encodedConsumerKeyAndConsumerSecret = Tools.base64(ConsumerKeyAndConsumerSecret)
            
            return encodedConsumerKeyAndConsumerSecret
        }
    }
  
    struct GetIPAdress {
        static let BaseUrl = "http://ipof.in/json"//返回经常超时
        static let BaseUrlBak1 = "http://geoip.nekudo.com/api" //备用,和BaseUrl解析ip地址的顺序一致
        
    }
    
    struct GetCountryCode {
        static let BaseUrl = "http://ip.taobao.com/service/getIpInfo.php"
    }
    
    static func setUserDefaults() {
        
        let onlySearchNearByDefault = false
        let useLocalLanguage        = true
        let defaultRadius:Float     = 100
        
        NSUserDefaults.standardUserDefaults().setBool(onlySearchNearByDefault, forKey: "onlySearchNearBy")
        NSUserDefaults.standardUserDefaults().setFloat(defaultRadius, forKey: "settedRadius")
        NSUserDefaults.standardUserDefaults().setBool(useLocalLanguage, forKey: "shouldUseLocalLanguage")
    }
    
    struct AlertMessages {
        static let noMoreData = "没有更多数据"
    }
}



