//
//  VkFileCustomViewLayout.swift
//  VkFileBrowser
//
//  Created by Vk on 2016/9/26.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit

class VkFileCustomViewLayout: UICollectionViewFlowLayout {
    
    
    var rowCounts : Int!
    /// Collection View 中有几列
    var columnCounts : Int! = 3
    
    var marginX : Float!
    var marginY : Float!

    override func prepare() {
        
        self.itemSize = CGSize(width: 95, height: 110)
        
        
        
    }

}
