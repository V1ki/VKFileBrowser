//
//  DownloadUtils.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/17.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Alamofire

class DownloadUtils {
    
    //(() -> Swift.Void)? = nil
    
    class func downloadFile(_ url : URL , completionHanler handler  :((String) -> Void)? = nil ){
        
        let downloadFileDestination = self.getSavePath()
        let savePathStr = self.getSavePathStr(url)
//        print("path:\(savePathStr)  isExist:\(FileManager.default.fileExists(atPath: savePathStr))")
        
        if(!FileManager.default.fileExists(atPath: savePathStr)){
            let request = Alamofire.download(url, to: downloadFileDestination)
            request.responseData(completionHandler: {(response) in
                switch response.result{
                case .success(_):
                    if(handler != nil){
                        handler!(savePathStr)
                    }
                    
                    break
                    
                case .failure(_):
                    log("error:\(response.error)")
                    break
                    
                }
            })
        }else{
            if(handler != nil){
                handler!(savePathStr)
            }
            
        }
    }
    
    
    
    

    
    
    class func getSavePathStr(_ url: URL?) -> String {
        
        var pathUrl = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        if let pathComponents = url?.pathComponents {
            for i in 0..<(pathComponents.count-1) {
                pathUrl?.append("/"+pathComponents[i])
            }
            if(!FileManager.default.fileExists(atPath: pathUrl!)){
                do {
                    try FileManager.default.createDirectory(atPath: pathUrl!, withIntermediateDirectories: true, attributes:nil)
                } catch let error {
                    print(error)
                }
            }
            pathUrl?.append("/"+pathComponents[pathComponents.count-1])
            
        }
        
        
        return pathUrl!
        
    }
    
    
    class func getSavePath() -> DownloadRequest.DownloadFileDestination {
        return { temporaryURL, response in
            let directoryURLs = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
            
            if !directoryURLs.isEmpty {
                var pathUrl = directoryURLs[0]
                if let pathComponents = response.url?.pathComponents {
                    for i in 0..<(pathComponents.count-1) {
                        pathUrl = pathUrl.appendingPathComponent(pathComponents[i])
                    }
                    if(!FileManager.default.fileExists(atPath: pathUrl.absoluteString)){
                        do {
                            try FileManager.default.createDirectory(at: pathUrl, withIntermediateDirectories: true, attributes:nil)
                        } catch let error {
                            print(error)
                        }
                    }
                    pathUrl = pathUrl.appendingPathComponent(pathComponents[pathComponents.count-1])
                    
                }
                
                
                return (pathUrl, [])
            }
            
            return (temporaryURL, [])
        }
    }
    
    
    

}
