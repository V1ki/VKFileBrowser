//
//  VKSpiltViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/18.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class VKSpiltViewController: UISplitViewController,UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.preferredDisplayMode = .allVisible
        
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
extension UISplitViewController {
    
    func reloadRootData(){
        let firstViewController = self.viewControllers.first
        if let rootVC = firstViewController as? RootViewController{
            rootVC.reloadCurPage()
        }
    }
    
}
extension UIViewController {
    
    func reloadFileTree(){
        spiltController.reloadRootData()
    }
    
}
