//
//  RepositoryUtils.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/18.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Result
import SwiftyUserDefaults

public typealias SidebandProgressProgressBlock = (String,Int) -> Void
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
    
    class func clone(_ url:String ,_ progresssHandler :SidebandProgressProgressBlock? = nil  ) -> Result<Repository,NSError>{
        
        let repoUrl = URL(string: url)
        
        let localPathUrl = URL(fileURLWithPath: getRepoSavePath(url))
        
        let repoResult = Repository.cloneWithCustomFetch(repoUrl!, localPathUrl,progresssHandler)
        /*
         , checkoutProgress: {(str, completedSteps, totalSteps) in
         log("str:\(str ?? "")  completedSteps:\(completedSteps)  totalSteps:\(totalSteps)")
         
         if(progresssHandler != nil){
         progresssHandler!(str,completedSteps,totalSteps)
         },
         
         }
         */
        if let error = repoResult.error {
            log("error:\(error)")
        }
        return repoResult
        
    }
    
    
    class func listFiles(_ repo:Repository, _ oid:OID){
        let tree = repo.tree(oid).value
        log("repo.directoryURL:\(repo.directoryURL?.path)")
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
    
    
    class func createBranch(_ repo:Repository,commit:Commit, branchName:String) -> Result<Branch,NSError>{
        var error : Int32 = 0
        var branchPointer : OpaquePointer? = nil
        
        var commitPointer: OpaquePointer? = nil
        var oid = commit.oid.oid
        error = git_object_lookup(&commitPointer, repo.pointer, &oid, GIT_OBJ_COMMIT)
        
        guard error == GIT_OK.rawValue else {
            return failure(error, "git_object_lookup")
        }
        
        error = git_branch_create(&branchPointer, repo.pointer, branchName, commitPointer, 0)
        guard error == GIT_OK.rawValue else {
            return failure(error, "git_branch_create")
        }
        return Result.success(Branch(branchPointer!)!)
    }
    
    class func fetchOptions(_ progresssHandler :SidebandProgressProgressBlock? = nil ) -> git_fetch_options {
        let pointer = UnsafeMutablePointer<git_fetch_options>.allocate(capacity: 1)
        git_fetch_init_options(pointer, UInt32(GIT_FETCH_OPTIONS_VERSION))
        
        var options = pointer.move()
        
        pointer.deallocate(capacity: 1)
        if(progresssHandler != nil){
            let blockPointer = UnsafeMutablePointer<SidebandProgressProgressBlock>.allocate(capacity: 1)
            blockPointer.initialize(to: progresssHandler!)
            options.callbacks.payload = UnsafeMutableRawPointer(blockPointer)
        }
        
        options.callbacks.transfer_progress = transfer_progress_cb
        options.callbacks.pack_progress = packbuilder_progress_cb
        options.callbacks.sideband_progress = transport_message_cb
        options.callbacks.credentials = credential_cb
        
        return options
    }
    
    
    class func fetchRemote(_ repo:Repository,_ remoteName:String ,_ progresssHandler :SidebandProgressProgressBlock? = nil ) {
        var error:Int32 = 0
        
        var remote : OpaquePointer? = nil
        error = git_remote_lookup(&remote, repo.pointer, remoteName)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_lookup"))")
            return
        }
        
        let strArrayPointer  = UnsafeMutablePointer<git_strarray>.allocate(capacity: 1)
        error = git_remote_get_fetch_refspecs(strArrayPointer, remote)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_get_fetch_refspecs"))")
            return
        }
        var fo = fetchOptions(progresssHandler)
        error = git_remote_fetch(remote,strArrayPointer, &fo, "fetching remote : origin");
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_fetch"))")
            return
        }
        
        log("fetch success")
        
        let branch = repo.localBranches().value?.first
        
        if(branch == nil){
            // current no branch .do not need merge
            return
        }
        
        let localBranch = (branch)!
        
        if(localBranch.isLocal){
            log("isLocal")
            let trackingBranchResult = localBranch.trackingBranch(repo)
            if let trackingBranch = trackingBranchResult.value {
                log("trackingBranch:\(trackingBranch)")
                let trackingCommit = (trackingBranch?.commit)!
                let treeOID = (repo.commit(trackingCommit.oid).value)?.tree.oid
                
                mergeBranch(repo, localBranch, trackingBranch!)
            }else{
                log("error:\(trackingBranchResult.error)")
            }
        }
        
        
    }
    
    class func checkoutBranch(_ repo:Repository,_ branch:Branch){
        var branchPointer:OpaquePointer? = nil
        
        git_branch_lookup(&branchPointer, repo.pointer, branch.name,branch.isLocal ?GIT_BRANCH_LOCAL : GIT_BRANCH_REMOTE)
        
        let refname = (git_reference_name(branchPointer))!
        
        var commitPointer:OpaquePointer? = nil
        var commitOid = branch.oid.oid
        
        let result = checkout(repo, branchPointer, String(validatingUTF8:refname)! )
        
        guard result.error == nil else{
            return
        }
        print("branch.shortName:\(branch.shortName)")
        
        if(branch.isLocal){
            return
        }
        let branchName = branch.shortName!
        let localBranchName = (branchName.components(separatedBy: "/").last)!
        git_commit_lookup(&commitPointer, repo.pointer, &commitOid)
        
        let lcommit = Commit(commitPointer!)
        print("\(lcommit)  -- localBranchName:\(localBranchName)")
        
        
        let branchResult = createBranch(repo, commit: lcommit, branchName: localBranchName)
        
        if let localbranch = branchResult.value {
            log("checkout \(branch.longName)  --> \(localbranch.longName) \(branch.pointer)")
            localbranch.updateTrackingBranch(branch)
            repo.moveHEADToRefname(localbranch.longName)
        }
        
    }
    
    
    
    class func checkoutRefname(_ repo:Repository,_ obj:OpaquePointer?,_ refname:String) -> Result<(),NSError> {
        var error : Int32 = 0
        
        var option = git_checkout_options()
        error = git_checkout_init_options(&option, UInt32(GIT_CHECKOUT_OPTIONS_VERSION))
        option.checkout_strategy = GIT_CHECKOUT_FORCE.rawValue
        option.target_directory = UnsafePointer<Int8>("\((repo.directoryURL?.path)!)")
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_checkout_init_options"))")
            return failure(error, "git_checkout_init_options")
        }
        error = git_checkout_tree(repo.pointer, obj, &option)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_checkout_tree"))")
            return failure(error, "git_checkout_tree")
        }
        
        //        let refname = git_reference_name(obj)
        
        _ = repo.moveHEADToRefname(refname)
        print("checkout success")
        return .success()
        
    }
    
    
    
    class func checkout(_ repo:Repository,_ newRefPointer:OpaquePointer?,_ refname:String) -> Result<(),NSError>{
        var error : Int32 = 0
        
        var obj : OpaquePointer? = nil
        error = git_reference_peel(&obj, newRefPointer, GIT_OBJ_ANY)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_reference_peel"))")
            return failure(error, "git_reference_peel")
        }
        return checkoutRefname(repo, obj, refname)
        
    }
    
    
    
    private class func mergeBranch(_ repo:Repository, _ currentBranch:Branch ,_ remoteBranch:Branch){
        var error:Int32 = 0
        let localCommit = (repo.commit(currentBranch.oid).value)!
        let remoteCommit = (repo.commit(remoteBranch.oid).value)!
        var localCommitOID = localCommit.oid.oid
        var remoteCommitOID = remoteCommit.oid.oid
        
        var localBranchPointer : OpaquePointer? = nil
        error = git_branch_lookup(&localBranchPointer, repo.pointer, currentBranch.shortName!, GIT_BRANCH_LOCAL)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_branch_lookup"))")
            return
        }
        var remoteBranchPointer : OpaquePointer? = nil
        error = git_branch_lookup(&remoteBranchPointer, repo.pointer, remoteBranch.shortName!, GIT_BRANCH_REMOTE)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_branch_lookup"))")
            return
        }
        if(localCommit.oid == remoteCommit.oid) {
            return
        }
        
        var annotatedCommit : OpaquePointer? = nil
        
        error = git_annotated_commit_lookup(&annotatedCommit, repo.pointer, &remoteCommitOID)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_annotated_commit_lookup"))")
            return
        }
        var analysis = GIT_MERGE_ANALYSIS_NONE
        var preference = GIT_MERGE_PREFERENCE_NONE
        error = git_merge_analysis(&analysis, &preference, repo.pointer, &annotatedCommit, 1)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_merge_analysis"))")
            return
        }
        git_annotated_commit_free(annotatedCommit)
        
        if((analysis.rawValue & GIT_MERGE_ANALYSIS_UP_TO_DATE.rawValue) != 0){
            print("ANALYSIS_UP_TO_DATE")
            
            return
        }else if((analysis.rawValue & GIT_MERGE_ANALYSIS_FASTFORWARD.rawValue) != 0 || (analysis.rawValue & GIT_MERGE_ANALYSIS_UNBORN.rawValue) != 0 )
        {
            // Fast-forward branch
            var newRefPointer : OpaquePointer? = nil
            if(git_reference_type(localBranchPointer) == GIT_REF_OID){
                var remoteOid = remoteBranch.oid.oid
                error = git_reference_set_target(&newRefPointer, localBranchPointer, &remoteOid, "merge origin: Fast-forward")
                guard error == GIT_OK.rawValue else{
                    
                    log("error:\(NSError(gitError: error, pointOfFailure: "git_reference_set_target"))")
                    return
                }
            }else{
                error = git_reference_symbolic_set_target(&newRefPointer, localBranchPointer, remoteBranch.oid.description, "merge origin: Fast-forward")
                guard error == GIT_OK.rawValue else{
                    
                    log("error:\(NSError(gitError: error, pointOfFailure: "git_reference_symbolic_set_target"))")
                    return
                }
            }
            
            let refname = (git_reference_name(newRefPointer))!
            
            checkout(repo, newRefPointer,String(validatingUTF8:refname)!)
            
            
        }
        else{
            // Do normal merge
            print("normal merge")
            var localTreeOid = localCommit.tree.oid.oid
            var remoteTreeOid = remoteCommit.tree.oid.oid
            
            var localTree : OpaquePointer? = nil
            var remoteTree : OpaquePointer? = nil
            
            error = git_tree_lookup(&localTree, repo.pointer, &localTreeOid)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_tree_lookup"))")
                return
            }
            error = git_tree_lookup(&remoteTree, repo.pointer, &remoteTreeOid)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_tree_lookup"))")
                return
            }
            //find common ancestor
            var idx : OpaquePointer? = nil
            var ancestorTreePointer: OpaquePointer? = nil
            error = git_merge_trees(&idx, repo.pointer, ancestorTreePointer, localTree, remoteTree, nil)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_merge_trees"))")
                return
            }
            if(git_index_has_conflicts(idx) == 1){
                var iterator : OpaquePointer? = nil
                git_index_conflict_iterator_new(&iterator, idx)
                var files = [String]()
                while true {
                    var ancestor : UnsafePointer<git_index_entry>? = nil
                    var ours : UnsafePointer<git_index_entry>? = nil
                    var theirs : UnsafePointer<git_index_entry>? = nil
                    
                    error = git_index_conflict_next(&ancestor, &ours, &theirs, iterator)
                    
                    guard error != GIT_ITEROVER.rawValue else {
                        break;
                    }
                    guard error == GIT_OK.rawValue else {
                        break;
                    }
                    files.append(String(validatingUTF8: (ours?.pointee.path)!)!)
                    
                }
                
                
                var merge_opts = git_merge_options()
                git_merge_init_options(&merge_opts, UInt32(GIT_MERGE_OPTIONS_VERSION))
                
                var checkout_opts = git_checkout_options()
                git_checkout_init_options(&checkout_opts, UInt32(GIT_CHECKOUT_OPTIONS_VERSION))
                checkout_opts.checkout_strategy = (GIT_CHECKOUT_SAFE.rawValue | GIT_CHECKOUT_ALLOW_CONFLICTS.rawValue)
                
                var annotatedCommit : OpaquePointer? = nil
                var remoteOid = remoteCommit.oid.oid
                git_annotated_commit_lookup(&annotatedCommit, repo.pointer, &remoteOid)
                
                git_merge(repo.pointer, &annotatedCommit, 1, &merge_opts, &checkout_opts)
                
                
            }
            
            var newTreeOid = git_oid()
            error = git_index_write_tree_to(&newTreeOid, idx, repo.pointer)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_index_write_tree_to"))")
                return
            }
            var newTree : OpaquePointer? = nil
            error = git_object_lookup(&newTree, repo.pointer, &newTreeOid, GIT_OBJ_TREE)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_object_lookup"))")
                return
            }
            var commitsPointer : [OpaquePointer?] = [OpaquePointer?]()
            
            var localCommitPointer : OpaquePointer? = nil
            var remoteCommitPointer : OpaquePointer? = nil
            error = git_commit_lookup(&localCommitPointer, repo.pointer, &localCommitOID)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_commit_lookup"))")
                return
            }
            error = git_commit_lookup(&remoteCommitPointer, repo.pointer, &remoteCommitOID)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_commit_lookup"))")
                return
            }
            
            commitsPointer.append(localCommitPointer)
            commitsPointer.append(remoteCommitPointer)
            
            var signature = (userSignatureForNow().value)!
            var newCommitOid = git_oid()
            error = git_commit_create(&newCommitOid, repo.pointer, currentBranch.longName, &signature, &signature, "UTF-8", "merge", newTree, 2, &commitsPointer)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_commit_create"))")
                return
            }
            
            var newCommit : OpaquePointer? = nil
            error = git_commit_lookup(&newCommit, repo.pointer, &newCommitOid)
            guard error == GIT_OK.rawValue else{
                
                log("error:\(NSError(gitError: error, pointOfFailure: "git_commit_lookup"))")
                return
            }
            checkout(repo, localBranchPointer,currentBranch.longName)
            
            print("normal merge success")
        }
    }
    
    /**
    */
    class func checkoutCommit(_ repo:Repository,_ commit:Commit) -> Result<(),NSError>{
        var error:Int32 = 0
        
        var obj : OpaquePointer? = nil
        var commitOid = commit.oid.oid
        error = git_commit_lookup(&obj, repo.pointer, &commitOid)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_commit_lookup"))")
            
            return failure(error, "git_commit_lookup")
        }
        var treeOid = commit.tree.oid.oid
        error = git_tree_lookup(&obj, repo.pointer, &treeOid)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_tree_lookup"))")

            return failure(error, "git_tree_lookup")
        }
        
        var option = git_checkout_options()
        error = git_checkout_init_options(&option, UInt32(GIT_CHECKOUT_OPTIONS_VERSION))
        option.checkout_strategy = GIT_CHECKOUT_ALLOW_CONFLICTS.rawValue | GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH.rawValue | GIT_CHECKOUT_RECREATE_MISSING.rawValue | GIT_CHECKOUT_REMOVE_UNTRACKED.rawValue | GIT_CHECKOUT_SAFE.rawValue 
        option.target_directory = UnsafePointer<Int8>("\((repo.directoryURL?.path)!)")
        option.progress_cb = checkout_progress_cb
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_checkout_init_options"))")
            return failure(error, "git_checkout_init_options")
        }
        
        error = git_checkout_tree(repo.pointer, obj, &option)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_checkout_tree"))")
            return failure(error, "git_checkout_tree")
        }
        print("checkout success")
        _ = repo.moveHEADToCommit(commit)
        return Result.success()
    }
    
    class func addRemote(_ repo:Repository,_ remoteName:String,_ remoteURL:String) ->Result<Remote,NSError> {
        
        var remote : OpaquePointer? = nil
        let error = git_remote_create(&remote, repo.pointer,  remoteName, remoteURL)
        
        guard(error == GIT_OK.rawValue)else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_create"))")
            return failure(error, "git_remote_create")
        }
        return Result.success(Remote(remote!))
        
        //        git_remote_add_push(repo.pointer, <#T##remote: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>, <#T##refspec: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>)
    }
    
    class func deleteRemote(_ repo:Repository,_ remoteName:String) -> Result<(),NSError>{
        let error = git_remote_delete(repo.pointer, remoteName)
        guard(error == GIT_OK.rawValue)else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_delete"))")
            return failure(error, "git_remote_delete")
        }
        return Result.success()
    }
    
    
    class func initFirstCommit(_ repo:Repository){
        var error:Int32  = 0
        //如果lastCommit 是空，表示没有文件。
        let result = makeTree(repo,nil, [])
        if(result.error != nil){
            return
        }
        
        var treeOid:git_oid  = (result.value)!
        
        
        var newTree : OpaquePointer? = nil
        error = git_tree_lookup(&newTree, repo.pointer, &treeOid)
        if(error != GIT_OK.rawValue) {
            log("error:\(NSError(gitError: error, pointOfFailure: "git_tree_lookup"))")
            return
        }
        let signatureResult = userSignatureForNow()
        
        
        if(signatureResult.error != nil) {
            log("error:\(signatureResult.error)")
            return
        }
        
        var signature = (signatureResult.value)!
        
        
        var commitsPointer : [OpaquePointer?] = [OpaquePointer?]()
        
        var newCommitID : git_oid = git_oid()
        error = git_commit_create(&newCommitID, repo.pointer, "HEAD", &signature , &signature , "UTF-8", "message", newTree, 1, &commitsPointer)
        
        if ( error == GIT_OK.rawValue){} else{
            print("error:\(NSError(gitError: error, pointOfFailure: "git_commit_create"))")
            return
        }
        
        
        var newCommit : OpaquePointer? = nil
        error = git_commit_lookup(&newCommit, repo.pointer, &newCommitID)
        if ( error == GIT_OK.rawValue){} else{
            print("error:\(NSError(gitError: error, pointOfFailure: "git_commit_lookup"))")
        }
        
    }
    
    
    
    
    
    class func pushRefspecs(_ repo:Repository,_ refspec:String,_ remote:Remote) -> Result<(),NSError> {
        
        var error:Int32 = 0
        var remotePointer: OpaquePointer? = nil
        error = git_remote_lookup(&remotePointer, repo.pointer, remote.name)
        guard error == GIT_OK.rawValue else{
            
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_lookup"))")
            return failure(error, "git_remote_lookup")
        }
        var remote_callbacks = git_remote_callbacks()
        
        error = git_remote_init_callbacks(&remote_callbacks, UInt32(GIT_REMOTE_CALLBACKS_VERSION))
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_init_callbacks"))")
            return failure(error, "git_remote_init_callbacks")
        }
        remote_callbacks.credentials = credential_cb
        remote_callbacks.push_transfer_progress = push_transfer_progress
        
        error = git_remote_connect(remotePointer, GIT_DIRECTION_PUSH, &remote_callbacks, nil)
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_connect"))")
            return failure(error, "git_remote_connect")
        }
        git_remote_disconnect(remotePointer)
        
        var push_options = git_push_options()
        error = git_push_init_options(&push_options, UInt32(GIT_PUSH_OPTIONS_VERSION))
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_push_init_options"))")
            return failure(error, "git_push_init_options")
        }
        
        push_options.callbacks = remote_callbacks
        
        var git_refspecs:git_strarray = NSArray(array: [refspec]).git_strarray()
        
        error = git_remote_upload(remotePointer, &git_refspecs, &push_options)
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_upload"))")
            return failure(error, "git_remote_upload")
        }
        
        
        let download_tags = GIT_REMOTE_DOWNLOAD_TAGS_UNSPECIFIED
        let reflog_message = "pushing remote origin"
        
        error = git_remote_update_tips(remotePointer,&remote_callbacks, Int32(1), download_tags, reflog_message)
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_remote_update_tips"))")
            return failure(error, "git_remote_update_tips")
        }
        
        print("push success")
        return .success()
    }
    
    
    class func pushBranch(_ repo:Repository, _ branch:Branch,_ remote:Remote)-> Result<(),NSError> {
        var refspec = ""
        var remoteBranchReference = "refs/heads/\((branch.shortName)!)"
        
//        let trackingBranchResult = branch.trackingBranch(repo)
//
//        if let trackingBranch = trackingBranchResult.value {
//            remoteBranchReference = "refs/heads/\((trackingBranch?.shortName)!)"
//        }
//
        refspec = "refs/heads/\((branch.shortName)!):\(remoteBranchReference)"
        print("\(refspec)")

        // init ,push
        //refs/heads/master:refs/heads/master
        return pushRefspecs(repo, refspec,remote)
    }
    
    
    class func deleteBranch(_ repo:Repository ){}
    
    private class func makeTree(_ repo:Repository,_ commit:Commit?,_ files:[String]) -> Result<git_oid,NSError>{
        var error : Int32 = 0
        
        var oldTree : OpaquePointer? = nil
        if(commit != nil){
            var oid = (commit!).tree.oid.oid
            error = git_tree_lookup(&oldTree, repo.pointer, &oid)
            if(error != GIT_OK.rawValue) {
                log("error:\(NSError(gitError: error, pointOfFailure: "git_tree_lookup"))")
                return failure(error, "git_tree_lookup")
            }
        }
        
        
        var treeBuilder : OpaquePointer? = nil
        error = git_treebuilder_new(&treeBuilder, repo.pointer, oldTree)
        
        if(error != GIT_OK.rawValue) {
            log("error:\(NSError(gitError: error, pointOfFailure: "git_treebuilder_new"))")
            return failure(error, "git_treebuilder_new")
        }
        
        git_tree_free(oldTree)
        
        var _git_odb : OpaquePointer? = nil
        
        error = git_repository_odb(&_git_odb, repo.pointer);
        
        var stream :UnsafeMutablePointer<git_odb_stream>? = nil
        error = git_odb_open_wstream(&stream, _git_odb, 3, GIT_OBJ_BLOB)
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_odb_open_wstream"))")
            return failure(error, "git_odb_open_wstream")
        }
        error = git_odb_stream_write(stream, "123", 3)
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_odb_stream_write"))")
            return failure(error, "git_odb_stream_write")
        }
        var oid = git_oid()
        error = git_odb_stream_finalize_write(&oid, stream);
        guard error == GIT_OK.rawValue else{
            log("error:\(NSError(gitError: error, pointOfFailure: "git_odb_stream_finalize_write"))")
            return failure(error, "git_odb_stream_finalize_write")
        }
        git_odb_stream_free(stream)
        
        for file in files {
            //
            //            var obj : OpaquePointer? = nil
            //            print("HEAD:\((file))")
            //            error = git_revparse_single(&obj, repo.pointer, "HEAD:\((file))");
            //            if(error != GIT_OK.rawValue) {
            //                log("error:\(NSError(gitError: error, pointOfFailure: "git_revparse_single"))")
            //                return Result.failure(NSError(gitError: error, pointOfFailure: "git_revparse_single"))
            //            }
            //
            //            error = git_treebuilder_insert(nil, treeBuilder, "\(file)", git_object_id(obj), GIT_FILEMODE_BLOB)
            error = git_treebuilder_insert(nil, treeBuilder, "\(file)", &oid, GIT_FILEMODE_BLOB)
            if(error != GIT_OK.rawValue) {
                log("error:\(NSError(gitError: error, pointOfFailure: "git_treebuilder_insert"))")
                return failure(error, "git_treebuilder_insert")
            }
            //            git_object_free(obj);
            //
        }
        
        
        
        var treeOid : git_oid = git_oid()
        error = git_treebuilder_write(&treeOid, treeBuilder)
        if(error != GIT_OK.rawValue) {
            log("error:\(NSError(gitError: error, pointOfFailure: "git_treebuilder_write"))")
            return failure(error,"git_treebuilder_write")
        }
        
        git_treebuilder_free(treeBuilder)
        
        return Result.success(treeOid)
    }
    
    
    class func makeTree(_ repo:Repository, _ files:[String])-> Result<git_oid,NSError>{
        var error:Int32 = 0
        var idx : OpaquePointer? = nil
        var result = git_repository_index(&idx, repo.pointer);
        guard result == GIT_OK.rawValue else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_repository_index"))")
            return failure(result, "git_repository_index")
        }
        
        for file in files {
            
            result = git_index_add_bypath(idx, file)
            guard result == GIT_OK.rawValue else{
                print("error:\(NSError(gitError: result, pointOfFailure: "git_index_add_bypath"))")
                return failure(result, "git_index_add_bypath")
            }
            
        }
        
        error = git_index_add_all(idx, nil, GIT_INDEX_ADD_CHECK_PATHSPEC.rawValue, nil, nil)
        guard result == GIT_OK.rawValue else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_index_add_all"))")
            return failure(result, "git_index_add_all")
        }
        
        error = git_index_write(idx)
        guard result == GIT_OK.rawValue else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_index_write"))")
            return failure(result, "git_index_write")
        }
        
        var treeOid : git_oid = git_oid()
        result = git_index_write_tree(&treeOid, idx)
        
        guard result == GIT_OK.rawValue else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_index_write_tree"))")
            return failure(result, "git_index_add_bypath")
        }
        git_index_free(idx)
        return Result.success(treeOid)
    }
    
    class func refspecs(_ repo:Repository){
        /*
         
         git_strarray fetch_refspecs = {0};
         int error = git_remote_get_fetch_refspecs(&fetch_refspecs, remote);
         git_strarray push_refspecs = {0};
         error = git_remote_get_push_refspecs(&fetch_refspecs, remote);
         
         /* … or individually */
         size_t count = git_remote_refspec_count(remote);
         const git_refspec *rs = git_remote_get_refspec(remote, 0);
         
         /* You can add refspecs to the configuration */
         error = git_remote_add_fetch(repo, "origin", "…");
         error = git_remote_add_push(repo, "origin", "…");
         */
        var error : Int32 = 0
        var remote : OpaquePointer? = nil
        error = git_remote_lookup(&remote, repo.pointer, "origin")
        guard error == GIT_OK.rawValue else{
            print("error:\(NSError(gitError: error, pointOfFailure: "git_remote_lookup"))")
            return
        }
        
        let pointer = UnsafeMutablePointer<git_strarray>.allocate(capacity: 1)
        error = git_remote_get_push_refspecs(pointer, remote)
        guard error == GIT_OK.rawValue else{
            print("error:\(NSError(gitError: error, pointOfFailure: "git_remote_get_push_refspecs"))")
            return
        }
        
        //        pointer.pointee.map{
        ////            print("\($0)")
        //        }
        
        
    }
    
    class func addRefspecs(_ repo:Repository,_ remoteName:String){
        var error : Int32 = 0
        error = git_remote_add_push(repo.pointer, remoteName, "master")
        guard error == GIT_OK.rawValue else{
            print("error:\(NSError(gitError: error, pointOfFailure: "git_remote_add_push"))")
            return
        }
    }
    
    
    
    class func loadIndex(_ repo:Repository ,_ lastCommit:Commit){
        var idx : OpaquePointer? = nil
        var result = git_repository_index(&idx, repo.pointer);
        guard result == GIT_OK.rawValue else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_repository_index"))")
            return
        }
        
        
        result = git_index_add_bypath(idx, "README.md")
        if(result == GIT_OK.rawValue){}else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_index_add_bypath"))")
            return
        }
        
        var treeID : git_oid = git_oid()
        result = git_index_write_tree(&treeID, idx)
        
        if(result == GIT_OK.rawValue){}else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_index_write_tree"))")
            return
        }
        var tree : OpaquePointer? = nil
        
        result = git_tree_lookup(&tree, repo.pointer, &treeID)
        if(result == GIT_OK.rawValue){}else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_tree_lookup"))")
            return
        }
        
        
        
        var signature = (userSignatureForNow().value)!
        
        var commit : OpaquePointer? = nil
        var commitOid = lastCommit.oid.oid
        git_commit_lookup(&commit, repo.pointer, &commitOid)
        
        var commits = [commit]
        var newCommitID : git_oid = git_oid()
        result = git_commit_create(&newCommitID, repo.pointer, "HEAD", &signature , &signature , "UTF-8", "message", tree, 1, &commits)
        
        if ( result == GIT_OK.rawValue){} else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_commit_create"))")
            return
        }
        
        
        
        var newCommit : OpaquePointer? = nil
        let newCommitResult = git_commit_lookup(&newCommit, repo.pointer, &newCommitID)
        if ( newCommitResult == GIT_OK.rawValue){} else{
            print("error:\(NSError(gitError: newCommitResult, pointOfFailure: "git_commit_lookup"))")
        }
        
        print("commit success")
        
        
        
    }
    
    
    
    class func pushToFirstRemote(_ repo:Repository){
        
        let pointer = UnsafeMutablePointer<git_strarray>.allocate(capacity: 1)
        var result = git_remote_list(pointer, repo.pointer)
        if ( result == GIT_OK.rawValue){} else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_remote_list"))")
            return
        }
        let strarray = pointer.pointee
        let remotes: [String] = strarray.map {
            return $0
        }
        
        
        var remotePointer: OpaquePointer? = nil
        result = git_remote_lookup(&remotePointer, repo.pointer, "\((remotes.first)!)")
        
        if ( result == GIT_OK.rawValue){} else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_remote_lookup"))")
            return
        }
        
        var options = git_push_options()
        
        
        git_push_init_options(&options, UInt32(GIT_PUSH_OPTIONS_VERSION))
        
        var remoteCb = git_remote_callbacks()
        git_remote_init_callbacks(&remoteCb,UInt32(GIT_REMOTE_CALLBACKS_VERSION))
        remoteCb.credentials = credential_cb
        
        options.callbacks = remoteCb
        /**
         let repoRefcs = ["refs/heads/master:/refs/heads/master"]
         
         var repoRefcsArray = NSArray(array: repoRefcs)
         
         var gitStrArray = repoRefcsArray.git_strarray()
         */
        
        result = git_remote_add_push(repo.pointer, "origin", ":refs/remotes/origin/master")
        
        if ( result == GIT_OK.rawValue){} else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_remote_add_push"))")
            return
        }
        
        result = git_remote_push(remotePointer, pointer, &options)
        if ( result == GIT_OK.rawValue){} else{
            print("error:\(NSError(gitError: result, pointOfFailure: "git_remote_push"))")
            return
        }
        print("push success")
    }
    
    
    
}

