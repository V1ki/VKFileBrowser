//
//  VKLayoutManager.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/5.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class VKLayoutManager: NSLayoutManager {
    
    var gutterWidth : Float = 30.0
    var selectedRange = NSMakeRange(0, 0)
    var lineAreaInset = UIEdgeInsetsMake(0, 10, 0, 4)
    var lineNumberColor : UIColor = .gray
    var selectedLineNumberColor : UIColor = .white
    
    
    func paragraphRect(_ range : Range<String.Index>){
        let a = ""
        
    }
    
//    func paragraphRectForRange(range:inout RangeExpression) {
//        range = (self.textStorage?.string)?.paragraphRange(for: range)
//        range = (self.textStorage?.string)!.paragraphRange(for: range)
//    }
    
    
}
