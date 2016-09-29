//
//  VKFile.swift
//  VkFileBrowser
//
//  Created by Vk on 2016/9/29.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit

class VKFile: NSObject {
    
    var name : String!
    var isDirectory : Bool!
    var type : String!
    
    init(_ name : String , _ isDirectory : Bool ,_ type :String) {
        self.name = name
        self.isDirectory = isDirectory
        self.type = type
    }
    
    
    

}