struct Index {
    
}


extension Repository {
    class public func cloneWithCustomFetch(_ remoteURL: URL, _ localURL: URL,_ progresssHandler :SidebandProgressProgressBlock? = nil ) -> Result<Repository, NSError> {
        
        var cloneOpts = git_clone_options()
        git_clone_init_options(&cloneOpts, UInt32(GIT_CLONE_OPTIONS_VERSION))
        
        cloneOpts.bare = 0
        
        
        var checkoption = git_checkout_options()
        git_checkout_init_options(&checkoption, UInt32(GIT_CHECKOUT_OPTIONS_VERSION))
        checkoption.checkout_strategy = GIT_CHECKOUT_SAFE.rawValue
        cloneOpts.checkout_opts = checkoption
        
        cloneOpts.fetch_opts = RepositoryUtils.fetchOptions(progresssHandler)
        
        
        var repoPointer: OpaquePointer? = nil
        let remoteURLString = (remoteURL as NSURL).isFileReferenceURL() ? remoteURL.path : remoteURL.absoluteString
        let result = localURL.withUnsafeFileSystemRepresentation { localPath in
            git_clone(&repoPointer, remoteURLString, localPath, &cloneOpts)
        }
        
        guard result == GIT_OK.rawValue else {
            return failure(result, "git_clone")
        }
        
