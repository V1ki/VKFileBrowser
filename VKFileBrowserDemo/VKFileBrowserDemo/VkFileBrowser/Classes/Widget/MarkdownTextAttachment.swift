//
//  MarkdownTextAttachment.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/14.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class MarkdownTextAttachment: NSTextAttachment {
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        print("position:\(position)  textContainer:\(textContainer)  lineFrag:\(lineFrag)  charIndex:\(charIndex) self.image:\(self.image)")
        let img = self.image
        let widthRate = (img?.size.width)! / lineFrag.size.width
        
        
        return CGRect(origin:position,size:CGSize(width:lineFrag.size.width,height:widthRate * (img?.size.height)!))
    }

}
