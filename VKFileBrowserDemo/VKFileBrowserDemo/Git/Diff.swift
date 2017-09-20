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

struct DiffHunk {
    
    /**
     * Structure describing a hunk of a diff.
 
    typedef struct {
    int    old_start;     /**< Starting line number in old_file */
    int    old_lines;     /**< Number of lines in old_file */
    int    new_start;     /**< Starting line number in new_file */
    int    new_lines;     /**< Number of lines in new_file */
    size_t header_len;    /**< Number of bytes in header text */
    char   header[128];   /**< Header text, NUL-byte terminated */
    } git_diff_hunk;
*/
    
    let oldStart : Int
    let oldLines : Int
    let newStart : Int
    let newLines : Int
    let headerLen : Int
    let header : String
    
    init(_ hunk : git_diff_hunk) {
        
        oldStart = Int(hunk.old_start )
        oldLines = Int(hunk.old_lines)
        newStart = Int(hunk.new_start)
        newLines = Int(hunk.new_lines)
        headerLen = Int(hunk.header_len)
        header = ""
//        header = String(UnicodeScalar(UInt8(hunk.header)))
//        header = String(validatingUTF8: )!
    }
    
}

extension DiffHunk : CustomStringConvertible {
    var description: String {
        get{
            return "oldStart:\(oldStart) oldLines:\(oldLines) newStart:\(newStart) newLines:\(newLines) headerLen:\(headerLen) "
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
    
    
    
    func diffFile(_ filename:String){
        var error : Int32 = 0
        let commits = self.allCommits()
        if let firstCommit = commits.first {
            let treeResult = self.tree(firstCommit.tree.oid)
            if let tree = treeResult.value {
                for entry in (tree.entries) {
                    let treeEntry = entry.value
                    
                    switch treeEntry.object {
                    case .blob:
                        //文件
                        print("\(treeEntry.name)")
                        print("\(self.blob(treeEntry.object.oid))")
                        
                        
                        var firstBlob : OpaquePointer? = nil
                        var foid = treeEntry.object.oid.oid
                        error = git_blob_lookup(&firstBlob, self.pointer, &foid)
                        guard error == GIT_OK.rawValue else {
                            print("error:\(error)")
                            return
                        }
                        
                        var oid = git_oid()
                        error = git_blob_create_fromworkdir(&oid, self.pointer, "README")
                        guard error == GIT_OK.rawValue else {
                            print("error:\(error)")
                            return
                        }
                        
                        
                        var lastBlob : OpaquePointer? = nil
                        error = git_blob_lookup(&lastBlob, self.pointer, &oid)
                        guard error == GIT_OK.rawValue else {
                            print("error:\(error)")
                            return
                        }
                        
                        
                        error = git_diff_blobs(firstBlob, nil, lastBlob, nil, nil, gitDiffFileCB, gitDiffBinaryCB, gitDiffHunkCB, gitDiffLineCB, nil)
                        guard error == GIT_OK.rawValue else {
                            print("error:\(error)")
                            return
                        }
                        print("success")
                        
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
        }
        
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
    
        print("delta:\(DiffDelta((delta?.pointee)!)))")
    return 0
}
private func gitDiffBinaryCB(_ delta:UnsafePointer<git_diff_delta>?, binary:UnsafePointer<git_diff_binary>?,playload: UnsafeMutableRawPointer?)->Int32{
        print("gitDiffBinaryCB")
    return 0
}
private func gitDiffHunkCB(_ delta:UnsafePointer<git_diff_delta>?,hunk: UnsafePointer<git_diff_hunk>?,playload: UnsafeMutableRawPointer?)->Int32{
    print("delta:\(DiffDelta((delta?.pointee)!))) hunk:\(DiffHunk((hunk?.pointee)!))")
    return 0
}
private func gitDiffLineCB(delta:UnsafePointer<git_diff_delta>?,hunk: UnsafePointer<git_diff_hunk>?, line:UnsafePointer<git_diff_line>?,playload: UnsafeMutableRawPointer?)->Int32{
        print("delta:\(DiffDelta((delta?.pointee)!))) line:\(DiffLine((line?.pointee)!))  hunk:\(DiffHunk((hunk?.pointee)!))")
    return 0
}
