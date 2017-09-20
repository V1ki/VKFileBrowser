//
//  VKDiffView.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/8.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class VKDiffView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    // splitMode
    var beforeView : VKTextView =  VKTextView()
    var afterView : VKTextView =  VKTextView()
    
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    
    func commonSetup(){
        self.addSubview(beforeView)
        self.addSubview(afterView)
        
        beforeView.snp.makeConstraints{ make in
            make.top.equalTo(self)
            make.left.equalTo(0)
            make.width.equalTo(self).dividedBy(2)
            make.height.equalTo(self)
        }
        
        afterView.snp.makeConstraints{ make in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.right.equalTo(0)
            make.width.equalTo(self).dividedBy(2)
        }
        
        
    }
    
    
    
}
