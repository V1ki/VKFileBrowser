//
//  PopoverViewController.swift
//  HtmlDebugger
//
//  Created by Vk on 2017/9/19.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyUserDefaults

class PopoverViewController: UITableViewController {
    
    @IBOutlet weak var consoleToggleSwitch: UISwitch!
    @IBOutlet weak var sourceOrPreviewLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    var consoleToggleVar = Variable<Bool>(true)
    var itemSelectEvent : ControlEvent<IndexPath>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.tableView.hideExtraCell()
        //        self.tableView.layer.cornerRadius = 20
        self.view.layer.cornerRadius = 15
        
        consoleToggleSwitch.isOn = Defaults[.showConsoleView]
        
        consoleToggleSwitch.rx.isOn.bind{ bool in
            Defaults[.showConsoleView] = bool
            self.consoleToggleVar.value = bool
            }.disposed(by: disposeBag)
        
        self.itemSelectEvent = self.tableView.rx.itemSelected
        self.tableView.rx.itemSelected.bind{ ip in
            
            if ip.row == 1 {
                self.tableView.deselectRow(at: ip, animated: true)
            }
            if let cell = self.tableView.cellForRow(at: ip) as? CheckItemCell {
                self.tableView.deselectRow(at: ip, animated: true)
                cell.checkedImgView.isHidden = !cell.checkedImgView.isHidden
            }
            
            }.disposed(by: disposeBag)
        
        
        
        let cell = UITableViewCell.appearance()
        cell.selectedBackgroundView = UIView(frame:cell.frame)
        cell.selectedBackgroundView?.backgroundColor = UIColor.flatPowderBlue
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            return
        }
        //        cell.layer.cornerRadius = 15
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row == 0  || indexPath.row == 2 {
            return false
        }
        
        return true
    }
    
    
    
    
}

