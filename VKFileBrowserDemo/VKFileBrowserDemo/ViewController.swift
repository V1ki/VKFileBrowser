//
//  ViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2016/9/30.
//  Copyright © 2016年 vk. All rights reserved.
//

import UIKit
import Result
import ChameleonFramework

class ViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.setLeftBarButtonItems([(splitViewController?.displayModeButtonItem)!], animated: true)
        self.navigationController?.hidesNavigationBarHairline = true
        navigationItem.leftItemsSupplementBackButton = true
        self.navigationController?.navigationBar.barTintColor = .flatSkyBlue
    }

    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

