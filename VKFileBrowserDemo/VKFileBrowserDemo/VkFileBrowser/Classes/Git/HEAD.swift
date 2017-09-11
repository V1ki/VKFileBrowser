//
//  HEAD.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/28.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import Result

// HEAD
extension Repository {
    
    func moveHEADToCommit(_ commit:Commit) -> Result<(), NSError> {
        var error:Int32 = 0
        var oid = commit.oid.oid
        error = git_repository_set_head_detached(self.pointer, &oid);
        guard error == GIT_OK.rawValue else{
            
            print("error:\(NSError(gitError: error, pointOfFailure: "git_repository_set_head_detached"))")
            return Result.failure(NSError(gitError: error, pointOfFailure: "git_repository_set_head_detached"))
        }
        print("moveHEADToCommit success")
        return Result.success()
    }
    
    func moveHEADToRefname(_ refname:String) -> Result<(), NSError>{
        var error:Int32 = 0
        error = git_repository_set_head(self.pointer, refname)
        guard error == GIT_OK.rawValue else{
            
            print("error:\(NSError(gitError: error, pointOfFailure: "git_repository_set_head"))")
            return Result.failure(NSError(gitError: error, pointOfFailure: "git_repository_set_head"))
        }
        print("moveHEADToRefname success")
        return Result.success()
    }
}
