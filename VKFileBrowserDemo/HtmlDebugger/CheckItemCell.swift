//
//  CheckItemCell.swift
//  HtmlDebugger
//
//  Created by Vk on 2017/9/20.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class CheckItemCell: UITableViewCell {
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var checkedImgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkedImgView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }

}
