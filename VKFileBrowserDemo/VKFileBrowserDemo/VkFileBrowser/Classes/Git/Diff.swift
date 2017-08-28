//
//  Diff.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/27.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation

struct DiffDelta {
    
    
    //git_diff_delta
    /**
     git_delta_t   status;
     uint32_t      flags;	   /**< git_diff_flag_t values */
     uint16_t      similarity;  /**< for RENAMED and COPIED, value 0-100 */
     uint16_t      nfiles;	   /**< number of files in this delta */
     git_diff_file old_file;
     git_diff_file new_file;
     */
    
    let status : git_delta_t
    
    let flags : Int
    
    let similarity : Int
    
    let nfiles : Int
    
    let oldFile : DiffFile
    
    let newFile : DiffFile
    
    
    init(_ delta: git_diff_delta) {
        
        status = delta.status
        flags = Int(delta.flags)
        similarity = Int(delta.similarity)
        nfiles = Int(delta.nfiles)
        oldFile = DiffFile(delta.old_file)
        newFile = DiffFile(delta.new_file)
    }
    
    
    
}

extension DiffDelta : CustomStringConvertible{
    var description: String {
        get{
            return "status:\(status) flags:\(flags) similarity:\(similarity) nfiles:\(nfiles) oldFile:\(oldFile) newFile:\(newFile)"
        }
    }
}

struct DiffFile {
    /**
     git_oid     id;
     const char *path;
     git_off_t   size;
     uint32_t    flags;
     uint16_t    mode;
     */
    let oid : OID
    let path : String
    let size : Int
    let flags : Int
    let mode : Int
    
    
    init(_ file: git_diff_file) {
        oid = OID(file.id)
        path = String(validatingUTF8: file.path)!
        size = Int(file.size)
        flags = Int(file.flags)
        mode = Int(file.mode)
    }
    
}

extension DiffFile : CustomStringConvertible{
    var description: String {
        get{
            return "oid:\(oid) path:\(path) size:\(size) flags:\(flags) mode:\(mode) "
        }
    }
}

struct DiffLine {
    /**
     char   origin;       /**< A git_diff_line_t value */
     int    old_lineno;   /**< Line number in old file or -1 for added line */
     int    new_lineno;   /**< Line number in new file or -1 for deleted line */
     int    num_lines;    /**< Number of newline characters in content */
     size_t content_len;  /**< Number of bytes of data */
     git_off_t content_offset; /**< Offset in the original file to the content */
     const char *content; /**< Pointer to diff text, not NUL-byte terminated */
     */
    let origin : Character
    let oldLineno : Int
    let newLineno : Int
    let numLines : Int
    let contentLen : Int
    let contentOffset : Int
    let content : String
    
    init(_ line : git_diff_line) {
        
        origin = Character(UnicodeScalar(UInt8(line.origin)))
        oldLineno = Int(line.old_lineno)
        newLineno = Int(line.new_lineno)
        numLines = Int(line.num_lines)
        contentLen = Int(line.content_len)
        contentOffset = Int(line.content_offset)
        content = String(validatingUTF8: line.content)!
    }
    
}

extension DiffLine : CustomStringConvertible {
    var description: String {
        get{
            return "origin:\(origin) oldLineno:\(oldLineno) newLineno:\(newLineno) numLines:\(numLines) contentLen:\(contentLen) contentOffset:\(contentOffset) content:\(content) "
        }
    }
}



extension Repository {
    
    
    func diff(_ oldTreeOid:OID,_ newTreeOid:OID){
        var pointer : OpaquePointer? = nil
        var oldTreePointer : OpaquePointer? = nil
        var oldTreeOidOid = oldTreeOid.oid
        let oldTreeResult = git_object_lookup(&oldTreePointer, self.pointer, &(oldTreeOidOid), GIT_OBJ_TREE)
        guard oldTreeResult == GIT_OK.rawValue else {
            print("oldTreeResult:\(oldTreeResult)")
            return
        }
        
        var newTreePointer : OpaquePointer? = nil
        var newTreeOidOid = newTreeOid.oid
        let newTreeResult = git_object_lookup(&newTreePointer, self.pointer, &(newTreeOidOid), GIT_OBJ_TREE)
        guard newTreeResult == GIT_OK.rawValue else {
            print("newTreeResult:\(newTreeResult)")
            return
        }
        
        let diffResult = git_diff_tree_to_tree(&pointer, self.pointer, oldTreePointer, newTreePointer, nil)
        guard diffResult == GIT_OK.rawValue else {
            print("diffResult:\(diffResult)")
            return
        }
        
        
        
        git_diff_foreach(pointer, gitDiffFileCB, gitDiffBinaryCB, gitDiffHunkCB, gitDiffLineCB, nil)
        
        
        
        //        git_diff_tree_to_workdir(<#T##diff: UnsafeMutablePointer<OpaquePointer?>!##UnsafeMutablePointer<OpaquePointer?>!#>, <#T##repo: OpaquePointer!##OpaquePointer!#>, <#T##old_tree: OpaquePointer!##OpaquePointer!#>, <#T##opts: UnsafePointer<git_diff_options>!##UnsafePointer<git_diff_options>!#>)
        
        git_object_free(oldTreePointer)
        git_object_free(newTreePointer)
        git_diff_free(pointer)
        
    }
    
    
    
    
    func diffTreeToWorkDir(_ oldTreeOid:OID){
        var pointer : OpaquePointer? = nil
        var oldTreePointer : OpaquePointer? = nil
        var oldTreeOidOid = oldTreeOid.oid
        let oldTreeResult = git_object_lookup(&oldTreePointer, self.pointer, &(oldTreeOidOid), GIT_OBJ_TREE)
        guard oldTreeResult == GIT_OK.rawValue else {
            print("oldTreeResult:\(oldTreeResult)")
            return
        }
        
        
        
        let diffResult = git_diff_tree_to_workdir(&pointer, self.pointer, oldTreePointer, nil)
        guard diffResult == GIT_OK.rawValue else {
            print("diffResult:\(diffResult)")
            return
        }
        
        
        git_diff_foreach(pointer, gitDiffFileCB, gitDiffBinaryCB, gitDiffHunkCB, gitDiffLineCB, nil)
        
        git_object_free(oldTreePointer)
        
        git_diff_free(pointer)
        
    }
    

}

private func gitDiffFileCB(_ delta:UnsafePointer<git_diff_delta>?, progress:Float,playload: UnsafeMutableRawPointer?) ->Int32{
    
    let delta = DiffDelta((delta?.pointee)!)
    //    print("delta:\(delta))")
    return 0
}
private func gitDiffBinaryCB(_ delta:UnsafePointer<git_diff_delta>?, binary:UnsafePointer<git_diff_binary>?,playload: UnsafeMutableRawPointer?)->Int32{
    //    print("gitDiffBinaryCB")
    return 0
}
private func gitDiffHunkCB(_ delta:UnsafePointer<git_diff_delta>?,hunk: UnsafePointer<git_diff_hunk>?,playload: UnsafeMutableRawPointer?)->Int32{
    //    print("gitDiffHunkCB")
    return 0
}
private func gitDiffLineCB(delta:UnsafePointer<git_diff_delta>?,huk: UnsafePointer<git_diff_hunk>?, line:UnsafePointer<git_diff_line>?,playload: UnsafeMutableRawPointer?)->Int32{
    //    print("line:\(DiffLine((line?.pointee)!))")
    return 0
}
