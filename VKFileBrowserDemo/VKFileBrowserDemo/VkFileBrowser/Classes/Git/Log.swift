//
//  Log.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/10.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation


private func gitDiffLineCB(delta:UnsafePointer<git_diff_delta>?,hunk: UnsafePointer<git_diff_hunk>?, line:UnsafePointer<git_diff_line>?,playload: UnsafeMutableRawPointer?)->Int32{
    if delta != nil{
//        print("delta:\(DiffDelta((delta?.pointee)!)))")
    }
    
    if line != nil{
//        print("line:\(DiffLine((line?.pointee)!))  ")
    }
    
    if hunk != nil{
//        print("hunk:\(DiffHunk((hunk?.pointee)!))")
    }
    
    
    
    return 0
}

extension Repository {
    
    
    
    func log(_ filename:String) -> [Commit]{
        var walk : OpaquePointer? = nil
        var ps : OpaquePointer? = nil
        var list : OpaquePointer? = nil
        var oid = git_oid()
        var pathspec = NSArray(array: [filename]).git_strarray()
        
        var error = git_pathspec_new(&ps, &pathspec)
        
        
        git_revwalk_new(&walk, self.pointer)
        git_revwalk_sorting(walk, GIT_SORT_TIME.rawValue ^ GIT_SORT_TOPOLOGICAL.rawValue )
        git_revwalk_push_head(walk)
        
        var commits:[Commit] = [Commit]()
        
        while git_revwalk_next(&oid, walk) == 0 {
            var commit : OpaquePointer? = nil
            var poid = git_oid()
            var tree : OpaquePointer? = nil
            var ptree : OpaquePointer? = nil
            var pcommit : OpaquePointer? = nil
            var diff : OpaquePointer? = nil
            
            
            error = git_commit_lookup(&commit, self.pointer, &oid)
            error = git_commit_tree(&tree, commit)
            
            let count = git_commit_parentcount(commit)
            if(count != 0){
                let p1oid = git_commit_parent_id(commit, 0)
                poid = (p1oid?.pointee)!
                error = git_commit_lookup(&pcommit, self.pointer, &poid)
                error = git_commit_tree(&ptree, pcommit)
                git_diff_tree_to_tree(&diff, self.pointer, ptree, tree, nil)
            }
            
            if diff == nil{
                
                error = git_pathspec_match_tree(&list, tree, GIT_PATHSPEC_NO_MATCH_ERROR.rawValue, ps)
                
                guard error == GIT_OK.rawValue else{
                    continue
                }
                
                
                let entry = git_pathspec_match_list_entry(list, 0)
                if entry == nil {
                    continue
                }
                let commit = Commit(commit!)
                commits.append(commit)
            }
            else{
                git_diff_print(diff, GIT_DIFF_FORMAT_PATCH, gitDiffLineCB, nil)
                error = git_pathspec_match_diff(&list, diff,GIT_PATHSPEC_NO_GLOB.rawValue ^ GIT_PATHSPEC_NO_MATCH_ERROR.rawValue, ps)
                
                let entry = git_pathspec_match_list_diff_entry(list, 0)
                if entry == nil {
                    continue
                }
                
                let commit = Commit(commit!)
                commits.append(commit)
                
                git_commit_free(pcommit)
                git_tree_free(ptree)
                
                git_diff_free(diff)
                
            }
            
            git_pathspec_match_list_free(list)
            
            git_commit_free(commit)
            git_tree_free(tree)
        }
        
        git_pathspec_free(ps)
        print("commits.count:\(commits.count)")
        return commits
    }
    
}
