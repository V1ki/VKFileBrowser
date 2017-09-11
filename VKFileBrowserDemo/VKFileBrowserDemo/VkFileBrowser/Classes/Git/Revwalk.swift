//
//  Revwalk.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/10.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation

extension Repository {
    
    func revwalk(){
        var oid = git_oid()
        var error = git_blob_create_fromworkdir(&oid, self.pointer, "README")
        guard error == GIT_OK.rawValue else {
            print("error:\(error)")
            return
        }
        print("123------")
        
        let iterator = CommitIterator(repo: self, root: oid)
        
        for i in iterator {
            
            print("i:\(i)")
            
            
        }
        
    }
    
    
}
