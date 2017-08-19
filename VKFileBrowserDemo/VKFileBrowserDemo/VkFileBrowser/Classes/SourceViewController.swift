//
//  SourceViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/2.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Highlightr


class SourceViewController: BaseViewController ,UITextViewDelegate{
    
    @IBOutlet weak var sourceTV: UITextView!
    
    
    var filePath:String!
    
    var mFile:VKFile!{
        
        didSet{
            filePath = "\(mFile.filePath!)/\(mFile.name!)"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceTV.delegate = self
        sourceTV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTextView)))
        self.title = mFile.name
        
        DispatchQueue.global().async{
            let startDate = Date()
            
            let content = self.mFile.readContent()
            
            
            let highlightr = Highlightr()
            
            
            if(self.mFile.isXcodeFileType()){
                highlightr?.setTheme(to: "xcode")
                DispatchQueue.main.async {
                    self.sourceTV.backgroundColor = UIColor.white
                }
            }
            
            // You can omit the second parameter to use automatic language detection.
            let highlightedCode = highlightr?.highlight(content, as: "swift")
            let endDate = Date()
            let interval = endDate.timeIntervalSince(startDate)
            
//            let bStr = HighlightJS().paint(code: content)
            
            log("interval:\(interval)")
            
            DispatchQueue.main.async {
                self.sourceTV.attributedText = highlightedCode
//                self.sourceTV.backgroundColor = UIColor.hexColor(0x1F2029)
            }
        }
        
        
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func tapTextView(_ gr:UITapGestureRecognizer){
        let content = sourceTV.text
        let touchPosition = gr.location(in: sourceTV)
        let textRange = sourceTV.characterRange(at: touchPosition)!
        
        //起始位置
//        let startPosition = textRange.start
        
        //结束位置
        let endPosition = textRange.end
        
//        let startOffset = sourceTV.offset(from: sourceTV.beginningOfDocument, to:startPosition)
        let endOfsset = sourceTV.offset(from: sourceTV.beginningOfDocument, to: endPosition)
        
        let startStrRange = (content?.startIndex)! ..< (content?.index((content?.startIndex)!, offsetBy: endOfsset))!
        
        let endStrRange = (content?.index((content?.startIndex)!, offsetBy: endOfsset))! ..< (content?.endIndex)!
        
        let startBrRange = content?.range(of: "\n", options: .backwards, range: startStrRange, locale: nil)
        let endBrRange = content?.range(of: "\n", options: .caseInsensitive, range: endStrRange, locale: nil)
        
        //得到点击的行的内容
        let line = content?.substring(with: (startBrRange?.upperBound)!..<(endBrRange?.lowerBound)!)
        
        log("line:\(line)")
        
        // 找到 需要处理的行 的内容之后，判断 是否需要跳转，怎么跳转。
        
    }

    
    
}
