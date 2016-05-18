//
//  SettingTableVC.swift
//  SearchTwitterWithOauth
//
//  Created by Larry on 16/5/16.
//  Copyright © 2016年 Larry. All rights reserved.
//

import UIKit

class SettingTableVC: UITableViewController {

    let sectionHeaderNames = ["设置选项","搜索选项"]
    
    //只搜索附近，默认为false。只有为true时，搜索半径的设置才有意义
    @IBOutlet weak var onlySearchNearBy: UISwitch!
    
    //搜索半径，0~5000km，默认为100km
    @IBOutlet weak var searchDistance: UISlider!
    @IBOutlet weak var showDistance: UILabel!

    //使用本机语言，默认为false
    @IBOutlet weak var onlyUseLocalLanguage: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configUI()  {
        onlySearchNearBy.on     = NSUserDefaults.standardUserDefaults().boolForKey("onlySearchNearBy")
        searchDistance.value    = NSUserDefaults.standardUserDefaults().floatForKey("settedRadius")
        onlyUseLocalLanguage.on = NSUserDefaults.standardUserDefaults().boolForKey("shouldUseLocalLanguage")
        showDistance.text       = "\(Int(searchDistance.value))"
    }
    
    @IBAction func searchNearBy(sender: UISwitch) {
        onlySearchNearByTweets = sender.on
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "onlySearchNearBy")
        tableView.reloadData()
    }
    
    @IBAction func radiusChanged(sender: UISlider) {
        settedRadius      = sender.value
        radius            = "\(settedRadius)km"
        showDistance.text = "\(Int(settedRadius))km"
        
        NSUserDefaults.standardUserDefaults().setFloat(settedRadius, forKey: "settedRadius")
    }
    
    @IBAction func useLocalLanguage(sender: UISwitch) {
        let currentLanguage = Tools.getDeviceLanguageCode()
        
        language = sender.on ? currentLanguage : language
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "shouldUseLocalLanguage")
        print("sender.on:\(sender.on),language:\(language)")
        language = sender.on ? currentLanguage : language
    }
    
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return sectionHeaderNames[0]
        case 1:
            return sectionHeaderNames[1]
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let toBeSettedSection = indexPath.section
        
        if !onlySearchNearByTweets {
            if toBeSettedSection == 0 && indexPath.row == 1 {
                return 0
            }
        }
        return 44.0
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedSection = indexPath.section
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if selectedSection == 1 {
            
            if cell?.accessoryType == .Checkmark{
                cell?.accessoryType = .None
            }else{
                cell?.accessoryType = .Checkmark
            }
        }
        
    }
}
