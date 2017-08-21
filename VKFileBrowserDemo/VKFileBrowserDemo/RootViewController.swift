//
//  RootViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/18.
//  Copyright © 2017年 vk. All rights reserved.
//
import UIKit
import Result

import SwipeCellKit

class RootViewController: UITableViewController,SSZipArchiveDelegate {

    /// MARK: -- Property
    let fm = FileManager.default
    
    var dataSource = [VKFile]()
    let reuseIdentifier = "Cell"
    var shouldGoPrev = false
    var shouldNoAnim = false
    
    var currentDir : String! {
        didSet{
            if(currentDir != nil && currentDir != oldValue){
                if(oldValue != nil){
                    shouldNoAnim = false
                    shouldGoPrev = currentDir.characters.count < oldValue.characters.count
                }else{
                    shouldNoAnim = true
                }
                
                reloadCurPage()
                self.title = currentDir.components(separatedBy: "/").last
                if(currentDir == documentDir){
                    navigationItem.leftBarButtonItem = settingItem!
                }else{
                    navigationItem.leftBarButtonItem = backItem!
                }
            }
        }
    }
    
    
    var settingItem : UIBarButtonItem?
    var backItem : UIBarButtonItem?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fm.delegate = self
        
        let btn = UIButton(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:32,height:32)))
        btn.setImage(UIImage(named: "bottom_setting"), for: .normal)
        btn.setImage(UIImage(named: "bottom_setting_pressed"), for: .highlighted)
        btn.addTarget(self, action: #selector(clickSettingBtn), for: UIControlEvents.touchUpInside)
        
        settingItem = UIBarButtonItem(customView: btn)
        
        navigationItem.leftBarButtonItem = settingItem!
        
        
        let btn1 = UIButton(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:36,height:36)))
        btn1.setImage(UIImage(named: "back-icon"), for: .normal)
        btn1.addTarget(self, action: #selector(clickBackBtn), for: UIControlEvents.touchUpInside)
        
        backItem = UIBarButtonItem(customView: btn1)
        
        
        
        let btn2 = UIButton(type: .contactAdd)
        
        btn2.addTarget(self, action: #selector(clickAddBtn), for: UIControlEvents.touchUpInside)
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn2)
        
        self.tableView.hideExtraCell()
        if (currentDir == nil) {
            currentDir = documentDir
        }
        
        self.loadFileAtPath(currentDir)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func clickAddBtn(_ sender:UIView){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let createAction = UIAlertAction(title: LocalizedString("Create New Folder"), style: .default, handler: {(action) in
            
        })
        let wifiTransferAction = UIAlertAction(title: LocalizedString("WiFi Transfer"), style: .default, handler: nil)
        let gitCloneAction = UIAlertAction(title:LocalizedString("Git Clone"), style: .default, handler: {(action) in
            
            let vc = CloneViewController()
            vc.modalPresentationStyle = .popover
            self.present(vc, animated: true, completion: nil)
            
            
            let presentationController = vc.popoverPresentationController
            
            // Get the popover presentation controller and configure it.

            presentationController?.permittedArrowDirections = .unknown
            presentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            presentationController?.sourceRect = CGRect(x:0,y:0,width:200,height:200);
        })
        alertController.addAction(createAction)
        alertController.addAction(wifiTransferAction)
        alertController.addAction(gitCloneAction)
        
//        self.detailViewController()?.present(alertController, animated: true, completion: nil)
        let popover = alertController.popoverPresentationController
        if (popover != nil){
            popover?.sourceView = sender
            popover?.sourceRect = sender.bounds
            popover?.permittedArrowDirections = UIPopoverArrowDirection.any
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func clickSettingBtn(){}

    func clickBackBtn(){
        
        if(currentDir == documentDir){
            return
        }
        
        let endRange = currentDir.range(of: "/", options: .backwards, range: nil, locale: nil)
        if(endRange != nil){
            let str = currentDir.substring(with: currentDir.startIndex..<(endRange?.lowerBound)!)
            currentDir = str
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadCurPage(){
        self.loadFileAtPath(self.currentDir)
    }
    
    func loadFileAtPath(_ path: String){
        dataSource = VKFileManager.default.loadFile(at: path,loadGit: true)
        
        dataSource.sort(by: {(file1,file2) -> Bool in
            return file1.compare(withOtherFile: file2, bySortType: .name)
        })
        
        currentDir = path
        
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer:0), with: self.shouldNoAnim ? .none : (self.shouldGoPrev ? .right: .left))
        }
        
        
        
    }
    
    
    func selectFile(_ file :VKFile){
        
        
        
        let fileDir : String = file.filePath!.appending("/\(file.name!)")
        log("fileDir:\(fileDir)")
        
        
        if file.isDirectory {
            
            if RepositoryUtils.isGitRepository(file.toFileURL()) {
                //当前处于git仓库下
                let repo = RepositoryUtils.at(file.toFileURL()).value
                
                RepositoryUtils.listAllCommits(repo!){ commits in
                    
                }
                
                
                
                
                
            }
            
            
            self.currentDir = fileDir
        }
        else
        {
            if(file.name.hasSuffix(".7z")){
                
                LZMAExtractor.extract7zArchive(fileDir, dirName: self.currentDir.appending("/\(file.name.substring(to: file.name.index(before: file.name.index(file.name.endIndex, offsetBy: -2))))"), preserveDir: true)
                
                reloadCurPage()
                
                
                return
            }
            else if (file.name.hasSuffix(".zip")){
                //                SSZipArchive.unzipFile(atPath: fileDir, toDestination: self.currentDir.appending("/\(file.name.substring(to: file.name.index(before: file.name.index(file.name.endIndex, offsetBy: -3))))"), delegate: self)
                
                SSZipArchive.unzipFile(atPath: fileDir, toDestination: self.currentDir, delegate: self)
                return
            }else if(file.isImageType()){
                let imgs = dataSource.filter({$0.isImageType() })
                var photos = [MWPhoto]()
                
                if(imgs.count > 0){
                    for  vkFile in imgs {
                        
                        let photoUrl = URL(fileURLWithPath:self.currentDir.appending("/\(vkFile.name!)"))
                        
                        let photo = MWPhoto(url: photoUrl)
                        photos.append(photo!)
                    }
                    
                    
                    let browser = MWPhotoBrowser(photos: photos)
                    
                    self.pushDetailViewController(browser!, sender: nil)
                    
                    return ;
                }
            }
            else if(file.isSourceCodeType()){
                
                let sourceCodeVC = SourceViewController()
                sourceCodeVC.mFile = file
                
                self.pushDetailViewController(sourceCodeVC, sender: nil)
                return
            }
            else if(file.name.hasSuffix(".md")){
                let markdownVC = MarkdownViewController()
                markdownVC.mFile = file
                
                self.pushDetailViewController(markdownVC, sender: nil)
                return
            }
            
            log("fileDir:\(fileDir) == file.type:\(file.type)")
            
            let nextVc = DocumentPreviewObject(_ : URL(fileURLWithPath: fileDir))
            nextVc.previewVC = self.detailViewController() as! UINavigationController?
            
            nextVc.startPreview()
        }
    }
    

    // MARK: UITableView  DataSouce And Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataSource.count
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? SwipeTableViewCell
        if (cell == nil) {
            cell = SwipeTableViewCell(style:.default, reuseIdentifier: reuseIdentifier)
            cell?.delegate = self
        }
        let file = dataSource[indexPath.row]
        
        cell?.textLabel?.text = file.name
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        
        cell?.imageView?.image = file.isDirectory ? UIImage(named: "folder") : UIImage(named: "file")
        
        if file.isDirectory {
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if(action == #selector(deleteAction)){
//            return true
//        }
        return false
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let file = dataSource[indexPath.row]
        
        selectFile(file)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    

}

//FileManager Delegate
extension RootViewController :FileManagerDelegate {
    
    func fileManager(_ fileManager: FileManager, shouldRemoveItemAtPath path: String) -> Bool {
        log("shouldRemoveItemAtPath",path)
        //        reloadCurPage()
        return true
    }
    
    func fileManager(_ fileManager: FileManager, shouldRemoveItemAt URL: URL) -> Bool {
        log("shouldRemoveItemAt",URL)
        //        reloadCurPage()
        return true
    }
    
    func fileManager(_ fileManager: FileManager, shouldCopyItemAt srcURL: URL, to dstURL: URL) -> Bool {
        log("shouldCopyItemAt",srcURL ,dstURL)
        return true
    }
    
    func fileManager(_ fileManager: FileManager, shouldLinkItemAt srcURL: URL, to dstURL: URL) -> Bool {
        log("shouldLinkItemAt",srcURL ,dstURL)
        return true
    }
    
    func fileManager(_ fileManager: FileManager, shouldMoveItemAt srcURL: URL, to dstURL: URL) -> Bool {
        //        log("shouldMoveItemAt",srcURL ,dstURL)
        reloadCurPage()
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldCopyItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        log("shouldCopyItemAtPath",srcPath ,dstPath)
        reloadCurPage()
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldLinkItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        log("shouldLinkItemAtPath",srcPath ,dstPath)
        reloadCurPage()
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldMoveItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        log("shouldMoveItemAtPath",srcPath ,dstPath)
        reloadCurPage()
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, removingItemAt URL: URL) -> Bool {
        log("shouldProceedAfterError",error ,"removingItemAt",URL)
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, removingItemAtPath path: String) -> Bool {
        log("shouldProceedAfterError",error ,"removingItemAt",path)
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, movingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        log("shouldProceedAfterError",error ,"movingItemAt",srcURL,dstURL)
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, copyingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        log("shouldProceedAfterError",error ,"copyingItemAt",srcURL,dstURL)
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, linkingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        log("shouldProceedAfterError",error ,"linkingItemAt",srcURL,dstURL)
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, movingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        log("shouldProceedAfterError",error ,"movingItemAtPath",srcPath,dstPath)
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, copyingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        log("shouldProceedAfterError",error ,"copyingItemAtPath",srcPath,dstPath)
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, linkingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        log("shouldProceedAfterError",error ,"linkingItemAtPath",srcPath,dstPath)
        return true
    }
}

//SwipeTableViewCellDelegate
extension RootViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if(orientation == .left){
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                
                
                let file = self.dataSource[indexPath.row]
                try! self.fm.removeItem(at: file.toFileURL())

                self.dataSource.remove(at: indexPath.row)
                
            }
            
            return [deleteAction]
        }
        else{
            let action = SwipeAction(style: .default, title: "Action"){ action ,indexPath in
                
            }
            return [action]
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructiveAfterFill
        options.transitionStyle = .drag
        return options
    }
}

extension RootViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
