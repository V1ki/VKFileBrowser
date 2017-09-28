//
//  VKCoreTextView.swift
//  HtmlDebugger
//
//  Created by Vk on 2017/9/24.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class VKCoreTextView : UIScrollView,UIScrollViewDelegate{
    
    private var frames = [VKCoreItemView]()
    private let offsetX : CGFloat = 0
    private let offsetY : CGFloat = 0
    var text : String?{
        didSet{
            self.rebuildFrame()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func buildFrame(){
        
        guard let str = self.text else{
            return
        }
        
        self.delegate = self
        let content = UIGraphicsGetCurrentContext()
        content?.textMatrix = CGAffineTransform.identity
        
        content?.translateBy(x: 0, y: self.bounds.size.height)
        
        content?.scaleBy(x: 1, y: -1)
        
        //绘制区域
        
        let mutablePath = CGMutablePath()
        let textFrame = self.bounds.offsetBy(dx: offsetX, dy: offsetY)
        print("textFrame:\(textFrame)")
        mutablePath.addRect(textFrame)
        
        let attr = NSMutableAttributedString(string:str)
        
        //绘制文字
        let setter = CTFramesetterCreateWithAttributedString(attr)
        
        var textPos  = 0
        var columnIndex : CGFloat = 0
        
        while textPos < attr.length {
            let colOffset = CGPoint(x: offsetX, y: columnIndex * textFrame.size.height)
            let colRect = CGRect(x: 0, y: 0, width: textFrame.size.width - offsetX, height: textFrame.size.height )
            let path = CGMutablePath()
            path.addRect(colRect)
            
            let frame = CTFramesetterCreateFrame(setter, CFRangeMake(textPos ,0), path, nil)
            let frameRange = CTFrameGetVisibleStringRange(frame)
            
            
            let itemView = VKCoreItemView(frame: CGRect(x: colOffset.x, y: colOffset.y, width: colRect.size.width, height: colRect.size.height))
            
            itemView.ctFrame = frame
            itemView.backgroundColor = .green
            
            self.addSubview(itemView)
            frames.append(itemView)
            
            
            textPos += frameRange.length
            
            
            columnIndex += 1
        }
        
        let totalPages = columnIndex
        print("page:\(totalPages)")
        self.contentSize = CGSize(width: self.bounds.size.width , height: self.bounds.size.height * totalPages)
        
        print(self.contentSize)
        
        
    }

    func rebuildFrame(){
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        self.frames.removeAll()
        
        self.buildFrame()
    }
}


class VKCoreItemView : UIView {
    
    var ctFrame : CTFrame?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.textMatrix = CGAffineTransform.identity
        
        context.translateBy(x: 0, y: self.bounds.size.height)
        
        context.scaleBy(x: 1, y: -1)
        
        if let cf = ctFrame {
           
            
            let lines = CTFrameGetLines(cf)
            //            var origins : CGPoint = CGPoint()
            //            CTFrameGetLineOrigins(cf, CFRangeMake(0, 0), &origins)
            
            let lineCount = CFArrayGetCount(lines)
            if lineCount > 0 {
                let line = CFArrayGetValueAtIndex(lines, CFIndex(bitPattern: 0))
                
                var ascent : CGFloat = 0
                var descent : CGFloat = 0
                var leading : CGFloat = 0
                
                guard let ctLine = line?.load(as: CTLine.self) else {
                    return
                }
                CTLineGetTypographicBounds(ctLine, &ascent, &descent, &leading)
                
                
            }
            
            CTFrameDraw(cf, context)
            
            
        }
        
        
        
        
    }
}
