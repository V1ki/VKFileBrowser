//
//  RepositoryViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/22.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class RepositoryViewController: BaseViewController {
    
    @IBOutlet weak var mTableView: UITableView!
    
    
    var sectionTitles = ["REMOTES","LocalBranches","RemoteBranches"]
    
    let reuseIdentifier = "cell"
    
    var currentRepo : Repository?
    
    var dataSource : [String:[Any]] = [String:[Any]]()
    
    var dateFormatter = DateFormatter()
    
    var headOID : OID? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mTableView.hideExtraCell()
        self.automaticallyAdjustsScrollViewInsets = false
        //        RepositoryUtils.addRefspecs(currentRepo!, "origin")
        //        RepositoryUtils.refspecs(currentRepo!)
        
        if(currentRepo?.HEAD().value == nil){
            //            RepositoryUtils.initFirstCommit(currentRepo!)
        }
        else{
            headOID = (currentRepo?.HEAD().value?.oid)!
            
            let lastCommitResult = (currentRepo?.HEAD().flatMap{(currentRepo?.commit($0.oid))!} )!
            if let lastCommit = lastCommitResult.value {
                
                RepositoryUtils.listFiles(currentRepo!, lastCommit.tree.oid)
            }
            
        }
        
        
        
        
        
        let pushBtn = UIButton(frame:CGRect(x: 0, y: 0, width: 80, height: 40))
        
        pushBtn.setTitle("push", for: .normal)
        pushBtn.setTitleColor(pushBtn.tintColor, for: .normal)
        pushBtn.addTarget(self, action: #selector(clickPushBtn), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pushBtn)
        
        
        self.reloadData()
    }
    
    func clickPushBtn(){
        
        let remoteBranchesResult = currentRepo?.remoteBranches()
        
        
        if let remoteBranches = remoteBranchesResult?.value {
            if(remoteBranches.count == 0){
                
            }
        }
        
        
        
        let localBranchesResult = currentRepo?.localBranches()
        
        if let localBranches = localBranchesResult?.value {
            if(localBranches.count > 0){
                
                let remoteReuslt = currentRepo?.allRemotes()
                if let remotes = remoteReuslt?.value {
                    RepositoryUtils.pushBranch(currentRepo!, localBranches.first!,remotes.first!)
                }
                
                
            }
        }
        
        
        
        
        //
    }
    
    
    
    func reloadData(){
        let remoteReuslt = currentRepo?.allRemotes()
        if let remotes = remoteReuslt?.value {
            dataSource["REMOTES"] = remotes
            dataSource["REMOTES"]?.append("Add")
        }else{
            log("error: \(remoteReuslt?.error)")
        }
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let commits = (currentRepo?.allCurrentCommits())!
        
        
        var allCommits = commits
        
        allCommits.sort{ ci1,ci2 in return ci1.author.time > ci2.author.time }
        
        for ci in allCommits {
            let committerTime = ci.author.time
            let committerTitle = "COMMITS \(dateFormatter.string(from: committerTime))"
            
            if var array = dataSource[committerTitle] {
                
                array.append(ci)
                dataSource[committerTitle] = array
            }
            else{
                var array = [Commit]()
                array.append(ci)
                sectionTitles.append(committerTitle)
                dataSource[committerTitle] = array
            }
            
            
            //            RepositoryUtils.addCommit(currentRepo!, allCommits.first!)
            
        }
        
        
        
        let localBranchesResult = currentRepo?.localBranches()
        if let localBranches = localBranchesResult?.value {
            dataSource["LocalBranches"] = localBranches
        }else{
            log("error: \(localBranchesResult?.error)")
        }
        
        
        let remoteBranchesResult = currentRepo?.remoteBranches()
        if let remoteBranches = remoteBranchesResult?.value {
            dataSource["RemoteBranches"] = remoteBranches
        }else{
            log("error: \(remoteBranchesResult?.error)")
        }
        
        self.mTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension RepositoryViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[sectionTitles[section]]!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if(cell == nil){
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }
        let key = sectionTitles[indexPath.section]
        if(key == "REMOTES"){
            
            let remote = dataSource[key]![indexPath.row] as? Remote
            if(remote != nil){
                cell?.textLabel?.text = remote?.name
                cell?.detailTextLabel?.text = remote?.URL
                cell?.accessoryType = .disclosureIndicator
            }
            else{
                cell?.textLabel?.text = "Add"
            }
        }
        else if(key.contains("COMMITS")){
            let ci = dataSource[key]![indexPath.row] as! Commit
            let msg = "\(ci.message)"
            dateFormatter.dateFormat = "HH:mm"
            let timeStr = dateFormatter.string(from: ci.author.time)
            cell?.textLabel?.text = "\(msg)"
            if(headOID == ci.oid){
                cell?.detailTextLabel?.text = "HEAD \(ci.author.name) \(timeStr)"
            }
            else{
                cell?.detailTextLabel?.text = "\(ci.author.name) \(timeStr)"
            }
            
            
        }
        else if(key == "LocalBranches" || key == "RemoteBranches"){
            let branch = dataSource[key]![indexPath.row] as! Branch
            cell?.textLabel?.text = "\(branch.name)"
            let trackingBranch = branch.trackingBranch(currentRepo!).value
            if(branch.isLocal && trackingBranch != nil){
                cell?.detailTextLabel?.text = "tracking \(branch.name)"
            }
            
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: tableView.frame.size.width, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = LocalizedString(sectionTitles[section])
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeight = CGFloat(40)
        
        if(scrollView.contentOffset.y <= sectionHeight && scrollView.contentOffset.y >= 0 ){
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
            
        }else if (scrollView.contentOffset.y >= sectionHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeight, 0, 0, 0);
        }
        
    }
    
    
}
extension RepositoryViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = sectionTitles[indexPath.section]
        if(key == "REMOTES"){
            
            let remote = dataSource[key]![indexPath.row] as? Remote
            if(remote == nil){
                
                _ = RepositoryUtils.addRemote(currentRepo!,"origin","https://github.com/qq727755316/python1.git")
                self.reloadData()
            }else{
                let remoteVC = RemoteViewController()
                remoteVC.remote = remote
                remoteVC.repo = currentRepo
                self.navigationController?.pushViewController(remoteVC, animated: true)
                
            }
        }
        else if(key.contains("COMMITS")){
            let commit  = dataSource[key]![indexPath.row] as! Commit
            
            RepositoryUtils.checkoutCommit(currentRepo!, commit)
            
            let oid = commit.tree.oid
            
            let tree = currentRepo?.tree(oid)
            print("tree:\(tree)")
            
        }else if(key == "LocalBranches" || key == "RemoteBranches"){
            let branch  = dataSource[key]![indexPath.row] as! Branch
            RepositoryUtils.checkoutBranch(currentRepo!, branch)
        }
    }
}
