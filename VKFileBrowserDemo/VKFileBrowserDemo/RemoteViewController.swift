//
//  RemoteViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/23.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class RemoteViewController: BaseViewController {
    
    let cellIdentifier = "CELL"
    
    @IBOutlet weak var mTableView: UITableView!
    var repo:Repository?
    var remote:Remote?
    var remoteName : String?
    var remoteUrl : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if(self.remote == nil)
        {
            self.navigationController?.popViewController(animated: false)
        }
        
        let saveBtn = UIButton(frame: CGRect(x:0,y:0,width:50,height:30 ))
        saveBtn.setTitle(LocalizedString("Save"), for: .normal)
        saveBtn.rx.tap.bind {
            if let remoteName = self.remoteName ,let remoteUrl = self.remoteUrl {
                if(self.remote!.name == remoteName){
                    self.remote?.rename(self.repo!, remoteName)
                }
                if(self.remote!.URL == remoteUrl){
                    self.remote?.updatePushUrl(self.repo!, remoteUrl)
                }
            }
            
        }.disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.title = LocalizedString("Remote")
        
        self.mTableView.dataSource = nil
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>()
        
        let items = Observable.just([
            SectionModel(model: "First section", items: [""]),
            SectionModel(model: "Second section", items: [LocalizedString("Name"),LocalizedString("URL"),
//                                                          LocalizedString("Test")
                ]),
            SectionModel(model: "Third section", items: [LocalizedString("Delete")])
            ])
        //(TableViewSectionedDataSource<S>, Int) -> String?
        dataSource.titleForHeaderInSection = {tDataSource,section in
            return "  "
        }
        
        
        dataSource.configureCell = { (tdataSource, tv, indexPath, element) in
            var cell = tv.dequeueReusableCell(withIdentifier: self.cellIdentifier)
            if(cell == nil){
                cell = UITableViewCell(style: .default, reuseIdentifier: self.cellIdentifier)
            }
            if(element.isEmpty){
                let fetchBtn = UIButton(frame: CGRect(x:20,y:0,width:50,height:cell?.mj_h ?? 40))
                fetchBtn.backgroundColor = .clear
                fetchBtn.setTitle(LocalizedString("Fetch"), for: .normal)
                fetchBtn.setTitleColor(fetchBtn.tintColor, for: .normal)
                fetchBtn.rx.tap.bind {
                    
//                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    RepositoryUtils.fetchRemote(self.repo!, self.remote!.name,{str,line in
                        print("\(str)")
                    })
                    
                    
                }.disposed(by: disposeBag)
                
                cell?.addSubview(fetchBtn)
                
                
                let pushBtn = UIButton(frame: CGRect(x:self.view.mj_w - 20 - 50,y:0,width:50,height:cell?.mj_h ?? 40))
                pushBtn.backgroundColor = .clear
                pushBtn.setTitle(LocalizedString("Push"), for: .normal)
                pushBtn.setTitleColor(fetchBtn.tintColor, for: .normal)
                pushBtn.rx.tap.bind {
                    
                    print("click push:\(self.repo!.HEAD())")
                    
                    let head = self.repo!.HEAD().value
                    if(head == nil){
                        self.view.showTips("local has no content,Please fetch first")
                        return
                    }
                    
                    var branch : Branch?
                    if(head is Branch){
                        // current Branch
                        print("current Branch")
                        branch = head as? Branch
                    }
                    else{
                        let branches = (self.repo!.localBranches().value)!
                        branch = branches.filter{$0.oid == head?.oid}.last
                        
                        if(branch == nil){
                            self.view.showTips("local has no content,Please fetch first")
                            return
                        }
                        
                    }
                    
                    RepositoryUtils.pushBranch(self.repo!, (branch)!, (self.remote)!)
                    
                    
                    }.disposed(by: disposeBag)
                
                cell?.addSubview(pushBtn)
                
                
            }else{
                cell?.textLabel?.text = element
                
                if(element == LocalizedString("Delete")){
                    cell?.textLabel?.textAlignment = .center
                    cell?.textLabel?.textColor = .flatRed
                    return cell!
                }
                if(element == LocalizedString("Test")){
                    cell?.textLabel?.textAlignment = .center
                    cell?.textLabel?.textColor = .flatSkyBlue
                    return cell!
                }
                
                let textField = UITextField(frame: CGRect(x:80,y:0,width:self.view.mj_w - 100,height:cell?.mj_h ?? 40))
                
                if(element == LocalizedString("Name")){
                    textField.text = self.remote?.name
                    textField.rx.text.bind{str in self.remoteName = str}.disposed(by: disposeBag)
                }else if(element == LocalizedString("URL")){
                    textField.text = self.remote?.URL
                    textField.rx.text.bind{str in self.remoteUrl = str}.disposed(by: disposeBag)
                }
                    cell?.addSubview(textField)
                
            }
            return cell!
        }
        
        
        
        self.mTableView.rx.itemSelected.bind{indexPath in
            self.mTableView.deselectRow(at: indexPath, animated: true)
            
            if indexPath.row == 0 && indexPath.section == 2{
            
                //delete Action
                let result = RepositoryUtils.deleteRemote(self.repo!, self.remote!.name)
                if(result.error == nil){
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    self.view.showTips((result.error?.description)!)
                }
            }
            
            
        }.disposed(by: disposeBag)
        
        
        items
            .bind(to: self.mTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        
        self.mTableView.hideExtraCell()
        
        
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


extension RemoteViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if(indexPath.row == 2 || (indexPath.row == 0 && indexPath.section == 2)){
            return indexPath
        }
        return nil
    }
}

