//
//  RemoteViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/23.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources




class RemoteViewController: BaseViewController {
    
    let cellIdentifier = "CELL"
    let dataSource = [[""],["Name","URL"]]
    
    @IBOutlet weak var mTableView: UITableView!
    var repo:Repository?
    var remote:Remote?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.title = LocalizedString("Remote")
        
        self.mTableView.dataSource = nil
        self.mTableView.delegate = nil
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>()
        
        let items = Observable.just([
            SectionModel(model: "First section", items: [""]),
            SectionModel(model: "Second section", items: [LocalizedString("Name"),LocalizedString("URL")])
            
            ])
        //(TableViewSectionedDataSource<S>, Int) -> String?
        dataSource.titleForHeaderInSection = {tDataSource,section in
            return "  "
        }
        
        
        dataSource.configureCell = { (tdataSource, tv, indexPath, element) in
            var cell = tv.dequeueReusableCell(withIdentifier: self.cellIdentifier)
            if(cell == nil){
                cell = UITableViewCell(style: .default, reuseIdentifier: self.cellIdentifier)
            }
            if(element.isEmpty){
                let fetchBtn = UIButton(frame: CGRect(x:20,y:0,width:50,height:cell?.mj_h ?? 40))
                fetchBtn.backgroundColor = .clear
                fetchBtn.setTitle(LocalizedString("Fetch"), for: .normal)
                fetchBtn.setTitleColor(fetchBtn.tintColor, for: .normal)
                fetchBtn.rx.tap.bind {
                    print("click fetch")
                    RepositoryUtils.fetchRemote(self.repo!, self.remote!.name)
                    
                }.disposed(by: disposeBag)
                
                cell?.addSubview(fetchBtn)
                
                
                let pushBtn = UIButton(frame: CGRect(x:self.view.mj_w - 20 - 50,y:0,width:50,height:cell?.mj_h ?? 40))
                pushBtn.backgroundColor = .clear
                pushBtn.setTitle(LocalizedString("Push"), for: .normal)
                pushBtn.setTitleColor(fetchBtn.tintColor, for: .normal)
                pushBtn.rx.tap.bind {
                    
                    print("click push")
                    
                    }.disposed(by: disposeBag)
                
                cell?.addSubview(pushBtn)
                
                
            }else{
                cell?.textLabel?.text = element
                let textField = UITextField(frame: CGRect(x:80,y:0,width:self.view.mj_w - 100,height:cell?.mj_h ?? 40))
                
                if(element == LocalizedString("Name")){
                    textField.text = self.remote?.name
                }else if(element == LocalizedString("URL")){
                    textField.text = self.remote?.URL
                }
                
                cell?.addSubview(textField)
            }
            
            
            
            return cell!
        }
        
        
        
        
        items
            .bind(to: self.mTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        
        self.mTableView.hideExtraCell()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension RemoteViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

