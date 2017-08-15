//
//  VKSearchViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/14.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

class VKSearchViewController: BaseViewController , UITableViewDataSource , UITableViewDelegate ,UISearchBarDelegate {
    
    
    @IBOutlet weak var resultTableView: UITableView!
    
    typealias CallBack = ((NSURL) -> Swift.Void)
    
    var callBack : CallBack?
    
    let fileManager = FileManager.default
    let documentDir : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    let searchQueue = DispatchQueue(label: "com.vk.search")
    var searchWorkItem : DispatchWorkItem? {
        didSet{
            if(searchWorkItem != nil){
                searchQueue.asyncAfter(deadline: DispatchTime.now()+0.5, execute: searchWorkItem!)
            }
            
        }
    }
    
    var dataSource : [NSURL] = [] {
        didSet{
            DispatchQueue.main.async {
                self.resultTableView.reloadData()
            }
        }
    }
    
    func searchFile(_ fileName:String) -> [Any]{
        print("searchFile:\(fileName)")
        let resourceKeys = [URLResourceKey.nameKey,URLResourceKey.isDirectoryKey,URLResourceKey.pathKey,URLResourceKey.typeIdentifierKey]
        let directoryEnumerator = fileManager.enumerator(at:URL(fileURLWithPath: documentDir), includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil)!
        
        let results = directoryEnumerator.filter({try! ((($0 as! NSURL).resourceValues(forKeys: resourceKeys)[URLResourceKey.nameKey] as? String)?.range(of: fileName, options: .caseInsensitive, range: nil, locale: nil) != nil ) })
        
        
        
        print("\(type(of:results))")
        return results
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        // Install the search bar as the table header.
        let searchBar = UISearchBar(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:300,height:44)))
        searchBar.delegate = self
        resultTableView.tableHeaderView = searchBar
        resultTableView.delegate = self
        resultTableView.dataSource = self
//        resultTableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchCell")
        resultTableView.hideExtraCell()
        // Do any additional setup after loading the view.
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        resultTableView.tableHeaderView?.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        print("input searchText:\(searchText)")
        
        if(searchWorkItem != nil){
            
            searchWorkItem?.cancel()
        }

        if(searchText.isEmpty){
            
            return
        }
        
        
        
        searchWorkItem = DispatchWorkItem(block: {() in
            let results = self.searchFile(searchText)
            
            DispatchQueue.main.sync {
                self.dataSource.removeAll()
                self.resultTableView.reloadData()
            }
            
            
            for case let fileURL as NSURL in results {
                self.dataSource.append(fileURL)
            }
            DispatchQueue.main.sync {
                self.resultTableView.reloadData()
            }
        })
        
        
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataSource.count
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")
        
        if(cell == nil){
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "searchCell")
        }
        
        cell?.accessoryType = .disclosureIndicator
        
        
        let fileUrl = dataSource[indexPath.row]

        let path = (fileUrl.deletingLastPathComponent?.path)! + "/"
        let name = fileUrl.lastPathComponent
        
        cell?.textLabel?.text = name
        cell?.detailTextLabel?.text = path.substring(from: path.index(path.startIndex, offsetBy: documentDir.characters.count))
        
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let fileUrl = dataSource[indexPath.row]

        self.dismiss(animated: true, completion: {() in
            if((self.callBack) != nil){
                self.callBack!(fileUrl)
            }
        })
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
