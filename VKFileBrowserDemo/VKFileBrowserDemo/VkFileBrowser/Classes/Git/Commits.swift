//
//  Commits.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/28.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import Result

import SwiftyUserDefaults




public func userSignatureForNow() -> Result<git_signature,NSError>{
    
    var signaturePointer: UnsafeMutablePointer<git_signature>? = UnsafeMutablePointer<git_signature>.allocate(capacity: 1)
    
    print("username:\(Defaults[.username]) email:\(Defaults[.email])")
    let error = git_signature_now(&signaturePointer, Defaults[.username], Defaults[.email])
    
    
    guard(error == GIT_OK.rawValue) else{
        log("error:\(NSError(gitError: error, pointOfFailure: "git_signature_now"))")
        return failure(error, "git_signature_now")
    }
    return Result.success((signaturePointer?.pointee)!)
}


extension Repository {
    func allCurrentCommits() -> [Commit] {
        let lastCommitResult = self.HEAD().flatMap{self.commit($0.oid)}
        var resultCommits = [Commit]()
        if let commit = lastCommitResult.value {
            resultCommits.append(commit)
            listParentCommits(self, commit){ commits in
                resultCommits.append(contentsOf: commits)
            }
        }
        return resultCommits
    }
    
    private func listParentCommits(_ repo:Repository , _ commit:Commit ,resultHandler: ([Commit]) -> Void){
        
        let commitParents = commit.parents.flatMap({repo.commit($0.oid)})
        
        var resultCommits = [Commit]()
        for ciResult in commitParents {
            guard let ci = ciResult.value else {
                continue
            }
            
            listParentCommits(repo, ci){ commits in
                resultCommits.append(contentsOf: commits)
            }
            resultCommits.append(ci)
        }
        resultHandler(resultCommits)
    }
    
    

    
    
    func commitFiles(_ files:[String] ,_ shouldPush:Bool = false) -> Result<(),NSError>{
        
        /*
         git_signature *me = NULL;
         int error = git_signature_now(&me, "Me", "me@example.com");
         
         const git_commit *parents[] = {parent1, parent2};
         
         git_oid new_commit_id = 0;
         error = git_commit_create(
         &new_commit_id,
         repo,
         "HEAD",                      /* name of ref to update */
         me,                          /* author */
         me,                          /* committer */
         "UTF-8",                     /* message encoding */
         "Flooberhaul the whatnots",  /* message */
         tree,                        /* root tree */
         2,                           /* parent count */
         parents);                    /* parents */
         git_signature_now(<#T##out: UnsafeMutablePointer<UnsafeMutablePointer<git_signature>?>!##UnsafeMutablePointer<UnsafeMutablePointer<git_signature>?>!#>, <#T##name: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##email: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>)
         git_commit_create(<#T##id: UnsafeMutablePointer<git_oid>!##UnsafeMutablePointer<git_oid>!#>, <#T##repo: OpaquePointer!##OpaquePointer!#>, <#T##update_ref: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##author: UnsafePointer<git_signature>!##UnsafePointer<git_signature>!#>, <#T##committer: UnsafePointer<git_signature>!##UnsafePointer<git_signature>!#>, <#T##message_encoding: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##message: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##tree: OpaquePointer!##OpaquePointer!#>, <#T##parent_count: Int##Int#>, <#T##parents: UnsafeMutablePointer<OpaquePointer?>!##UnsafeMutablePointer<OpaquePointer?>!#>)
         */
        
        
        
        var error : Int32 = 0
        let lastCommitResult = self.HEAD().flatMap{self.commit($0.oid)}
        
        
        let commit = lastCommitResult.value
        
        //如果lastCommit 是空，表示没有文件。
        let result = RepositoryUtils.makeTree(self, files)
        if(result.error != nil){
            log("error:\(result.error )")
            return .failure(result.error!)
        }
        
        var treeOid:git_oid  = (result.value)!
        
        
        var newTree : OpaquePointer? = nil
        error = git_tree_lookup(&newTree, self.pointer, &treeOid)
        guard(error == GIT_OK.rawValue) else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_tree_lookup"))")
            return failure(error, "git_tree_lookup")
        }
        var headPointer : OpaquePointer? = nil
        error = git_repository_head(&headPointer, self.pointer)
        
        guard(error == GIT_OK.rawValue) else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_repository_head"))")
            return failure(error, "git_repository_head")
        }
        
        //        repo.HEAD().value?.oid.description
        var walk : OpaquePointer? = nil
        error = git_revwalk_new(&walk, self.pointer);
        
        var oid = (self.HEAD().value?.oid.oid)!
        
        error = git_revwalk_push(walk, &oid)
        guard(error == GIT_OK.rawValue) else{
            print("error:\(NSError(gitError: error, pointOfFailure: "git_revwalk_push"))")
            return failure(error, "git_revwalk_push")
        }
        
        var signatureResult = userSignatureForNow()
        
        if(signatureResult.error != nil){
            log("error:\(signatureResult.error)")
            return .failure(signatureResult.error!)
        }
        var signature = (signatureResult.value)!
        
        var commitsPointer : [OpaquePointer?] = [OpaquePointer?]()
        
        
        if( commit != nil){
            
            var commitP : OpaquePointer? = nil
            var commitOid = (commit!).oid.oid
            error = git_commit_lookup(&commitP, self.pointer, &commitOid)
            guard(error == GIT_OK.rawValue) else{
                print("error:\(NSError(gitError: error, pointOfFailure: "git_commit_lookup"))")
                return failure(error, "git_commit_lookup")
            }
            
            commitsPointer.append(commitP)
        }
        
        var newCommitID : git_oid = git_oid()
        error = git_commit_create(&newCommitID, self.pointer, "HEAD", &signature , &signature , "UTF-8", "message", newTree, 1, &commitsPointer)
        
        guard(error == GIT_OK.rawValue) else{
            print("error:\(NSError(gitError: error, pointOfFailure: "git_commit_create"))")
            return failure(error, "git_commit_create")
        }
        
        
        var newCommit : OpaquePointer? = nil
        error = git_commit_lookup(&newCommit, self.pointer, &newCommitID)
        guard(error == GIT_OK.rawValue) else{
            print("error:\(NSError(gitError: error, pointOfFailure: "git_commit_lookup"))")
            return failure(error, "git_commit_lookup")
        }
        
        print("newCommit:\(Commit(newCommit!))")
        
        
        if shouldPush {
            if(self.localBranches().value?.isEmpty ?? false){
                return .success()
            }
            print("\((self.allRemotes().value?.first)!)")
            return RepositoryUtils.pushBranch(self, (self.localBranches().value?.first)!, (self.allRemotes().value?.first)!)
        }
        return .success()
        
    }
    
}
