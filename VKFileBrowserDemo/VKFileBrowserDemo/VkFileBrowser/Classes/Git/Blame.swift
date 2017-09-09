//
//  Blame.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/9.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation


/**
 * Structure that represents a blame hunk.
 *
 * - `lines_in_hunk` is the number of lines in this hunk
 * - `final_commit_id` is the OID of the commit where this line was last
 *   changed.
 * - `final_start_line_number` is the 1-based line number where this hunk
 *   begins, in the final version of the file
 * - `orig_commit_id` is the OID of the commit where this hunk was found.  This
 *   will usually be the same as `final_commit_id`, except when
 *   `GIT_BLAME_TRACK_COPIES_ANY_COMMIT_COPIES` has been specified.
 * - `orig_path` is the path to the file where this hunk originated, as of the
 *   commit specified by `orig_commit_id`.
 * - `orig_start_line_number` is the 1-based line number where this hunk begins
 *   in the file named by `orig_path` in the commit specified by
 *   `orig_commit_id`.
 * - `boundary` is 1 iff the hunk has been tracked to a boundary commit (the
 *   root, or the commit specified in git_blame_options.oldest_commit)
 */
//typedef struct git_blame_hunk {
//    size_t lines_in_hunk;
//
//    git_oid final_commit_id;
//    size_t final_start_line_number;
//    git_signature *final_signature;
//
//    git_oid orig_commit_id;
//    const char *orig_path;
//    size_t orig_start_line_number;
//    git_signature *orig_signature;
//
//    char boundary;
//} git_blame_hunk;

struct BlameHunk {
    let lines_in_hunk : Int
    let final_commit_id : git_oid
    let final_start_line_number : Int
    let final_signature : git_signature
    let finalCommit : Commit
    
    let orig_commit_id : git_oid
    let origCommit : Commit
    let orig_path : String
    let orig_start_line_number : Int
    let orig_signature : git_signature
    
    init(_ blameHunk:git_blame_hunk,_ repo:Repository) {
        
        lines_in_hunk = blameHunk.lines_in_hunk
        final_commit_id = blameHunk.final_commit_id
        final_start_line_number = blameHunk.final_start_line_number
        final_signature = blameHunk.final_signature.pointee
        
        orig_commit_id = blameHunk.orig_commit_id
        orig_path = String(validatingUTF8:blameHunk.orig_path!)!
        orig_start_line_number = blameHunk.orig_start_line_number
        orig_signature = blameHunk.orig_signature.pointee
        
        var unsafeCommit: OpaquePointer? = nil
        var oid = final_commit_id
        git_commit_lookup(&unsafeCommit, repo.pointer, &oid)
        finalCommit = Commit(unsafeCommit!)
        git_commit_free(unsafeCommit)
        
        oid = orig_commit_id
        git_commit_lookup(&unsafeCommit, repo.pointer, &oid)
        origCommit = Commit(unsafeCommit!)
        git_commit_free(unsafeCommit)
        
        
    }
}

extension BlameHunk : CustomStringConvertible{
    var description: String {
        get {
            return "lines_in_hunk:\(lines_in_hunk) finalCommit:\(finalCommit.message) origCommit:\(origCommit.message)"
        }
    }
}



extension Repository {
    
    func blame(filePath:String){
        
        var blame : OpaquePointer? = nil
        var error = git_blame_file(&blame, self.pointer, filePath, nil)
        guard error == GIT_OK.rawValue else {
            print("error:\(NSError(gitError:error,pointOfFailure:"git_blame_file"))")
            return
        }
        let hunkCount = git_blame_get_hunk_count(blame)
        
        print("hunkCount:\(hunkCount)")
        var hunks = [BlameHunk]()
        for i in 0..<hunkCount {
            let blameHunkPointer = git_blame_get_hunk_byindex(blame, i)
            if let blameHunk = blameHunkPointer?.pointee {
                let blame = BlameHunk(blameHunk,self)
                print("blame:\(blame)")
                hunks.append(blame)
                
            }
            
        }
        
        
    }
    
}

