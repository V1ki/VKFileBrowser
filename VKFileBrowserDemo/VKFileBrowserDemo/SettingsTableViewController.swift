//
//  SettingsTableViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/28.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import InAppSettingsKit

class SettingsTableViewController: IASKAppSettingsViewController ,IASKSettingsDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
        self.neverShowPrivacySettings = true
        NotificationCenter.default.addObserver(self, selector: #selector(appSettingChanged), name: NSNotification.Name(rawValue: "kAppSettingChanged"), object: nil)
        
    }
    
    func appSettingChanged(_ notif:NSNotification){
        print("notif:\(notif)")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController!) {
        print( "settingsViewControllerDidEnd:\(self.settingsStore)")
        
    }
    
    func settingsViewController(_ sender: IASKAppSettingsViewController!, buttonTappedFor specifier: IASKSpecifier!) {
        print( "buttonTappedFor\(specifier)")
    }
    
    func settingsViewController(_ sender: IASKAppSettingsViewController!, tableView: UITableView!, didSelectCustomViewSpecifier specifier: IASKSpecifier!) {
        print( "didSelectCustomViewSpecifier\(specifier)")
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
