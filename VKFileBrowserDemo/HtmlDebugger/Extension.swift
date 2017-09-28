//
//  Extension.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/7/28.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import UIKit

import SVProgressHUD


extension UIView{
    public func showTips(_ tips:String){
        
        SVProgressHUD.showError(withStatus: tips)
    }
    

}
extension UITableView{
    
    func hideExtraCell(){
        let view = UIView()
        view.backgroundColor = UIColor.clear
        self.tableFooterView = view
    }
}

extension UITextField {
    
    func clear(){
        self.text = ""
    }
    
}
extension UITextView {
    
    func clear(){
        self.text = ""
    }
    
}