        let repository = Repository(repoPointer!)
        return Result.success(repository)
    }
}


//(git_cert *cert, int valid, const char *host, void *payload)
private func certificate_check(_ cert:UnsafePointer<git_cert>?,_ valid:Int32,_ host:UnsafePointer<Int8>?,_ playload: UnsafeMutableRawPointer?) -> Int32{
    return 1
}

/**
 int (*git_cred_acquire_cb)(
	git_cred **cred,
	const char *url,
	const char *username_from_url,
	unsigned int allowed_types,
	void *payload)
 */
private func credential_cb(_ cred:UnsafeMutablePointer<UnsafeMutablePointer<git_cred>?>?,_ url:UnsafePointer<Int8>?,_ username_from_url:UnsafePointer<Int8>? ,_ allowed_types:UInt32,_ playload: UnsafeMutableRawPointer?) -> Int32{
    
    let error = cred_userpass_plaintext(cred)
    
    //    print("url:\(String(validatingUTF8:url!))  result:\(error)")
    guard error == GIT_OK.rawValue else {
        print("error:\(NSError(gitError: error, pointOfFailure: "git_cred_userpass_plaintext_new")) ")
        return error
    }
    return error
}



/**
 * Create a new ssh key credential object reading the keys from memory.
 *
 * @param out The newly created credential object.
 * @param username username to use to authenticate.
 * @param publickey The public key of the credential.
 * @param privatekey The private key of the credential.
 * @param passphrase The passphrase of the credential.
 * @return 0 for success or an error code for failure
 
 GIT_EXTERN(int) git_cred_ssh_key_memory_new(
 git_cred **out,
 const char *username,
 const char *publickey,
 const char *privatekey,
 const char *passphrase);
 */
