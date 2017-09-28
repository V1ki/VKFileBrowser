//
//  HtmlParser.swift
//  HtmlDebugger
//
//  Created by Vk on 2017/9/21.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import SwiftSoup

struct HtmlParser {
    
    
    func parseHtml(_ htmlStr:String) -> String{
        
        if let doc = try? SwiftSoup.parse(htmlStr) {
            return parseChild(doc,indentCount:0)
        }
        return ""
        
    }
    
    func indentStr(indentCount:Int) -> String {
        var str = ""
        for _ in 0..<indentCount {
            str += "  "
        }
        return str
    }
    
    func parseChild(_ element:Element,indentCount:Int ) -> String{
        let elements = element.children()

        var formatStr = ""
        if element.tagName() == "script" {
        }
        var attrStr = ""
        if let attrs = element.getAttributes() {
            for attr in attrs {
                attrStr += " \(attr.getKey())=\"\(attr.getValue())\""
            }
        }
        
        if elements.size() > 0 {
            formatStr += "\(indentStr(indentCount: indentCount))<\(element.tagName())\(attrStr)>\n"
            for element in elements {
                formatStr += parseChild(element,indentCount: indentCount+1)
            }
            formatStr += "\(indentStr(indentCount: indentCount))</\(element.tagName())>\n"
        }
        else{
            if let htmlStr = try? element.html() {
                if htmlStr.isEmpty {
                    if let outHtmlStr = try? element.outerHtml() {
                        formatStr += "\(indentStr(indentCount: indentCount))\(outHtmlStr)\n"
                    }
                }
                else {
                    let lineStr = "\(indentStr(indentCount: indentCount))<\(element.tagName())\(attrStr)>\(htmlStr)</\(element.tagName())>\n"
                    formatStr += lineStr
                }
            }
        }
        return formatStr
        
        
    }
    
}


