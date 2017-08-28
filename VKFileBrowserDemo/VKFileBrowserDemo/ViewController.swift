//
//  ViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2016/9/30.
//  Copyright © 2016年 vk. All rights reserved.
//

import UIKit
import Result

class ViewController: UIViewController {
    
    
    var progressHud : MBProgressHUD?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }

    
    
//    func clone(){
//        let alertController = UIAlertController(title: LocalizedString("Github"), message: "HTTPS URLS", preferredStyle: .alert)
//        
//        alertController.addTextField(configurationHandler: {(textField) in
//            textField.placeholder = LocalizedString("https://github.com/owner/repo.git")
//        })
//        
//        
//        let action = UIAlertAction(title: LocalizedString("clone"), style: .default, handler: {(alertAction) in
//
//            
//            let repoStr = (alertController.textFields?.first?.text)!
//            
//            if(repoStr.isEmpty){
//                return
//            }
//            
//            
//            self.progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
//            self.progressHud?.mode = MBProgressHUDMode.annularDeterminate
//            
//            
//            DispatchQueue.global().async {
//                let repoResult = RepositoryUtils.clone(repoStr,credentials: .default,progresssHandler: {(str, completedSteps, totalSteps) in
//                    log("str:\(str ?? "")  completedSteps:\(completedSteps)  totalSteps:\(totalSteps)")
//                    self.progressHud?.progress = Float(completedSteps) / Float(totalSteps)
//                    self.progressHud?.labelText = str ?? ""
//                })
//                DispatchQueue.main.async {
//                    self.progressHud?.hide(true)
//                }
//                
//                if let repo = repoResult.value {
//                    
//                }
//                else{
//                    let err = repoResult.error
//                    log("err:\(err)")
//                    
//                    if(err?.domain == libGit2ErrorDomain && err?.code == -1){
//                        //请输入用户名和密码
//                        self.cloneWithUserAndPwd(repoStr)
//                    }else if(err?.domain == libGit2ErrorDomain && err?.code == -4){
//                        //file exists and is not an empty directory
//                    }
//                    
//                }
//            }
//            
//            
//            
//            
//            return ;
//            
//        })
//        
//        
//        
//        alertController.addAction(action)
//        
//        self.present(alertController, animated: true, completion: nil)
//    }
    
    func cloneWithUserAndPwd(_ repoStr:String){
        let alertController = UIAlertController(title: LocalizedString("git"), message: LocalizedString("no way to authenticate"), preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = LocalizedString("username")
        })
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = LocalizedString("password")
        })
        
        let cancelAction = UIAlertAction(title:LocalizedString("Cancel"),style:.cancel,handler:{(action) in
            
        })
        
        let loginAction = UIAlertAction(title: LocalizedString("Login"), style: .default, handler: {(alertAction) in
            
            
            let user = (alertController.textFields?.first?.text)!
            let pwd = (alertController.textFields?.last?.text)!
            log("user:\(user) -- pwd:\(pwd)")
            self.progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.progressHud?.mode = MBProgressHUDMode.annularDeterminate
            
            DispatchQueue.global().async {
                
                let repoResult = RepositoryUtils.clone(repoStr,credentials: .plaintext(username: user, password: pwd))
                
                DispatchQueue.main.async {
                    self.progressHud?.hide(true)
                }
                
                if let repo = repoResult.value {
                    
                }
                else{
                    let err = repoResult.error
                    log("err:\(err)")
                    
                }
            }

            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(loginAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

