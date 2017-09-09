//
//  Reflog.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/9.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation

extension Repository {
    func readReflog(_ refName:String){
        var reflogPointer : OpaquePointer? = nil
        var error = git_reflog_read(&reflogPointer, self.pointer, refName)
        
        guard error == GIT_OK.rawValue else {
            print("error:\(NSError(gitError:error,pointOfFailure:"git_reflog_read"))")
            return
        }
        
        let count = git_reflog_entrycount(reflogPointer)
        
        for i in 0..<count {
            let logEntry = git_reflog_entry_byindex(reflogPointer, i)
            
        }
        
    }
    
}
