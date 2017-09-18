//
//  NetworkItem.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/14.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class NetworkItem: Object {
    
    dynamic var url : String = "" // network url
    dynamic var status : Int = 200
    dynamic var size : Int = 0 //  network size
    dynamic var data = NSData()
    
    var headers = List<HeaderItem>()
    
    
    override func isEqual(_ object: Any?) -> Bool {
        if  object is NetworkItem {
            if let item = object as? NetworkItem {
                return item.url == self.url
            }
        }
        return false
    }

}

