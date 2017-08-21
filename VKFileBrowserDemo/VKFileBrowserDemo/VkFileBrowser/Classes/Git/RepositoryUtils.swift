//
//  RepositoryUtils.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/18.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Result


class RepositoryUtils: NSObject {
    
    
    class func initGit(){
        git_libgit2_init()
    }
    class func shutdownGit(){
        git_libgit2_shutdown()
    }
    
    
    class func getRepoSavePath(_ str : String) -> String{
        let pathComponents = str.components(separatedBy: "/")
        
        let last = (pathComponents.last?.components(separatedBy: ".").first)!
        let nextLast = (pathComponents[pathComponents.count - 2])
        
        var path = documentDir.appending("/\(nextLast)/\(last)")
        
        var i = 0
        while FileManager.default.fileExists(atPath: path) {
            i += 1
            path = documentDir.appending("/\(nextLast)/\(last)-\(i)")
        }
        
        return path
    }
    
    class func isGitRepository(_ url:URL) -> Bool{
        
        if(url.isFileURL){
            
            let result = RepositoryUtils.at(url)
            
            if result.value != nil {
                //当前处于git仓库下
                return true
            }
            return false
        }
        
        
        return true
        
    }
    
    
    class func at(_ url:URL) -> Result<Repository,NSError> {

        return Repository.at(url)
    }
    
    class func clone(_ url:String , credentials cred:Credentials = .default,progresssHandler :((String?,Int,Int) -> Void)? = nil  ) -> Result<Repository,NSError>{

        let repoUrl = URL(string: url)

        let localPathUrl = URL(fileURLWithPath: getRepoSavePath(url))
        
        
        
        let repoResult = Repository.clone(from: repoUrl!, to: localPathUrl, localClone: false, bare: false, credentials: cred, checkoutStrategy: .Safe, checkoutProgress: {(str, completedSteps, totalSteps) in
            log("str:\(str ?? "")  completedSteps:\(completedSteps)  totalSteps:\(totalSteps)")
            
            if(progresssHandler != nil){
                progresssHandler!(str,completedSteps,totalSteps)
            }
            
        })
        if let error = repoResult.error {
            log("error:\(error)")
        }
        return repoResult
        
    }

    
    class func listAllCommits(_ repo:Repository ,resultHandler:([Commit]) -> Void ){
        let lastCommitResult = repo.HEAD().flatMap{repo.commit($0.oid)}
        var resultCommits = [Commit]()
        if let commit = lastCommitResult.value {
            resultCommits.append(commit)
            listParentCommits(repo, commit){ commits in
                resultCommits.append(contentsOf: commits)
                resultHandler(resultCommits)
            }
            
            resultCommits.sort{ ci1,ci2 in return ci1.committer.time > ci2.committer.time }
            print("commit:\(commit)")
            
            for ci in resultCommits {
                listFiles(repo, ci.tree.oid)
            }
            
            
            diff(repo, OID(string:"bc0d290b5a0b0fb76cc32dbe4d8c3437872b53da")!, OID(string:"12b3f4b5ad1ca0327e0d079de54116a5a4311d99")!)
            
        }
    }
    
    private class func listParentCommits(_ repo:Repository , _ commit:Commit ,resultHandler: ([Commit]) -> Void){
        
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
    
    
    class func listFiles(_ repo:Repository, _ oid:OID){
        let tree = repo.tree(oid).value

        for entry in (tree?.entries)! {
            let treeEntry = entry.value
            
            switch treeEntry.object {
            case .blob:
                //文件
                print("\(treeEntry.name)")
                break
            case .tree:
                //目录
                print("enter \(treeEntry.name)   -- \(treeEntry.object.oid)")
//                listFiles(repo, treeEntry.object.oid)
                break

            default:
                print("Default")
                break
            }
            
            
        }
    }

    
    private class func createBranch(_ repo:Repository,commit:Commit){
        
        var branchPointer : OpaquePointer? = nil
        
        var commitPointer: OpaquePointer? = nil
        var oid = commit.oid.oid
        let result = git_object_lookup(&commitPointer, repo.pointer, &oid, GIT_OBJ_COMMIT)
        
        guard result == GIT_OK.rawValue else {
            return
        }
        
        git_branch_create(&branchPointer, repo.pointer, "", commitPointer, 0)
        
        
        
    }
    
    
    class func diff(_ repo:Repository ,_ oldTreeOid:OID,_ newTreeOid:OID){
        var pointer : OpaquePointer? = nil
        var oldTreePointer : OpaquePointer? = nil
        var oldTreeOidOid = oldTreeOid.oid
        let oldTreeResult = git_object_lookup(&oldTreePointer, repo.pointer, &(oldTreeOidOid), GIT_OBJ_TREE)
        guard oldTreeResult == GIT_OK.rawValue else {
            return
        }
        
        var newTreePointer : OpaquePointer? = nil
        var newTreeOidOid = newTreeOid.oid
        let newTreeResult = git_object_lookup(&newTreePointer, repo.pointer, &(newTreeOidOid), GIT_OBJ_TREE)
        guard newTreeResult == GIT_OK.rawValue else {
            return
        }
        
        let diffResult = git_diff_tree_to_tree(&pointer, repo.pointer, oldTreePointer, newTreePointer, nil)
        guard diffResult == GIT_OK.rawValue else {
            return
        }
        
        
        print("pass diff")
        
        
        
        
        git_object_free(oldTreePointer)
        git_object_free(newTreePointer)
        git_diff_free(pointer)
        
    }
    

    
}


