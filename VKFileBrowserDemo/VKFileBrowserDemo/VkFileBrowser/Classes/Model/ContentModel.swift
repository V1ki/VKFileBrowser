//
//  ContentModel.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/5.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation

class ContentModel : BaseModel {
    
    var items: [ContentItemModel]? = []
    
    override static func mj_objectClassInArray() -> [AnyHashable: Any]! {
        return ["items": ContentItemModel.classForCoder()]
    }
}
