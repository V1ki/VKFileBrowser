//
//  CloneViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/20.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit


class CloneViewController: BaseViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        urlTextField.placeholder = LocalizedString("http and https support")
        self.descLabel.isHidden = true
        self.progressView.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func cloneProgressCallBack(_ name:String?,_ completeStep : Int ,_ totalStep : Int){
        if(name != nil){
            print("name:\(name) completeStep:\(completeStep) totalStep:\(totalStep)")
            DispatchQueue.main.async {
                self.progressView.progress = Float(completeStep) / Float(totalStep)
                
                self.descLabel.text = name
            }
            
            if(totalStep == completeStep){
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clickCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func clickCloneBtn(_ sender: Any) {
        if let urlText = urlTextField.text {
            if(urlText.isEmpty){
                return
            }
            self.descLabel.isHidden = false
            self.progressView.isHidden = false
            self.descLabel.text = "connecting"
            DispatchQueue.global().async {
                
                let repoResult = RepositoryUtils.clone(urlText,credentials: .default,progresssHandler: self.cloneProgressCallBack)
                if let repo = repoResult.value {
                    
                }else {
                    let err = repoResult.error
                    if(err?.domain == libGit2ErrorDomain && err?.code == -1){
                        //请输入用户名和密码
                        self.cloneWithUserAndPwd(urlText)
                    }
                }
            }
            
            
            
        }
        
        
    }
    
    

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
            DispatchQueue.global().async {
                
                let repoResult = RepositoryUtils.clone(repoStr,credentials: .plaintext(username: user, password: pwd),progresssHandler: self.cloneProgressCallBack)
                
                
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

    
}
