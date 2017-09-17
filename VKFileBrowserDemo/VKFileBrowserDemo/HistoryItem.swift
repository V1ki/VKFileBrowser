//
//  HistoryItem.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/17.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryItem: Object {
    
    dynamic var url = ""
    dynamic var title = "" //
    dynamic var date = Date()
}
