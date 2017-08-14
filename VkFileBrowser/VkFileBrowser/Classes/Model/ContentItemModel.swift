//
//  ContentItemModel.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/4.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation

class ContentItemModel : BaseModel {
    /*
     
     {
     "name": ".swift-version",
     "path": ".swift-version",
     "sha": "9f55b2ccb5f234fc6b87ada62389a3d73815d0d1",
     "size": 4,
     "url": "https://api.github.com/repos/Alamofire/Alamofire/contents/.swift-version?ref=master",
     "html_url": "https://github.com/Alamofire/Alamofire/blob/master/.swift-version",
     "git_url": "https://api.github.com/repos/Alamofire/Alamofire/git/blobs/9f55b2ccb5f234fc6b87ada62389a3d73815d0d1",
     "download_url": "https://raw.githubusercontent.com/Alamofire/Alamofire/master/.swift-version",
     "type": "file",
     "_links": {
        "self": "https://api.github.com/repos/Alamofire/Alamofire/contents/.swift-version?ref=master",
        "git": "https://api.github.com/repos/Alamofire/Alamofire/git/blobs/9f55b2ccb5f234fc6b87ada62389a3d73815d0d1",
        "html": "https://github.com/Alamofire/Alamofire/blob/master/.swift-version"
     }
     */
    
    var name : String?
    var path : String?
    var sha : String?
    var size : NSNumber?
    var url : String?
    var html_url : String?
    var git_url : String?
    var download_url : String?
    var type : String?
    
    func isFile() -> Bool{
        return type == "file"
    }
    
    
    func isDir() -> Bool{
        return type == "file"
    }
    
    
    override var description: String {
        get{
            return "name:\(name) -- path:\(path) -- sha:\(sha) -- size:\(size) -- url:\(url) -- html_url:\(html_url)"
        }
    }
    
}
