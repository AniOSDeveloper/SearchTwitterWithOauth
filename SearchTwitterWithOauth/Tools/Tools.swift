//
//  Tools.swift
//  SearchTwitterWithOauth
//
//  Created by Larry on 16/5/14.
//  Copyright © 2016年 Larry. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import Toast

class Tools: NSObject {
    
    static let mainWindow = UIApplication.sharedApplication().delegate!.window
    static let networkError = "网络异常，请稍后再试"
    static let checkEnabledLocation = "请检查网络和定位已开启"
    
    class func GetManager() -> AFHTTPSessionManager {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer  = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments)
        manager.requestSerializer.timeoutInterval = 10
        
        return manager
    }
    
    //base64编码
    class func base64(toBeEncodedStr:String)->String {
        
        let originData   = toBeEncodedStr.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = originData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions([]))
        return base64String
    }
    
    //获取本机国家编码和语言    
    class func getDeviceCountryCode() -> String {
        let code = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        return code
    }
    
    class func getDeviceLanguageCode() -> String {
        let code = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
        return code
    }

    //MARK: - 网络库的基本封装
    //basicNetwork,封装AFNetworking,以后的网络访问都要调用它
    class func basicGETNetwork(manager:AFHTTPSessionManager, urlString:String, parameter:[String:AnyObject], shouldShowHud:Bool , success:((AnyObject?) -> Void)?, failure:((NSError)->Void)? )  {
        
        if shouldShowHud {
            MBProgressHUD.showHUDAddedTo(mainWindow!, animated: true)
        }
        
        //只返回响应的数据
        manager.GET(urlString, parameters: parameter, progress: nil, success: { (task, responseObject) in
            
            if shouldShowHud {
                MBProgressHUD.hideAllHUDsForView(mainWindow!, animated: true)
            }
            
            success?(responseObject)
            
        }) { (task, error) in
            if shouldShowHud {
                MBProgressHUD.hideAllHUDsForView(mainWindow!, animated: true)
                mainWindow??.makeToast( networkError )
            }
            failure?(error)
        }
    }
    
    
    class func basicPOSTNetwork(manager:AFHTTPSessionManager, urlString:String, parameter:[String:AnyObject],shouldShowHud:Bool = true, success:((AnyObject?) -> Void)?, failure:((AnyObject?) -> Void)? ){
        
        manager.POST(urlString, parameters: parameter, progress: nil, success: { (task, responseObject) in
            
            if shouldShowHud{
                MBProgressHUD.hideAllHUDsForView(mainWindow!, animated: true)
            }
            
            success?(responseObject)
        }) { (task, error) in
            if shouldShowHud {
                MBProgressHUD.hideAllHUDsForView(mainWindow!, animated: true)
                mainWindow??.makeToast(networkError)
            }
            failure?(error)
        }
    }
    
    
    //MARK: - 网络的业务封装
    //获取token,组装queryHeader
    class func getTwitterOauth(success:((AnyObject?) -> Void)?, failure:((AnyObject?) -> Void)?) {
        
        let manager = Tools.GetManager()
        
        let AuthorizationValue = "Basic " + Constants.TwitterOauthKeys.encodeConsumerKey()
        
        //set HTTP header
        manager.requestSerializer.setValue(AuthorizationValue, forHTTPHeaderField: "Authorization")
        manager.requestSerializer.setValue("application/x-www-form-urlencoded;charset=UTF-8;application/json", forHTTPHeaderField: "Content-Type")
        
        let parameter = ["grant_type":"client_credentials"]
        
        Tools.basicPOSTNetwork(manager, urlString: Constants.TwitterApi.Oauth2, parameter: parameter, success: { (responseObject) in
                guard let responseDict = responseObject as? NSDictionary else{
                    return
                }
                
                let token = responseDict.valueForKey("access_token") as! String
                queryHeader = "Bearer " + token
                success?(queryHeader)
            
            }) { (error) in
                //print(#function)
                //print(error.debugDescription)
                failure?(error)
        }
    }
    
    //获取手机的公网ip，并返回 ISO_639-1_codes 的国家编码
    class func getCountryCodes(success:((String?) -> Void)?, failure:((String?) -> Void)?) {
  
        let manager = Tools.GetManager()
        manager.responseSerializer.acceptableContentTypes = Set(arrayLiteral: "application/json", "text/json", "text/javascript", "text/html")
        
        Tools.basicGETNetwork(manager, urlString: Constants.GetIPAdress.BaseUrlBak1, parameter: [:], shouldShowHud:false, success: { (responseObject) in
            
                guard let objects = responseObject as? [String:AnyObject] else{
                    return
                }
                
                let ipAdress = objects["ip"] as! String
                
                let parameter = ["ip":ipAdress]
                
                Tools.basicGETNetwork(manager, urlString: Constants.GetCountryCode.BaseUrl, parameter: parameter, shouldShowHud:false,  success: { (responseData) in
                    
                    guard let objectsData = responseData as? [String:AnyObject] where (objectsData["code"] as! Int) == 0 else{
                        return
                    }
                    
                    let data = objectsData["data"] as! [String:String]
                    language = (data["country_id"]! as String).lowercaseString
                    //print("self.code:\(language)")
                    success?(language)
                
                }, failure: { (error) in
                    failure?("")
                    //print(error)
            })
            
            }) { (error) in
                 print("ip.taobao.com error,\(error.description)")
        }
        
    }
    
    //获取每条Twitter的内容，以便将其作为model存储起来
    class func getTwittes(manager:AFHTTPSessionManager, subject:String, otherParameter:[String:AnyObject], resultClosure:((tweetes:[TwitteModel]?, sinceid:Int, maxid:Int)->Void))  {
        
        if queryHeader == "" {
            Tools.getTwitterOauth({ (header) in
                guard let newQueryHeader = header as? String else{
                    return
                }
                queryHeader = newQueryHeader
                print("queryHeader:\(newQueryHeader)")
                }, failure: nil)
        }
        
        manager.requestSerializer.setValue(queryHeader, forHTTPHeaderField: "Authorization")
        
        var parameter = [String:AnyObject]()
        
        let otherParameterKeysCount = otherParameter.keys.count
        
        if onlySearchNearByTweets {
            guard latitude != "" && longitude != "" && radius != "" && language != "" else{
                mainWindow??.makeToast(checkEnabledLocation)
                return
            }
            
            let geocode = latitude + "," + longitude + "," + radius
            let encodeGeo = (geocode as NSString).URLEncodedString()
            let encodeSubject = (subject as NSString).URLEncodedString()
            parameter =  ["q":encodeSubject, "geocode":encodeGeo!, "lang":language]
            
            if otherParameterKeysCount != 0 {
                for (key,value) in otherParameter {
                    parameter[key] = value
                }
            }
        }else{
            guard language != "" else{
                return
            }
            let encodeSubject = (subject as NSString).URLEncodedString()
            parameter =  ["q":encodeSubject, "lang":language]
            
            if otherParameterKeysCount != 0 {
                for (key,value) in otherParameter {
                    parameter[key] = value
                }
            }
        }
        
        //参数已经全部拿到，开始网络获取数据
        Tools.basicGETNetwork(manager, urlString: Constants.TwitterApi.SearchUrl, parameter: parameter,shouldShowHud: false, success: { (responseObject) in
            
                //print(responseObject?.description)
                
                guard let objects = responseObject as? [String:AnyObject] else{
                    return
                }
                
                guard let statuses = objects["statuses"] as? [[String:AnyObject]] else{
                    return
                }
                
                var newTweets = [TwitteModel]()
                var maxTmp = Int()//暂存返回id的值，只取它的最小值作为since_id值
            
                for num in 0..<statuses.count {
                    let item = statuses[num] as [String:AnyObject]
                
                    let twitterText = item["text"] as! String
                    let nickNameText = item["user"]!["name"] as! String
                    let userNameText = item["user"]!["screen_name"] as! String
                    let timeAgoText = item["created_at"] as! String
                    let headerIcon = item["user"]!["profile_image_url"] as! String
                    let id = item["id"] as! Int
                    
                    maxTmp = id
                    
                    //TODO:时间显示
                    //这里只简单处理下时间显示
                    let time = (timeAgoText as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:" "))[3]
                    
                    let twitte = TwitteModel(headerIcon: headerIcon, nickName: nickNameText, userName: userNameText, timeAgo: time, tweet: twitterText, id: id)
                    
                    newTweets.append(twitte)
                }
            
                guard let searchMetadata = objects["search_metadata"] as? [String:AnyObject] else{
                    return
                }
            
                let max = searchMetadata["max_id"] as! Int
                
                let sinceTmp = searchMetadata["since_id"] as! Int
                
                let since = (sinceTmp == 0) ? maxTmp : sinceTmp
                
                resultClosure(tweetes: newTweets, sinceid: since, maxid: max)
            
            }) { (error) in
                mainWindow??.makeToast(networkError)
        }
    }
}