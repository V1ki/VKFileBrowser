//
//  PopoverViewController.swift
//  HtmlDebugger
//
//  Created by Vk on 2017/9/19.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyUserDefaults

class PopoverViewController: UITableViewController {
    
    @IBOutlet weak var consoleToggleSwitch: UISwitch!
    @IBOutlet weak var sourceOrPreviewLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    var consoleToggleVar = Variable<Bool>(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loadPopover")
        
        self.tableView.hideExtraCell()
//        self.tableView.layer.cornerRadius = 20
        self.view.layer.cornerRadius = 15
        
        consoleToggleSwitch.isOn = Defaults[.showConsoleView]
        
        consoleToggleSwitch.rx.isOn.bind{ bool in
            Defaults[.showConsoleView] = bool
            self.consoleToggleVar.value = bool
            }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind{ ip in
            
            if ip.row == 1 {
                self.tableView.deselectRow(at: ip, animated: true)
            }
            
            }.disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 15
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }

    
    
    
    
    
    
    
    
}

