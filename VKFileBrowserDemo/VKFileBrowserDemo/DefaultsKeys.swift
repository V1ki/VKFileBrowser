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

    // MARK: - git 用户名和密码
    static let username = DefaultsKey<String>("username")
    static let password = DefaultsKey<String>("password")
    static let email = DefaultsKey<String>("email")
    
    // MARK: - Wifi 上传文件
    static let autoStart = DefaultsKey<Bool>("autoStart")
    static let wifi = DefaultsKey<Bool>("wifi")
    static let url = DefaultsKey<String?>("url")
    static let port = DefaultsKey<Int>("port")
    
}
