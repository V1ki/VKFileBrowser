//
//  MultiMarkdown.swift
//  SwiftMMD
//
//  Created by Steve Brokaw on 11/18/15.
//  Copyright © 2015 Steven Brokaw. All rights reserved.
//

import Foundation

//public struct ParserExtension: OptionSet {
//    public let rawValue: UInt
//    public init(rawValue: UInt) {
//        self.rawValue = rawValue
//    }
//    public static let Compatibility = ParserExtension(rawValue: UInt(EXT_COMPATIBILITY.rawValue))
//    public static let Complete = ParserExtension(rawValue: UInt(EXT_COMPLETE.rawValue))
//    //etc
//}

public enum ExportFormat: UInt32 {
    case html
}
/*
public func mmd_string_to_markdown(_ string: String) -> String? {
    let output = markdown_to_string(string, UInt(EXT_COMPLETE.rawValue), Int32(HTML_FORMAT.rawValue))
    let str = String(cString: output!)
    free(output)
    return str
}
 */

public extension String {

//    public func mmdToHTMLDocument() -> String? {
//        let output = markdown_to_string(self, UInt(EXT_COMPLETE.rawValue), Int32(HTML_FORMAT.rawValue))
//        let str = String(cString: output!)
//        free(output)
//        return str
//    }
//    public func mmdRenderToFormat(_ format: export_formats, extensions: parser_extensions) -> String? {
//        let output = markdown_to_string(self, UInt(extensions.rawValue), Int32(format.rawValue))
//        let str = String(cString: output!)
//        free(output)
//        return str
//    }
//    public func mmdHasMetadataWithExtenstion(_ extensions: parser_extensions) -> Bool {
//        return has_metadata(self, UInt(extensions.rawValue))
//    }
//    public func mmdMetadataKeysWithExtensions(_ extensions: parser_extensions) -> String? {
//        let output = extract_metadata_keys(self, UInt(extensions.rawValue))
//        let str = String(cString: output!)
//        free(output)
//        return str
//    }
//
//    public func mmdMetadataValueForKey(_ key:String, extensions: parser_extensions) -> String? {
//        let keyData = key.data(using: String.Encoding.utf8)!
//        let keyPtr = UnsafeMutablePointer<Int8>(mutating: (keyData as NSData).bytes.bindMemory(to: Int8.self, capacity: keyData.count))
//        let output = extract_metadata_value(self, UInt(extensions.rawValue), keyPtr)
//        let str = String(cString: output!)
//        free(output)
//        return str
//    }
}
