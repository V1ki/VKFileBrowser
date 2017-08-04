//
//  SourceViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/2.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class SourceViewController: BaseViewController {
    
    @IBOutlet weak var sourceTV: UITextView!
    
    
    var filePath:String!
    
    var mFile:VKFile!{
        
        didSet{
            filePath = "\(mFile.filePath!)/\(mFile.name!)"
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        DispatchQueue.global().async{
            let startDate = Date()
            
            let content = self.mFile.readContent()
            
            let aStr = NSMutableAttributedString()
            
            
            let commentColorRGBValue = 0x45BB3E
            let preprocessorRGBValue = 0xC77A4B
            let keywordRGBValue = 0xD7008F
            
            var keywords = [String]()
            
            
            if(self.mFile.isObjectiveCSourceType()){
                
                keywords = ["static","void","id","@interface","@private","@end","@implementation","@selector","switch","YES","NO","case","break","if","else","nil","self","for"]
                
                let font = UIFont(name: "SFMono-Regular", size: CGFloat(12))
                content.enumerateLines(invoking: {(line,flag) in
                    //                print("line:\(line)")
                    
                    let attributedLine = NSMutableAttributedString(string: line+"\n",attributes:[NSForegroundColorAttributeName:UIColor.hexColor(0xFFFFFF),NSFontAttributeName:font])
                    
                    //单行注释
                    let commentRange = line.range(of:"//")
                    if(commentRange != nil){
                        let location = line.utf16.startIndex.distance(to: (commentRange?.lowerBound.samePosition(in: line.utf16))!)
                        let length = line.lengthOfBytes(using: .utf8) - location
                        attributedLine.addAttributes([NSForegroundColorAttributeName:UIColor.hexColor(commentColorRGBValue)], range: NSRange(location: location,length: length))
                    }
                    // URLS
//                    let urlRange = line.range(of: "^((ht|f)tps?):\\/\\/[\\w\\-]+(\\.[\\w\\-]+)+([\\w\\-\\.,@?^=%&:\\/~\\+#]*[\\w\\", options:.regularExpression , range: line.startIndex..<line.endIndex, locale: nil)
//                    if(urlRange != nil)
//                    {
//                        print(urlRange)
//                    }
                    
                    // #import
                    let importRange = line.range(of: "#import")
                    if(importRange != nil){
                        let location = line.utf16.startIndex.distance(to: (importRange?.lowerBound.samePosition(in: line.utf16))!)
                        let length = 7
                        attributedLine.addAttributes([NSForegroundColorAttributeName:UIColor.hexColor(preprocessorRGBValue)], range: NSRange(location: location,length: length))
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
            
            
            
            DispatchQueue.main.async {
                self.sourceTV.attributedText = aStr
                self.sourceTV.backgroundColor = UIColor.hexColor(0x1F2029)
            }
        }
        
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
}
