//
//  VKTextView.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/5.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

public var gutterWidth : CGFloat = 30
public var lineNumberBackgroundColor = UIColor.flatWhite
public var lineNumberFontColor : UIColor = UIColor.flatGray

class VKTextView: UITextView {

    var lineNumberLayoutManager:VKLayoutManager?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        
        let manager = VKLayoutManager()
        let textStorage = NSTextStorage()
        self.lineNumberLayoutManager = manager
        
        let tc = NSTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        tc.widthTracksTextView = true
        tc.exclusionPaths = [UIBezierPath(rect:CGRect(x: 0, y: 0, width: gutterWidth, height: CGFloat.greatestFiniteMagnitude)) ]
        
        manager.addTextContainer(tc)
        textStorage.addLayoutManager(manager)
        
        super.init(frame: frame,textContainer:tc)
        
        self.contentMode = .redraw
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
    
    
    override var attributedText: NSAttributedString! {
        didSet{
            let count = attributedText.string.components(separatedBy: .newlines).count
            let lcount = "\(count - 1)".count
            if(lcount > 3){
                
                gutterWidth = CGFloat("\(count - 1)".count * 9)
                self.setNeedsDisplay()
                
            }
            
        }
    }
    

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        // Set the regular fill
        context?.setFillColor(lineNumberBackgroundColor.cgColor)
        context?.fill(CGRect(x: bounds.origin.x, y: bounds.origin.y, width: gutterWidth, height: bounds.height) )
        
        //Draw line
        context?.setStrokeColor(lineNumberFontColor.cgColor)
        context?.setLineWidth(0.5)
        context?.stroke(CGRect(x: bounds.origin.x + gutterWidth - 0.5, y: bounds.origin.y, width: 0.5, height: bounds.height))
//        context?.fill(CGRect(x: 30, y: bounds.origin.y, width: 0.5, height: height) )
        

        super.draw(rect)
    }
}
