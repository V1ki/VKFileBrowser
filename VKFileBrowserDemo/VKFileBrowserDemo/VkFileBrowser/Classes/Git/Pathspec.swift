//
//  Pathspec.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/11.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation

extension Repository {
    
    
    //git_pathspec_match_tree(&list, tree, GIT_PATHSPEC_NO_MATCH_ERROR.rawValue, ps)
    func pathspecMatchTree(_ tree : OpaquePointer, _ ps:OpaquePointer ,_ callback:(OpaquePointer) -> Swift.Void){
        var list : OpaquePointer? = nil
        let error = git_pathspec_match_tree(&list, tree, GIT_PATHSPEC_NO_MATCH_ERROR.rawValue, ps)
        guard error == GIT_OK.rawValue else {
            return
        }
        callback(list!)
    }
    
    //git_pathspec_match_diff(&list, diff,GIT_PATHSPEC_NO_GLOB.rawValue ^ GIT_PATHSPEC_NO_MATCH_ERROR.rawValue, ps)
//    func pathspecMatchDiff(_ diff:)
    
}
