//
//  Extension.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/7/28.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD



public func log(_ items: Any..., separator: String = "", terminator: String = "")  {
    print(items,separator,terminator)
}



extension NSObject {

    
}
extension UIView{
    public func showTips(_ tips:String){
        
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        
        hud?.mode = .text
        hud?.labelText = tips
        
        hud?.hide(true, afterDelay: 1.0)
        
    }
    

}
extension UITableView{
    
    func hideExtraCell(){
        let view = UIView()
        view.backgroundColor = UIColor.clear
        self.tableFooterView = view
    }
}



extension String {
    func ranges(of str:String) -> [Range<String.Index>]{
        var results = [Range<String.Index>]()
        var startIndex: String.Index? = self.startIndex
        // 多行注释
        repeat{
            
            let range = (startIndex)!..<self.endIndex
            
            let startRange = self.range(of: str,options: .regularExpression, range: range, locale: nil)
            
            if(startRange == nil){
                break
            }
            
            results.append(startRange!)
            
            startIndex = startRange?.upperBound
        } while true
        return results
    }
    
    func keywordRanges(of str:String) -> [Range<String.Index>]{
        var results = [Range<String.Index>]()
        if(!self.contains(str)){
            return results
        }
        
        let keywordCharacters = str.characters
        let keywordCharacterCount = str.characters.count
        var tempIndex = -1
        var keywordIndex = keywordCharacters.index(keywordCharacters.startIndex, offsetBy: tempIndex+1)
        var keywordCharater = keywordCharacters[keywordCharacters.startIndex]
        
        
        var firstFoundIndex = -1 ;
        
        
        for index in 0..<self.characters.count {
            
            let charachterIndex = self.characters.index(self.characters.startIndex, offsetBy: index)
            let charachter = self.characters[charachterIndex]
            
            if(tempIndex != -1 && tempIndex <= ( keywordCharacters.count - 2 )){
                //开头找到了一部分。
                //从第 tempIndex + 1 位开始比较
                
                keywordIndex = keywordCharacters.index(keywordCharacters.startIndex, offsetBy: tempIndex+1)
                keywordCharater = keywordCharacters[keywordIndex]
            }
            else if(tempIndex == (keywordCharacters.count - 1)){
                //可以确认包含关键字，比较下一位是否是字母
                if (charachter.isWord()) {
                    //下一位是字母，所以不匹配
                    // 不匹配的话，就重置比较的内容，下次从 第一个开始比较
                    firstFoundIndex = -1
                    tempIndex = -1
                    
                    keywordIndex = keywordCharacters.index(keywordCharacters.startIndex, offsetBy: tempIndex+1)
                    keywordCharater = keywordCharacters[keywordIndex]
                    continue
                }
                else{
                    //匹配.找到了一个，继续找
                    let range = self.index(self.startIndex, offsetBy: firstFoundIndex)..<self.index(self.startIndex, offsetBy: firstFoundIndex+keywordCharacterCount)
                    results.append(range)
                    
                    // 已经找到了匹配的内容，重置比较的内容，下次从 第一个开始比较
                    firstFoundIndex = -1
                    tempIndex = -1
                    keywordIndex = keywordCharacters.index(keywordCharacters.startIndex, offsetBy: tempIndex+1)
                    keywordCharater = keywordCharacters[keywordIndex]
                }
            }
            
            if(charachter == keywordCharater){
                //当前位进行比较。如果比较不对称。则tempIndex = -1
                tempIndex += 1
                if(tempIndex == 0){
                    //第一位匹配的时候，需要检查一下在这之前的是否是字母
                    if(index != 0){
                        let prevCharachterIndex = self.characters.index(self.characters.startIndex, offsetBy: index-1)
                        let prevCharachter = self.characters[prevCharachterIndex]
                        if(prevCharachter.isWord()){
                            //如果前一位是字母的话，就没有必要进行比较了
                            tempIndex = -1
                            continue
                        }
                    }else{
                        //如果前面没有内容，那就进行比较
                    }
                    firstFoundIndex = index
                    
                    
                }
                else if(tempIndex == (keywordCharacters.count - 1) && index == (characters.count - 1)){
                    //可以确认包含关键字,而且已经遍历到最后一位了，可以肯定是关键词了
                    let range = self.index(self.startIndex, offsetBy: firstFoundIndex)..<self.index(self.startIndex, offsetBy: firstFoundIndex+keywordCharacterCount)
                    results.append(range)
                    //此时不需要进行重置比较的内容
                }
            }
            else{
                tempIndex = -1
                keywordIndex = keywordCharacters.index(keywordCharacters.startIndex, offsetBy: tempIndex+1)
                keywordCharater = keywordCharacters[keywordIndex]
            }
            
            
            
            
            
        }
        
        return results
    }
    
        
    public func mmdToHTMLDocument()  {
//        let output = markdown_to_string(self, UInt(EXT_COMPLETE.rawValue), Int32(HTML_FORMAT.rawValue))
//        let str = String(cString: output!)
        
        
    }
    
}
extension Character {
    func toInt() -> Int
    {
        var intFromCharacter:Int = 0
        for scalar in String(self).unicodeScalars
        {
            intFromCharacter = Int(scalar.value)
        }
        return intFromCharacter
    }
    func isWord() -> Bool {
        let unicodeValue = self.toInt()
        if (unicodeValue > 64 && unicodeValue < 91) || (unicodeValue > 96 && unicodeValue < 123) {
            return true
        }
        return false
    }
}

extension UIColor {
    class func hexColor(_ rgbValue: Int) -> UIColor{
        
        return UIColor(red: CGFloat(Float((rgbValue & 0xFF0000) >> 16).divided(by: 255.0)) , green: CGFloat(Float((rgbValue & 0xFF00) >> 8).divided(by: 255.0)), blue: CGFloat(Float((rgbValue & 0xFF) ).divided(by: 255.0)), alpha: 1.0)
        
    }
}
