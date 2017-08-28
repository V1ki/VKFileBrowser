//
//  Status.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/27.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import Result

struct StatusEntry : CustomStringConvertible{
    
    /**
     git_status_entry
     
     typedef enum {
     GIT_STATUS_CURRENT = 0,
     
     GIT_STATUS_INDEX_NEW        = (1u << 0),
     GIT_STATUS_INDEX_MODIFIED   = (1u << 1),
     GIT_STATUS_INDEX_DELETED    = (1u << 2),
     GIT_STATUS_INDEX_RENAMED    = (1u << 3),
     GIT_STATUS_INDEX_TYPECHANGE = (1u << 4),
     
     GIT_STATUS_WT_NEW           = (1u << 7),
     GIT_STATUS_WT_MODIFIED      = (1u << 8),
     GIT_STATUS_WT_DELETED       = (1u << 9),
     GIT_STATUS_WT_TYPECHANGE    = (1u << 10),
     GIT_STATUS_WT_RENAMED       = (1u << 11),
     GIT_STATUS_WT_UNREADABLE    = (1u << 12),
     
     GIT_STATUS_IGNORED          = (1u << 14),
     GIT_STATUS_CONFLICTED       = (1u << 15),
     } git_status_t;
     
     git_status_t status;
     git_diff_delta *head_to_index;
     git_diff_delta *index_to_workdir;
     */
    let status : git_status_t
    let headToIndex : DiffDelta?
    let indexToWorkdir : DiffDelta?
    
    var isNewFile : Bool {
        get{
            return (status.rawValue & GIT_STATUS_WT_NEW.rawValue) != GIT_STATUS_CURRENT.rawValue
        }
    }
    
    var isModified : Bool {
        get{
            return (status.rawValue & GIT_STATUS_WT_MODIFIED.rawValue) != GIT_STATUS_CURRENT.rawValue
        }
    }
    
    init(_ entry:git_status_entry) {
        status = entry.status
        if(entry.head_to_index != nil){
            headToIndex = DiffDelta(entry.head_to_index.pointee)
        }
        else{
            headToIndex = nil
        }
        if(entry.index_to_workdir != nil){
            indexToWorkdir = DiffDelta(entry.index_to_workdir.pointee)
        }
        else{
            indexToWorkdir = nil
        }
    }
    
    var description: String{
        get{
            return "status:\(status) headToIndex:\(headToIndex) indexToWorkdir:\(indexToWorkdir)"
        }
    }
    
}



extension Repository {
    
    
    func allStatus() -> Result <[StatusEntry],NSError> {
        var statusesPointer : OpaquePointer? = nil
        
        /*
         let pointer1 = UnsafeMutablePointer<git_strarray>.allocate(capacity: 1)
         let result1 = git_reference_list(pointer1, repo.pointer)
         
         guard result1 == GIT_OK.rawValue else {
         pointer1.deallocate(capacity: 1)
         return
         }
         
         let strarray = pointer1.pointee
         let remotes: [String] = strarray.map {
         return $0
         }
         log("remotes:\(remotes)")
         
         var opts : git_status_options = git_status_options(version: UInt32(GIT_STATUS_OPTIONS_VERSION), show: GIT_STATUS_SHOW_INDEX_AND_WORKDIR, flags: GIT_STATUS_OPT_INCLUDE_UNMODIFIED.rawValue, pathspec:strarray)
         git_status_init_options(&opts, UInt32(GIT_STATUS_OPTIONS_VERSION))
         */
        
        let result = git_status_list_new(&statusesPointer, self.pointer, nil)
        guard result == GIT_OK.rawValue else {
            return Result.failure(NSError(gitError: result, pointOfFailure: "git_status_list_new"))
        }
        let count = git_status_list_entrycount(statusesPointer);
        var statusEntries = [StatusEntry]()
        
        for i in 0..<count{
            let entry = git_status_byindex(statusesPointer, i)?.pointee
            let statusEntry = StatusEntry(entry!)
            statusEntries.append(statusEntry)
        }
        
        return Result.success(statusEntries)
        
        
    }
    
    
    
    func gitFileStatus(_ path:String = "README.md"){
        var statusFlags  = GIT_STATUS_INDEX_NEW.rawValue
        let result = git_status_file(&statusFlags, self.pointer, path)
        guard result == GIT_OK.rawValue else {
            return
        }
        
        log("statusFlags:\(statusFlags)")
        
        
        
    }
    
}

