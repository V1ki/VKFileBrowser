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


public func log(_ items: Any..., separator: String = "", terminator: String = "")  {
    print(items,separator,terminator)
}



extension NSObject {

    
}
extension UIView{
    public func showTips(_ tips:String){
        
//        let hud = MBProgressHUD.showAdded(to: self, animated: true)
//
//        hud?.mode = .text
//        hud?.labelText = tips
//
//        hud?.hide(true, afterDelay: 1.0)
        
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


extension Character {
    func toInt() -> Int
    {
        var intFromCharacter:Int = 0
        for scalar in String(self).unicodeScalars
        {
            intFromCharacter = Int(scalar.value)
        }
        return intFromCharacter
    }
    func isWord() -> Bool {
        let unicodeValue = self.toInt()
        if (unicodeValue > 64 && unicodeValue < 91) || (unicodeValue > 96 && unicodeValue < 123) {
            return true
        }
        return false
    }
}


