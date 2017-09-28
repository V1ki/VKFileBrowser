//
//  VKLayoutManager.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/5.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class VKLayoutManager: NSLayoutManager {
    
    var lastParaNumber = 0
    var lastParaLocation = 0
    
    
    
    func paraNumberForRange(_ charRange:NSRange) -> Int{
        if charRange.location == self.lastParaLocation {
            return self.lastParaNumber
        }
        else if charRange.location < self.lastParaLocation {
            //  We need to look backwards from the last known paragraph for the new paragraph range.  This generally happens
            //  when the text in the UITextView scrolls downward, revaling paragraphs before/above the ones previously drawn.
            
            let textStorageStr = NSString(string: self.textStorage?.string ?? "")
            var paraNumber = self.lastParaNumber
            let options = NSString.EnumerationOptions(rawValue: NSString.EnumerationOptions.byParagraphs.rawValue | NSString.EnumerationOptions.substringNotRequired.rawValue | NSString.EnumerationOptions.reverse.rawValue )

            textStorageStr.enumerateSubstrings(in: NSRange(location: charRange.location, length: self.lastParaLocation - charRange.location ), options:options , using: { (subString,subStringRange,enclosingRange,stop) in
                if (enclosingRange.location <= charRange.location) {
                    stop.pointee = true
                }
                paraNumber -= 1
            })
            self.lastParaLocation = charRange.location
            self.lastParaNumber = paraNumber
            
            return paraNumber
        }
        else{
            //  We need to look forward from the last known paragraph for the new paragraph range.  This generally happens
            //  when the text in the UITextView scrolls upwards, revealing paragraphs that follow the ones previously drawn.
            let textStorageStr = NSString(string: self.textStorage?.string ?? "")
            var paraNumber = self.lastParaNumber
            let options = NSString.EnumerationOptions(rawValue: NSString.EnumerationOptions.byParagraphs.rawValue | NSString.EnumerationOptions.substringNotRequired.rawValue )
            
            textStorageStr.enumerateSubstrings(in: NSRange(location: self.lastParaLocation, length: charRange.location - self.lastParaLocation ), options:options , using: { (subString,subStringRange,enclosingRange,stop) in
                if (enclosingRange.location >= charRange.location) {
                    stop.pointee = true
                }
                paraNumber += 1
            })
            self.lastParaLocation = charRange.location
            self.lastParaNumber = paraNumber
            
            return paraNumber
        }
    }
    
    override func processEditing(for textStorage: NSTextStorage, edited editMask: NSTextStorageEditActions, range newCharRange: NSRange, changeInLength delta: Int, invalidatedRange invalidatedCharRange: NSRange) {
        super.processEditing(for: textStorage, edited: editMask, range: newCharRange, changeInLength: delta, invalidatedRange: invalidatedCharRange)
        if invalidatedCharRange.location < self.lastParaLocation {
            self.lastParaNumber = 0
            self.lastParaLocation = 0 
        }
        
    }
    
    
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        let atts = [NSFontAttributeName:UIFont.systemFont(ofSize: 10),NSForegroundColorAttributeName:lineNumberFontColor] as [String : Any]
        var gutterRect = CGRect()
        var paraNumber = 0
        
        self.enumerateLineFragments(forGlyphRange: glyphsToShow, using: { (rect,usedRect,textContainer,glyphRange,stop) in
            let charRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let textStorageStr = NSString(string: self.textStorage?.string ?? "")
            let paraRange = textStorageStr.paragraphRange(for: charRange)
            
            
            //   Only draw line numbers for the paragraph's first line fragment.  Subsiquent fragments are wrapped portions of the paragraph and don't
            //   get the line number.
            if (charRange.location == paraRange.location) {
                
                gutterRect = CGRect(x:CGFloat(0), y:rect.origin.y, width:gutterWidth, height:rect.size.height).offsetBy(dx: origin.x, dy: origin.y)
                
                paraNumber = self.paraNumberForRange(charRange)
                let ln = NSString(string:"\(paraNumber + 1)")
                let size = ln.size(attributes: atts)
                
                ln.draw(in: gutterRect.offsetBy(dx: gutterRect.width-4-size.width, dy: (rect.size.height - size.height)/2), withAttributes: atts)
                
            }
        })
        
        //  Deal with the special case of an empty last line where enumerateLineFragmentsForGlyphRange has no line
        //  fragments to draw.
        
        if NSMaxRange(glyphsToShow) > self.numberOfGlyphs {
            let ln = NSString(string:"\(paraNumber + 2)")
            let size = ln.size(attributes: atts)
            gutterRect = gutterRect.offsetBy(dx: 0, dy: gutterRect.height)
            
            ln.draw(in: gutterRect.offsetBy(dx: gutterRect.width - 4 - size.width, dy: (gutterRect.height - size.height) / 2 ), withAttributes: atts)
        }
    }
    
    
}
