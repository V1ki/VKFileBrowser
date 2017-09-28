//
//  DefaultsKeys.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/29.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {

    // MARK: - Debug HTML settings
    static let consoleViewHeight = DefaultsKey<Double>("consoleViewHeight")
    
    // MARK: - Show Console View
    static let showConsoleView = DefaultsKey<Bool>("showConsoleView")
    
    static let userAgent = DefaultsKey<UserAgent>("userAgent")
    
}

enum UserAgent : Int {
    
    case iPad = 1
    case iPhone = 2
    case Mac = 3
    
}
