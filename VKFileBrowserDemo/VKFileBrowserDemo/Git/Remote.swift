//
//  Remote.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/5.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import Result

extension Remote {
    
    var pushUrlStr : String {
        get {
            let pushurl = git_remote_pushurl(self.pointer);
            if(pushurl != nil){
                return String(validatingUTF8:pushurl!)!
            }
            return ""
        }
    }
    
    func rename(_ repo:Repository, _ name:String) -> Result<(),NSError>{
        let problematic_refspecsPointer = UnsafeMutablePointer<git_strarray>.allocate(capacity: 1)
        let error = git_remote_rename(problematic_refspecsPointer,repo.pointer, git_remote_name(self.pointer), name);
        
        
        guard error == GIT_OK.rawValue else {
            problematic_refspecsPointer.deallocate(capacity: 1)
            return failure(error, "git_remote_rename")
        }
        
        git_strarray_free(problematic_refspecsPointer)
        problematic_refspecsPointer.deallocate(capacity: 1)
        return .success()
    }
    
    /// The fetch refspecs for this remote.
    ///
    /// This array will contain Strings of the form
    /// `+refs/heads/*:refs/remotes/REMOTE/*`.
    func fetchRefspecs() -> Result<[String],NSError>{
        let refspecsPointer = UnsafeMutablePointer<git_strarray>.allocate(capacity: 1)
        let error = git_remote_get_fetch_refspecs(refspecsPointer, self.pointer);
        
        guard error == GIT_OK.rawValue else {
            refspecsPointer.deallocate(capacity: 1)
            return failure(error, "git_remote_get_fetch_refspecs")
        }
        
        let refspecs :[String] = refspecsPointer.pointee.map{return $0}
        
        git_strarray_free(refspecsPointer)
        refspecsPointer.deallocate(capacity: 1)
        
        return .success(refspecs)
    }
    
    /// The push refspecs for this remote.
    ///
    /// This array will contain NSStrings of the form
    /// `+refs/heads/*:refs/remotes/REMOTE/*`.
    func pushRefspecs() -> Result<[String],NSError>{
        let refspecsPointer = UnsafeMutablePointer<git_strarray>.allocate(capacity: 1)
        let error = git_remote_get_push_refspecs(refspecsPointer, self.pointer);
        
        guard error == GIT_OK.rawValue else {
            refspecsPointer.deallocate(capacity: 1)
            return failure(error, "git_remote_get_fetch_refspecs")
        }
        
        let refspecs :[String] = refspecsPointer.pointee.map{return $0}
        
        git_strarray_free(refspecsPointer)
        refspecsPointer.deallocate(capacity: 1)
        
        return .success(refspecs)
    }
    
    func updateURL(_ repo:Repository, _ url:String) -> Result<(),NSError>{
        let error = git_remote_set_url(repo.pointer, self.name ,url);
        guard error == GIT_OK.rawValue else {
            return failure(error, "git_remote_set_url")
        }
        return .success()
    }

    func updatePushUrl(_ repo:Repository,_ url:String) -> Result<(),NSError>{
        if(self.pushUrlStr == url){
            return .success()
        }
        let error = git_remote_set_pushurl(repo.pointer,name,url)
        guard error == GIT_OK.rawValue else {
            return failure(error, "git_remote_set_pushurl")
        }
        return .success()
    }
    
    

    func addFetchRefspec(_ repo:Repository,fetchRefspec:String) -> Result<(),NSError>{
        let fetchRefspecsResult = self.fetchRefspecs()
        if let fetchRefspecs = fetchRefspecsResult.value {
            if(fetchRefspecs.contains(fetchRefspec)){
                return .success()
            }
        }
        let error = git_remote_add_fetch(repo.pointer,name,fetchRefspec)
        guard error == GIT_OK.rawValue else {
            return failure(error, "git_remote_add_fetch")
        }
        return .success()
    }
    
    
}
