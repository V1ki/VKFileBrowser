//
//  Branch.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/4.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import Result

extension Branch {
    func trackingBranch(_ repo:Repository)->Result<Branch?,NSError>{
        if(isRemote){
            return Result.success(self)
        }
        
        var branchPointer : OpaquePointer? = nil
        var error : Int32 = 0
        error = git_branch_lookup(&branchPointer, repo.pointer, (self.shortName)!, GIT_BRANCH_LOCAL)
        guard error == GIT_OK.rawValue else {
            print("error:\(error) -- shortName:\(shortName)")
            return failure(error, "git_branch_lookup")
        }
        var outBranchPointer : OpaquePointer? = nil
        error = git_branch_upstream(&outBranchPointer, branchPointer)
        guard error == GIT_OK.rawValue else {
            return failure(error,"git_branch_upstream")
        }
        return Result.success((Branch(outBranchPointer!))!)
    }
    
    func updateTrackingBranch(_ trackingBranch:Branch){
        var error:Int32 = GIT_ENOTFOUND.rawValue
        if(trackingBranch.isRemote){
            error = git_branch_set_upstream(self.pointer, trackingBranch.name.replacingOccurrences(of: "refs/remotes/", with: ""))
        }else{
            error = git_branch_set_upstream(self.pointer, trackingBranch.shortName);
        }
        guard error == GIT_OK.rawValue else {
            log("error:\(NSError(gitError: error, pointOfFailure: "git_branch_set_upstream"))")
            return
        }
        
    }
    
}