private func cred_ssh_key_memory_new(_ out:UnsafeMutablePointer<UnsafeMutablePointer<git_cred>?>?,_ username:UnsafePointer<Int8>?,_ publickey:UnsafePointer<Int8>? ,_ privatekey:UnsafePointer<Int8>?,_ passphrase:UnsafePointer<Int8>?) -> Int32{
    print("username:\(String(validatingUTF8:username!)) ")
    
    return 0
}
/**
 typedef int (*git_push_transfer_progress)(
	unsigned int current,
	unsigned int total,
	size_t bytes,
	void* payload);
 */

private func push_transfer_progress(_ current:UInt32,_ total:UInt32 ,_ bytes:size_t,_ playload: UnsafeMutableRawPointer?) -> Int32{
    print("current:\(current) total:\(total)  bytes:\(bytes)")
    return 0
}


/**
 /**
 * Type for messages delivered by the transport.  Return a negative value
 * to cancel the network operation.
 *
 * @param str The message from the transport
 * @param len The length of the message
 * @param payload Payload provided by the caller
 */
 typedef int (*git_transport_message_cb)(const char *str, int len, void *payload);
 */
private func transport_message_cb(_ str:UnsafePointer<Int8>?,_ len:Int32,_ playload: UnsafeMutableRawPointer?) -> Int32{
    
    if let payload = playload {
        let buffer = payload.assumingMemoryBound(to: SidebandProgressProgressBlock.self)
        
        if(len > 0){
            
            var progressStr = (String(validatingUTF8:str!))
            if(progressStr != nil){
                progressStr = progressStr!.components(separatedBy: .newlines).first
                let block: SidebandProgressProgressBlock
                block = buffer.pointee
                block(progressStr!,1)
            }
            
        }
        
    }
    
    return 0
}

