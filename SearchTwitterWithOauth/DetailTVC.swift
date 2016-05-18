//
//  DetailTVC.swift
//  SearchTwitterWithOauth
//
//  Created by Larry on 16/5/16.
//  Copyright © 2016年 Larry. All rights reserved.
//

import UIKit
import MJRefresh

class DetailTVC: UITableViewController {

    var subject = ""
    
    var allTwittes = [TwitteModel]()
    
    let manager = Tools.GetManager()
    
    let mainWindow = UIApplication.sharedApplication().delegate!.window
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension

        headerRefresh()
        
        //MJ下拉刷新
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(DetailTVC.headerRefresh))
        
        //MJ上拉加载
        tableView.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(DetailTVC.footerRefresh))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Refresh
    
    func headerRefresh() {
        var parameter = [String:AnyObject]()
        
        if maxID != 0 {
            parameter = ["since_id":maxID]
        }
        
        Tools.getTwittes(self.manager, subject: self.subject, otherParameter: parameter, resultClosure: { (tweetes, sinceid, maxid) in
            
            guard let newTweets = tweetes else{
                //self.mainWindow??.makeToast(Constants.AlertMessages.noMoreData)
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
               return
            }
            
            //将最近返回的tweet插入到数组首部
            for num in 0..<newTweets.count {
                let item = newTweets[num]
                self.allTwittes.insert(item, atIndex: num)
            }
            
            sinceID = sinceid
            maxID   = maxid
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
        })
    }
    
    func footerRefresh()  {

        let since = sinceID - 1
        
        let parameter = ["max_id":since]
        
        Tools.getTwittes(self.manager, subject: self.subject, otherParameter: parameter, resultClosure: { (tweetes, sinceid, maxid) in
            
            guard let newTweets = tweetes else{
                //self.mainWindow??.makeToast(Constants.AlertMessages.noMoreData)
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            //增加比较逻辑，将内容放到合适的位置
            
            
            
            
            self.allTwittes += newTweets
            
            sinceID = sinceid
            maxID   = maxid
            
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()

        })
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allTwittes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! DetailCell

        cell.configCells(allTwittes[indexPath.row])
        
        // Make sure the constraints have been added to this cell, since it may have just been created from scratch
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }


}
