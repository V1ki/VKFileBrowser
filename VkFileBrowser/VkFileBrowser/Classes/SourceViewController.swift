//
//  SourceViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/2.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

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
            
            let aStr = NSMutableAttributedString()
            
            
            let commentColorRGBValue = 0x45BB3E
            let preprocessorRGBValue = 0xC77A4B
            let keywordRGBValue = 0xD7008F
            
            var keywords = [String]()
            
            let font = UIFont(name: "SFMono-Regular", size: CGFloat(12))
            if(self.mFile.isObjectiveCSourceType()){
                
                keywords = ["static","void","id",
                            "@interface","@private","@end","@implementation","@selector"
                            ,"switch","YES","NO","return",
                             "case","break","if","const","do",
                             "else","nil","self","super",
                             "for","int","BOOL",
                             "while","NULL"]
                
                
                content.enumerateLines(invoking: {(line,flag) in
                    //                print("line:\(line)")
                    
                    let attributedLine = NSMutableAttributedString(string: line+"\n",attributes:[NSForegroundColorAttributeName:UIColor.hexColor(0xFFFFFF),NSFontAttributeName:font ?? UIFont.systemFont(ofSize: CGFloat(12))])
                    
                    
                    //单行注释
                    let commentRange = line.range(of:"//")
                    if(commentRange != nil){
                        let location = line.utf16.startIndex.distance(to: (commentRange?.lowerBound.samePosition(in: line.utf16))!)
                        let length = line.lengthOfBytes(using: .utf8) - location
                        attributedLine.addAttributes([NSForegroundColorAttributeName:UIColor.hexColor(commentColorRGBValue)], range: NSRange(location: location,length: length))
                        
                        aStr.append(attributedLine)
                        return
                    }
                    // URLS
                    let urlRange = line.range(of: "^((ht|f)tps?):\\/\\/[\\w\\-]+(\\.[\\w\\-]+)+([\\w\\-\\.,@?^=%&:\\/~\\+#]*[\\w\\", options:.regularExpression , range: line.startIndex..<line.endIndex, locale: nil)
                    if(urlRange != nil)
                    {
                        print(urlRange)
                    }
                    
                    
                    let preprocessors = ["#import","#include","#define"]
                    
                    for preprocessor in preprocessors {
                        
                        let preprocessorRange = line.range(of: preprocessor)
                        
                        if(preprocessorRange != nil ){
                            let length = preprocessor.lengthOfBytes(using: .utf8)
                            let location = line.utf16.startIndex.distance(to: (preprocessorRange?.upperBound.samePosition(in: line.utf16))!) - length
                            attributedLine.addAttributes([NSForegroundColorAttributeName:UIColor.hexColor(preprocessorRGBValue)], range: NSRange(location: location,length: length))
                            
                        }
                    }
                    // keyword 关键词
                    for keyword in keywords {
                        
                        let keywordRanges = line.keywordRanges(of: keyword)
                        
                        if(keywordRanges.count > 0){
                            for keywordRange in keywordRanges {
                                let length = keyword.lengthOfBytes(using: .utf8)
                                let location = line.utf16.startIndex.distance(to: (keywordRange.upperBound.samePosition(in: line.utf16))) - length
                                
                                //                        log("location:\(location)  lenght:\(length)  keyword:\(keyword)")
                                attributedLine.addAttributes([NSForegroundColorAttributeName:UIColor.hexColor(keywordRGBValue)], range: NSRange(location: location,length: length))
                            }
                        }
                    }
                    
                    aStr.append(attributedLine)
                    
                    
                })
                var startIndex: String.Index? = content.startIndex
                // 多行注释
                repeat{
                    
                    let range = (startIndex)!..<content.endIndex
                    
                    let startRange = content.range(of: "/*",options: .caseInsensitive, range: range, locale: nil)
                    
                    if(startRange == nil){
                        break
                    }
                    
                    let endRange = content.range(of: "*/",options: .caseInsensitive, range: range, locale: nil)
                    //                log("startRange:\(startRange)  endRange:\(endRange)")
                    
                    if(endRange == nil){
                        break
                    }
                    
                    let start = content.utf16.startIndex.distance(to: (startRange?.lowerBound.samePosition(in: content.utf16))!)
                    let end = content.utf16.startIndex.distance(to: (endRange?.upperBound.samePosition(in: content.utf16))!)
                    
                    
                    log("start:\(start)   end:\(end)")
                    
                    aStr.setAttributes([NSForegroundColorAttributeName:UIColor.hexColor(commentColorRGBValue)], range: NSRange(location:start,length:end-start))
                    
                    startIndex = endRange?.upperBound
                } while true
                
                
                let endDate = Date()
                let interval = endDate.timeIntervalSince(startDate)
                
                print("interval:\(interval)")
            }
            else if(self.mFile.isSwiftSourceType()){
                
            }
            
            
            
            
            DispatchQueue.main.async {
                self.sourceTV.attributedText = aStr
                self.sourceTV.backgroundColor = UIColor.hexColor(0x1F2029)
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
        
        print("line:\(line)")
        
        // 找到 需要处理的行 的内容之后，判断 是否需要跳转，怎么跳转。
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextIn:\(range)")
        return true
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("characterRange:\(characterRange)")
        
        
        
        return true
    }
    
    
    
    
    
    
}
