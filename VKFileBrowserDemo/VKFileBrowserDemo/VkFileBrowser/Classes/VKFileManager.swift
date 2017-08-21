//
//  VKFileManager.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/18.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class VKFileManager: NSObject {
    
    
    private override init() {
        
    }
    
    open class var `default`: VKFileManager {
        get{
            return VKFileManager()
        }
    }

    private let fm = FileManager.default
    
    func createNewFolder(_ fileDir : String) -> Bool {
        
        let fileExists = fm.fileExists(atPath: fileDir)
        if fileExists {
            return false
        }
        do{
            try fm.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
        }catch let error{
            log(error)
            return false
        }
        return true
    }
    
    
    func loadFile(at path:String,loadGit shouldLoad:Bool = false) -> [VKFile]{
        
        var dataSource = [VKFile]()
        
        let directoryEnumerator = fm.enumerator(at:URL(fileURLWithPath: path), includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil)!
        
        
        for case let fileURL as NSURL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                let isDirectory = resourceValues[.isDirectoryKey] as? Bool ,
                let name = resourceValues[.nameKey] as? String ,
                let type = resourceValues[.typeIdentifierKey] as? String
                
                else {
                    
                    continue
            }
            
            let fileSize = resourceValues[URLResourceKey.totalFileSizeKey] as? NSNumber
            var fileSizeFloatValue = fileSize?.intValue
            fileSizeFloatValue = fileSizeFloatValue == nil ? 0 : fileSizeFloatValue
            
            let creationDate = resourceValues[.creationDateKey]
            
            let file = VKFile(name,path, isDirectory, type,fileSizeFloatValue)
            file.creationDate = creationDate as! NSDate?
            
            dataSource.append(file)
            
            if(isDirectory){
                if(shouldLoad){
                    file.isGitRepo = RepositoryUtils.isGitRepository(file.toFileURL())
                }
                
                directoryEnumerator.skipDescendents()
            }
            
        }
        
        return dataSource
    }
}
