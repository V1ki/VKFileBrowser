//
//  GithubViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/15.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Alamofire


class GithubViewController: BaseViewController ,UITableViewDataSource , UITableViewDelegate {
    
    
    let identifier = "CELL"
    
    var owner : String?
    var repo : String?
    
    var curPath : String = "/" {
        didSet{
            self.title = curPath
        }
    }
    
    var datasources : [ContentItemModel] = []
    
    
    
    @IBOutlet weak var filesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:50,height:40)))
        btn.setTitle(LocalizedString("back"), for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(clickBackBtn), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)

        
        let btn1 = UIButton(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:50,height:40)))
        btn1.setTitle(LocalizedString("stop"), for: .normal)
        btn1.setTitleColor(UIColor.black, for: .normal)
        btn1.addTarget(self, action: #selector(clickStopBtn), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItems?.append(UIBarButtonItem(customView: btn1))
        
        
        let btn2 = UIButton(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:50,height:40)))
        btn2.setTitle(LocalizedString("clone"), for: .normal)
        btn2.setTitleColor(UIColor.black, for: .normal)
        btn2.addTarget(self, action: #selector(clickCloneBtn), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn2)
        
        self.getRateLimite()
        
        // Do any additional setup after loading the view.
        filesTableView.hideExtraCell()
        self.getDirContent(owner!, repo: repo!, {() in
            
            DispatchQueue.main.async {
                self.filesTableView.reloadData()
            }
            
        })
    }
    func clickCloneBtn(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.clone(owner!, repo: repo!)
        hud?.hide(true, afterDelay: 5)
    }
    
    
    func clone(_ owner:String,repo:String,path:String = "" ,ref:String = "master"){
        Alamofire.request(URLRouter.getContents(owner: owner/*"Alamofire"*/, repo: repo/*"Alamofire"*/, path: path, ref: ref)).responseJSON { response in
            
            if let json = response.result.value {
                
                
                if let result  = ContentItemModel.mj_objectArray(withKeyValuesArray: json){
                    
                    for item in result{
                        let itemModel = (item as! ContentItemModel)
                        
                        if(itemModel.isFile()){
                            if(itemModel.download_url != nil)
                            {
                                DownloadUtils.downloadFile(URL(string:itemModel.download_url!)!, completionHanler: nil)
                            }
                        }
                        else{
                            
                            if let itemPath = itemModel.path{
                                //                                log("itemPath:\(itemPath)")
                                self.clone(owner, repo: repo,path:itemPath)
                            }
                            
                        }
                    }
                }
                else{
                    // may be rate limit ， check rate limit
                    
                    log("JSON: \(json)") // serialized json response
                    
                    self.getRateLimite()
                    
                }
            }
        }
    }
    
    func getRateLimite(){
        Alamofire.request(URLRouter.getRateLimite()).responseJSON(completionHandler: {response in
            if case let json as NSDictionary = response.result.value {
                log("json:\(json)")
                
                let resources = json["resources"] as! NSDictionary
                let core = resources["core"] as! NSDictionary
                let coreResetTime = core["reset"]
                let coreResetDate = Date(timeIntervalSince1970: coreResetTime as! TimeInterval)
                log("coreResetDate:\(coreResetDate) ") // serialized json response
                
                let rate = json["rate"] as! NSDictionary
                let rateRemaining = rate["remaining"]
                let resetTime = rate["reset"]
                let date = Date(timeIntervalSince1970: resetTime as! TimeInterval)
                
                log("rateRemaining:\(rateRemaining) date : \(date)") // serialized json response
                
                
            }
        })
    }
    
        
    
    func clickStopBtn(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func clickBackBtn(){
        print("curPath:\(curPath)")
        let endRange = curPath.range(of: "/", options: .backwards, range: nil, locale: nil)
        if(endRange != nil){
            let str = curPath.substring(with: curPath.startIndex..<(endRange?.lowerBound)!)
            curPath = str
            self.getDirContent(owner!, repo: repo!, path: curPath, {() in
                DispatchQueue.main.async {
                    self.filesTableView.reloadData()
                }
            })
        }else{
            curPath = ""
            self.getDirContent(owner!, repo: repo!, path: curPath, {() in
                DispatchQueue.main.async {
                    self.filesTableView.reloadData()
                }
            })
        }
        
    }
    

    
    func getDirContent(_ owner:String,repo:String,path:String = "" ,ref:String = "master",_ complitionHandler:@escaping (()->Swift.Void)){
        Alamofire.request(URLRouter.getContents(owner: owner/*"Alamofire"*/, repo: repo/*"Alamofire"*/, path: path, ref: ref)).responseJSON { response in
            
            if let json = response.result.value {
                //                log("JSON: \(json)") // serialized json response
                
                if let result  = ContentItemModel.mj_objectArray(withKeyValuesArray: json){
                    
                    self.datasources.removeAll()
                    
                    for item in result{
                        let itemModel = (item as! ContentItemModel)
                        self.datasources.append(itemModel)
                    }
                    complitionHandler()
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasources.count
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if(cell == nil){
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        let itemModel = datasources[indexPath.row]
        cell?.accessoryType = .none
        if(itemModel.isDir()){
            cell?.accessoryType = .disclosureIndicator
        }
        
        cell?.textLabel?.text = itemModel.name
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itemModel = datasources[indexPath.row]
        
        if(itemModel.isDir()){
            print(itemModel)
            
            self.curPath = itemModel.path!
            
            self.getDirContent(owner!, repo: repo!, path: itemModel.path!, {() in
                DispatchQueue.main.async {
                    self.filesTableView.reloadData()
                }
            })
            
        }else{
            
            if(itemModel.download_url != nil)
            {
                DownloadUtils.downloadFile(URL(string:itemModel.download_url!)!, completionHanler: {(pathStr) in
                    var path = ""
                    let endRange = pathStr.range(of: "/", options: .backwards, range: nil, locale: nil)
                    if(endRange != nil){
                        let str = pathStr.substring(with: pathStr.startIndex..<(endRange?.lowerBound)!)
                        path = str
                    }
                    
                    print("pathStr:\(pathStr)")
                    let file = VKFile(URL(fileURLWithPath: pathStr).lastPathComponent,path, true, "",0)
                    
                    if(file.name.hasSuffix(".7z")){
                        
                        LZMAExtractor.extract7zArchive(pathStr, dirName: path.appending("/\(file.name.substring(to: file.name.index(before: file.name.index(file.name.endIndex, offsetBy: -2))))"), preserveDir: true)
                        
                        return
                    }
                    else if (file.name.hasSuffix(".zip")){
                        //                SSZipArchive.unzipFile(atPath: fileDir, toDestination: self.currentDir.appending("/\(file.name.substring(to: file.name.index(before: file.name.index(file.name.endIndex, offsetBy: -3))))"), delegate: self)
                        
                        SSZipArchive.unzipFile(atPath: pathStr, toDestination: path, delegate: nil)
                        return
                    }
                    else if(file.name.hasSuffix(".md")){
                        let markdownVC = MarkdownViewController()
                        markdownVC.mFile = file
                        self.navigationController?.pushViewController(markdownVC, animated: true)
                        
                        return
                    }
                    else if(file.isSourceCodeType()){
                        
                        let sourceCodeVC = SourceViewController()
                        sourceCodeVC.mFile = file
                        self.navigationController?.pushViewController(sourceCodeVC, animated: true)
                        return 
                    }
                    
                    let nextVc = DocumentPreviewObject(_ : URL(fileURLWithPath: pathStr))
                    nextVc.previewVC = self.navigationController
                    nextVc.startPreview()

                })
            }
        }
        
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
