//
//  ViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2016/9/30.
//  Copyright © 2016年 vk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var vkFileVC : VKFileViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func clickFinderBtn(_ sender: Any) {
        vkFileVC = VKFileViewController()
        self.navigationController?.pushViewController(vkFileVC!, animated: true)
    }
    
    @IBAction func clickGithubBtn(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: "Github", message: "SSH or HTTPS URLS", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = LocalizedString("git@github.com:owner/repo.git")
        })
        
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = LocalizedString("https://github.com/owner/repo.git")
        })
        
        
        let action = UIAlertAction(title: LocalizedString("confrim"), style: .default, handler: {(alertAction) in
            
            let sshUrls = (alertController.textFields?.first?.text)!
            let httpsUrls = (alertController.textFields?.last?.text)!
            
            if(sshUrls.isEmpty && httpsUrls.isEmpty){
                return
            }
            let gitSuffix = ".git"
            var gitPrefix = "git@github.com:"
            var owner = ""
            var repo = ""
            
            if(!sshUrls.isEmpty && sshUrls.hasSuffix(gitSuffix))
            {
                var str = sshUrls.substring(to: sshUrls.index(sshUrls.endIndex, offsetBy: -gitSuffix.characters.count))
                str = str.substring(from: str.index(str.startIndex, offsetBy: gitPrefix.characters.count))
                print("str:\(str)")
                
                let components = str.components(separatedBy: "/")
                owner = components.first!
                repo = components.last!
                
                
            }
            
            gitPrefix = "https://github.com/"
            if(!httpsUrls.isEmpty && httpsUrls.hasSuffix(gitSuffix))
            {
                var str = httpsUrls.substring(to: httpsUrls.index(httpsUrls.endIndex, offsetBy: -gitSuffix.characters.count))
                str = str.substring(from: str.index(str.startIndex, offsetBy: gitPrefix.characters.count))
                print("str:\(str)")
                
                let components = str.components(separatedBy: "/")
                owner = components.first!
                repo = components.last!
                

            }
            let githubVC = GithubViewController()
            githubVC.owner = owner
            githubVC.repo = repo
            self.navigationController?.pushViewController(githubVC, animated: true)
            
            
            
            
            
            
        })
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
        

        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func reloadData(){
        vkFileVC?.reloadCurPage()
    }

}