/*
 /**
 * Type for progress callbacks during indexing.  Return a value less than zero
 * to cancel the transfer.
 *
 * @param stats Structure containing information about the state of the transfer
 * @param payload Payload provided by caller
 */
 typedef int (*git_transfer_progress_cb)(const git_transfer_progress *stats, void *payload);
 
 
 
 /**
 * This is passed as the first argument to the callback to allow the
 * user to see the progress.
 *
 * - total_objects: number of objects in the packfile being downloaded
 * - indexed_objects: received objects that have been hashed
 * - received_objects: objects which have been downloaded
 * - local_objects: locally-available objects that have been injected
 *    in order to fix a thin pack.
 * - received-bytes: size of the packfile received up to now
 */
 typedef struct git_transfer_progress {
	unsigned int total_objects;
	unsigned int indexed_objects;
	unsigned int received_objects;
	unsigned int local_objects;
	unsigned int total_deltas;
	unsigned int indexed_deltas;
	size_t received_bytes;
 } git_transfer_progress;
 */
private func transfer_progress_cb(_ stats:UnsafePointer<git_transfer_progress>?,_ playload: UnsafeMutableRawPointer?)-> Int32{
    
    if let progress = stats?.pointee {
        var str = "progress total_objects:\(progress.total_objects) indexed_objects:\(progress.indexed_objects)  received_objects:\(progress.received_objects) local_objects:\(progress.local_objects) total_deltas:\(progress.total_deltas) indexed_deltas:\(progress.indexed_deltas) received_bytes:\(progress.received_bytes) \r\n"
        str = "Rceiving objects:   \(String(format: "%.f", Float(progress.received_objects)/Float(progress.total_objects)*Float(100)))% (\(progress.received_objects)/\(progress.total_objects)) ,\(bytesToStr(progress.received_bytes))"
        
        if let payload = playload {
            let buffer = payload.assumingMemoryBound(to: SidebandProgressProgressBlock.self)
            let block: SidebandProgressProgressBlock
            block = buffer.pointee
            print("\(str)")
            block(str,2)
            
            
        }
        
    }
    return 0
}

