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
        vkFileVC = VKFileViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.navigationController?.pushViewController(vkFileVC!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func reloadData(){
        vkFileVC?.reloadCurPage()
    }

}

