//
//  NetworkItemCellTableViewCell.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/18.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import VBFPopFlatButton
import MGSwipeTableCell

class NetworkItemCell: UITableViewCell {

    
    var item : NetworkItem? {
        didSet {
            guard let item = item else { return }
            var url = (item.url.components(separatedBy: "://").last)!
            if url.characters.last == "/" {
                url = url.substring(to: url.index(url.endIndex, offsetBy: -1))
            }
            
            let str = (url.components(separatedBy: "/").last)!
            
            self.textLabel?.text = "\(str.isEmpty ? url : str )"
            
            self.detailTextLabel?.text = "\(url)"
        }
    }
    
    init(reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.initView()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }
    
    
    func initView(){
        let nextBtn = VBFPopFlatButton(frame: CGRect(x:0,y:0,width:18,height:18), buttonType: .buttonForwardType, buttonStyle: .buttonRoundedStyle , animateToInitialState: false)
        
        nextBtn?.backgroundColor = UIColor.clear
        nextBtn?.tintColor = .flatBlue
        self.addSubview(nextBtn!)
        
        nextBtn!.snp.makeConstraints{ make in
            make.right.equalTo(0)
            make.top.equalTo(13)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
        self.addSubview(separatorLine)
        
        separatorLine.snp.makeConstraints{ make in
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
            make.left.equalTo(15)
            make.right.equalTo(0)
        }
        
        
        self.textLabel?.snp.makeConstraints{ make in
            make.top.equalTo(5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(20.5)
            
        }
        
        self.detailTextLabel?.snp.makeConstraints{ make in
            make.top.equalTo(25.5)
            make.left.equalTo((self.textLabel)!)
            make.height.equalTo(14.5)
            make.right.equalTo(-15)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
