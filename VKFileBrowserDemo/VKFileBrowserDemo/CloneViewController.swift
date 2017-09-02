//
//  CloneViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/20.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import RxSwift
import RxCocoa

class CloneViewController: BaseViewController {

    @IBOutlet weak var cloneBtn: UIButton!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var strs:[Int:String] = [Int:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        urlTextField.placeholder = LocalizedString("http and https support")
        urlTextField.text = "https://gitee.com/qq727755316/test.git"
        
        
        self.detailTextView.isHidden = true
        self.progressView.isHidden = true
        self.urlTextField.clearButtonMode = .whileEditing
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cloneProgressCallBack(_ str:String,_ line:Int){
        
        if(line == 1){
            if(str.contains("Compressing objects")){
                strs[1] = str
            }else if(str.contains("pack-reused")){
                strs[2] = str
            }else{
                strs[0] = str
            }
        }
        else if(line == 2){
            strs[3] = str
        }
        
        DispatchQueue.main.async {
            self.detailTextView.text = "\(self.strs[0] ?? "")\n\(self.strs[1] ?? "")\n\(self.strs[2] ?? "")\n\(self.strs[3] ?? "")"
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
            
            self.progressView.isHidden = false
            self.detailTextView.isHidden = false
            cloneBtn.isEnabled = false
            self.cloneWithUserAndPwd(urlText)

        }
        
    }
    
    
    func clone(_ urlText:String){
        DispatchQueue.global().async {
            let repoResult = RepositoryUtils.clone(urlText, self.cloneProgressCallBack)
            if repoResult.value != nil {
                self.dismiss(animated: true, completion: nil)
            }else {
                let err = repoResult.error
                print("err:\(err)")
            }
        }
       
    }
    

    func cloneWithUserAndPwd(_ repoStr:String){
        
        if(Defaults[.username].isEmpty || Defaults[.password].isEmpty){
            
            self.presentAlert{ isCancel in
                if(!isCancel){
                    self.clone(repoStr)
                }else{
                    self.detailTextView.isHidden = true
                    self.progressView.isHidden = true
                    self.cloneBtn.isEnabled = true
                }
                
            }
            return
        }
        print("username:\(Defaults[.username]) password:\(Defaults[.password]) ")
        self.clone(repoStr)
        
        
    }

    func presentAlert(_ completeHandler:((Bool) -> Swift.Void)? = nil ){
        
        
        let alertController = UIAlertController(title: LocalizedString("git"), message: LocalizedString("no way to authenticate"), preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = LocalizedString("username")
        })
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = LocalizedString("password")
        })
        
        let cancelAction = UIAlertAction(title:LocalizedString("Cancel"),style:.cancel,handler:{(action) in
            if(completeHandler != nil){
                completeHandler!(true)
            }
        })
        
        let loginAction = UIAlertAction(title: LocalizedString("Login"), style: .default, handler: {(alertAction) in
            
            
            let user = (alertController.textFields?.first?.text)!
            let pwd = (alertController.textFields?.last?.text)!
            log("user:\(user) -- pwd:\(pwd)")
            Defaults[.username] = user
            Defaults[.password] = pwd
            
            
            if(completeHandler != nil){
                completeHandler!(false)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(loginAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
