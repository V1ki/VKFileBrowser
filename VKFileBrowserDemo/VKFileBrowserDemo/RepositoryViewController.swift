//
//  RepositoryViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/22.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import VBFPopFlatButton
import RxSwift
import RxCocoa
import ChameleonFramework
import SVProgressHUD

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
        
        self.title = currentRepo?.directoryURL?.pathComponents.last
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
                
            }
            
        }
        

        self.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadData()
    }
    
    
    func reloadData(){
        dataSource.removeAll()
        
        let remoteReuslt = currentRepo?.allRemotes()
        if let remotes = remoteReuslt?.value {
            dataSource["REMOTES"] = remotes
            dataSource["REMOTES"]?.append("Add")
        }else{
            log("error: \(remoteReuslt?.error)")
        }
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let commits = (currentRepo?.allCommits())!
        
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
        self.reloadFileTree()
        self.mTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*

     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
//MARK: - UITableView dataSource
extension RepositoryViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionTitles.count > section {
            let key = sectionTitles[section]
            if let value = dataSource[key]{
                return value.count
            }
            return 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = sectionTitles[indexPath.section]
        
        
        if(key == "REMOTES"){

            if(dataSource[key]![indexPath.row] as? Remote == nil){
                let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
                cell.textLabel?.text = "Add Remote"
                cell.textLabel?.textAlignment = .center
                return cell
            }
        }
        else if(key == "LocalBranches"){
            if(dataSource[key]![indexPath.row] as? Branch == nil){
                let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
                cell.textLabel?.text = "Add Branch"
                cell.textLabel?.textAlignment = .center
                return cell
            }
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? MGSwipeTableCell
        
        if(cell == nil){
            cell = MGSwipeTableCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }
        cell?.textLabel?.textAlignment = .left
        
        var nextBtn = cell?.contentView.viewWithTag(101) as? VBFPopFlatButton
        if(nextBtn == nil){
            nextBtn = VBFPopFlatButton(frame: CGRect(x: self.view.mj_w - 40 , y: ((cell?.mj_h)! - 28)/2 , width: 28, height: 28), buttonType: .buttonForwardType, buttonStyle: .buttonRoundedStyle , animateToInitialState: false)
            nextBtn?.backgroundColor = UIColor.clear
            nextBtn?.tintColor = .flatSkyBlue
            nextBtn?.tag = 101
            nextBtn?.isHidden = true
            cell?.contentView.addSubview(nextBtn!)
        }
        
        nextBtn?.isHidden = true
        
        
        if(key == "REMOTES"){
            
            let remote = dataSource[key]![indexPath.row] as? Remote
            if(remote != nil){
                cell?.textLabel?.text = remote?.name
                cell?.detailTextLabel?.text = remote?.URL
                
                //configure right buttons
                cell?.rightButtons = [MGSwipeButton(title: "Fetch", backgroundColor: .flatLime,callback:{cell in
                    DispatchQueue.global().async {
                        
                        DispatchQueue.main.async {
                            SVProgressHUD.show()
                        }
                        
                        RepositoryUtils.fetchRemote(self.currentRepo!,(remote?.name)!,{str,line in
                            print("str:\(str)")
                        })
                        
                        DispatchQueue.main.async {
                            self.reloadData()
                            SVProgressHUD.dismiss()
                        }
                        
                    }
                    
                    return true
                })]
                cell?.rightSwipeSettings.transition = .rotate3D
                
                
                let deleteButton = MGSwipeButton(title: "Delete", backgroundColor: .flatRed){cell in
                    _ = RepositoryUtils.deleteRemote(self.currentRepo!, (remote?.name)!)
                    self.reloadData()
                    return true
                }
                cell?.leftButtons = [deleteButton]
                cell?.leftSwipeSettings.transition = .border
                
                
                nextBtn?.isHidden = false
            }
        }
        else if(key.contains("COMMITS")){
            let ci = dataSource[key]![indexPath.row] as! Commit
            let msg = "\(ci.message)"
            dateFormatter.dateFormat = "HH:mm"
            let timeStr = dateFormatter.string(from: ci.author.time)
            cell?.textLabel?.text = "\(msg)"
            let detailStr = NSMutableAttributedString()
            
            let localBranchResult = dataSource["LocalBranches"]!.filter{($0 as!Branch).oid == ci.oid}
            
            
            for i in 0..<localBranchResult.count {
                let branch = localBranchResult[i] as! Branch
                let branchStr = NSAttributedString(string: branch.shortName!, attributes: [ NSBackgroundColorAttributeName:localBranchColors[i]])
                detailStr.append(branchStr)
                detailStr.append(NSAttributedString(string:" "))
            }
            
            
            let remoteBranchResult = dataSource["RemoteBranches"]!.filter{($0 as!Branch).oid == ci.oid}
            
            
            for i in 0..<remoteBranchResult.count {
                let branch = remoteBranchResult[i] as! Branch
                let branchStr = NSAttributedString(string: branch.shortName!, attributes: [ NSBackgroundColorAttributeName:remoteBranchColors[i]])
                detailStr.append(branchStr)
                detailStr.append(NSAttributedString(string:" "))
            }
            
            
            let headResult = currentRepo?.HEAD()
            if let head = headResult?.value {
                if head is Branch {
                    
                }else if head.oid == ci.oid {
                    
                    let branchStr = NSAttributedString(string: "HEAD", attributes: [ NSBackgroundColorAttributeName:HEADCOLOR])
                    detailStr.append(branchStr)
                    detailStr.append(NSAttributedString(string:" "))
                }
            }
            
            detailStr.append(NSAttributedString(string:"\(ci.author.name) \(timeStr)"))

            cell?.detailTextLabel?.attributedText = detailStr
            
            
            //configure right buttons
            cell?.rightButtons = [MGSwipeButton(title: "Checkout", backgroundColor: .flatLime,callback:{cell in
                
                let result = RepositoryUtils.checkoutCommit(self.currentRepo!, ci)
                
                if(result.error == nil){
                    self.reloadData()
                }else{
                    print("result.error:\(result.error)")
                }
                return true
            })]
            cell?.rightSwipeSettings.transition = .rotate3D
            
        }
        else if(key == "LocalBranches" || key == "RemoteBranches"){
            
            let branch = dataSource[key]![indexPath.row] as! Branch
//            let trackingBranch = branch.trackingBranch(currentRepo!).value
            cell?.textLabel?.text = "\(branch.name)"
            if(branch.isLocal){
                
                
                let remoteBranches = dataSource["RemoteBranches"]! as! [Branch]
                if let remoteBranch = (remoteBranches.filter{$0.oid == branch.oid}).first {
                    cell?.detailTextLabel?.text = "tracking \(remoteBranch.name)"
                }
                
                
            }else{
                cell?.detailTextLabel?.text = "\(branch.longName)"
            }
            
            
            //configure right buttons
            cell?.rightButtons = [MGSwipeButton(title: "Checkout", backgroundColor: .flatLime,callback:{cell in
                
                RepositoryUtils.checkoutBranch(self.currentRepo!, branch)
                
                self.reloadData()
                return true
            })]
            cell?.rightSwipeSettings.transition = .rotate3D
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
        let label = UILabel(frame: CGRect(x: 20, y: 10, width: tableView.frame.size.width, height: 20))
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
                
                let alertController = UIAlertController(title: LocalizedString("remote"), message: LocalizedString("add remote"), preferredStyle: .alert)
                
                alertController.addTextField(configurationHandler: {(textField) in
                    textField.placeholder = LocalizedString("remote name")
                    textField.text = "origin"
                })
                
                alertController.addTextField(configurationHandler: {(textField) in
                    textField.placeholder = LocalizedString("remote url")
                    textField.text = "https://github.com/qq727755316/python1.git"
                    textField.keyboardType = .URL
                    if #available(iOS 10.0,*){
                        textField.textContentType = .URL
                    }
                    

                })
                
                let cancelAction = UIAlertAction(title:LocalizedString("Cancel"),style:.cancel,handler:{(action) in
                    
                })
                
                let addAction = UIAlertAction(title: LocalizedString("add"), style: .default, handler: {(alertAction) in
                    
                    let name = (alertController.textFields?.first?.text)!
                    let url = (alertController.textFields?.last?.text)!
                    
                    
                    
                    let result = RepositoryUtils.addRemote(self.currentRepo!,name,url)
                    
                    guard result.error == nil else{
                        print("error:\(result.error)")
                        return
                    }
                    
                    self.reloadData()
                    
                })
                alertController.addAction(cancelAction)
                alertController.addAction(addAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                
            }else{
                let remoteVC = RemoteViewController()
                remoteVC.remote = remote
                remoteVC.repo = currentRepo
                self.navigationController?.pushViewController(remoteVC, animated: true)
                
            }
        }
        else if(key.contains("COMMITS")){

            
        }else if(key == "LocalBranches" || key == "RemoteBranches"){
            
        }
    }
}