/**
 /** Packbuilder progress notification function */
 typedef int (*git_packbuilder_progress)(
	int stage,
	unsigned int current,
	unsigned int total,
	void *payload);
 */
private func packbuilder_progress_cb(_ stage:Int32,_ current:UInt32,_ total:UInt32,_ payload: UnsafeMutableRawPointer?) -> Int32 {
    print("stage:\(stage) current:\(current) total:\(total)")
    return 0
}
private func bytesToStr(_ size:Int) -> String {
    let v = Float(1024)
    let kbValue = Float(size) / v
    if(kbValue > v){
        let mbValue = kbValue / v
        
        if(mbValue > v){
            let gbValue = mbValue / v
            return "\(String(format: "%.2f", gbValue)) GB"
        }
        
        return "\(String(format: "%.2f", mbValue)) MB"
    }
    
    return "\(String(format: "%.2f", kbValue)) KB"
}

private func cred_userpass_plaintext(_ out:UnsafeMutablePointer<UnsafeMutablePointer<git_cred>?>?) -> Int32{
    let username = Defaults[.username]
    let password = Defaults[.password]
    
    let error = git_cred_userpass_plaintext_new(out, username, password);
    //    print("url:\(String(validatingUTF8:url!))  result:\(error)")
    guard error == GIT_OK.rawValue else {
        print("error:\(NSError(gitError: error, pointOfFailure: "git_cred_userpass_plaintext_new")) ")
        return error
    }
    return GIT_OK.rawValue
}

/*
 /** Checkout progress notification function */
 typedef void (*git_checkout_progress_cb)(
	const char *path,
	size_t completed_steps,
	size_t total_steps,
	void *payload)
 */
private func checkout_progress_cb(_ str:UnsafePointer<Int8>?,_ completed_steps:size_t,_ total_steps:size_t,_ playload: UnsafeMutableRawPointer?){
    if(str != nil){
        print("str:\((String(validatingUTF8:str!))) completed_steps:\(completed_steps) total_steps:\(total_steps)")
    }
}


public func failure<T>(_ errorCode:Int32 ,_ desc:String) -> Result<T,NSError> {
    return Result.failure(NSError(gitError: errorCode, pointOfFailure: desc))
}

