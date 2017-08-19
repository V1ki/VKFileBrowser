//
//  RepositoryUtils.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/18.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Result
import SwiftGit2

class RepositoryUtils: NSObject {
    
    
    
    class func getRepoSavePath(_ str : String) -> String{
        let pathComponents = str.components(separatedBy: "/")
        
        let last = (pathComponents.last?.components(separatedBy: ".").first)!
        let nextLast = (pathComponents[pathComponents.count - 2])
        
        return documentDir.appending("/\(nextLast)/\(last)")
    }
    
    class func clone(_ url:String , credentials cred:Credentials = .Default(),progresssHandler :((String?,Int,Int) -> Void)? = nil  ) -> Result<Repository,NSError>{

        let repoUrl = URL(string: url)

        let localPathUrl = URL(fileURLWithPath: getRepoSavePath(url))
        
        
        let repoResult = Repository.clone(from: repoUrl!, to: localPathUrl, localClone: false, bare: false, credentials: cred, checkoutStrategy: .Safe, checkoutProgress: {(str, completedSteps, totalSteps) in
            log("str:\(str ?? "")  completedSteps:\(completedSteps)  totalSteps:\(totalSteps)")
            
            if(progresssHandler != nil){
                progresssHandler!(str,completedSteps,totalSteps)
            }
            
        })
        return repoResult
        
    }

}
