//
//  VKFile.swift
//  VkFileBrowser
//
//  Created by Vk on 2016/9/29.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit

class VKFile: NSObject {
    
    enum VKFileSortType {
        /// 通过文件名来排序
        case name
        /// 通过文件类型来排序
        case type
        /// 通过文件大小来排序
        case fileSize
        /// 通过日期来排序呢
        case creationDate
        
    }
    
    
    var name : String!
    var isDirectory : Bool
    var type : String!
    var fileSize : Int? = 0
    var creationDate : NSDate?
    
    init(_ name : String , _ isDirectory : Bool ,_ type :String ,_ fileSize : Int?) {
        self.name = name
        self.isDirectory = isDirectory
        self.type = type
        self.fileSize = fileSize
        
        
    }
    
    
    func compare(withOtherFile otherFile:VKFile,bySortType sortType : VKFileSortType) -> Bool {
        if(sortType == .name)
        {
            let result = self.name.compare(otherFile.name,options: [.caseInsensitive])
            if(ComparisonResult.orderedAscending == result){
                return true
            }
            return false
        }
        else if(sortType == .type)
        {
            
            let result = self.type.compare(otherFile.type)
            if(ComparisonResult.orderedAscending == result){
                return true
            }
            return false
        }
        else if(sortType == .fileSize)
        {
            if(self.isDirectory && !otherFile.isDirectory)
            {
                return true
            }
            else if(!self.isDirectory && otherFile.isDirectory)
            {
                return false
            }
            else if(self.isDirectory && otherFile.isDirectory)
            {
                return self.compare(withOtherFile: otherFile, bySortType: .name)
            }
            return self.fileSize! > otherFile.fileSize!
        }
        else if(sortType == .creationDate)
        {
            let date1 : Double = (self.creationDate?.timeIntervalSince1970)!
            let date2 : Double = (otherFile.creationDate?.timeIntervalSince1970)!
            return date1  > date2
        }
        return true
        
    }

}
