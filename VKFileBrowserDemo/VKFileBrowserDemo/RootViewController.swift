//
//  RootViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/18.
//  Copyright © 2017年 vk. All rights reserved.
//
import UIKit
import Result
import MJRefresh
import SwipeCellKit

class RootViewController: UITableViewController,SSZipArchiveDelegate {

    /// MARK: -- Property
    let fm = FileManager.default
    
    var dataSource = [VKFile]()
    let repoReuseIdentifier = "repoCell"
    let fileReuseIdentifier = "fileCell"
    var shouldGoPrev = false
    var shouldNoAnim = false
    
    var currentRepo : Repository?
    var currentStatus = [String:StatusEntry]()
    
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
        
        self.tableView.mj_header = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(reloadCurPage))
        
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
        let createFolderAction = UIAlertAction(title: LocalizedString("Create New Folder"), style: .default, handler: {(action) in
            
            
            self.showAlertController(LocalizedString("Create New Folder"), LocalizedString("File Name"), LocalizedString("Cancel"), LocalizedString("Save"), nil , {(action,filename) in
                let fileDir = self.currentDir.appending("/\(filename)")
                let createSuccess = VKFileManager.default.createNewFolder(fileDir)
                if(!createSuccess){
                    self.showAlertController(LocalizedString("Warning"), LocalizedString("File Already Exist"), LocalizedString("Confirm"), nil, nil, nil)
                }
                else{
                    self.reloadCurPage()
                }
            })
            
        })
        let createFileAction = UIAlertAction(title: LocalizedString("Create New File"), style: .default, handler: {(action) in
            
            
            self.showAlertController(LocalizedString("Create New File"), LocalizedString("File Name"), LocalizedString("Cancel"), LocalizedString("Save"), nil , {(action,filename) in
                let fileDir = self.currentDir.appending("/\(filename)")
                let createSuccess = VKFileManager.default.createNewFile(fileDir)
                if(!createSuccess){
                    self.showAlertController(LocalizedString("Warning"), LocalizedString("File Already Exist"), LocalizedString("Confirm"), nil, nil, nil)
                }
                else{
                    self.reloadCurPage()
                }
            })
            
            
        })
        let initRepositoryAction = UIAlertAction(title: LocalizedString("Init Repository"), style: .default, handler: {(action) in
            let fileUrl = URL(fileURLWithPath: self.currentDir)
            self.currentRepo = Repository.create(at: fileUrl).value
            
            self.tableView.reloadData()
            
            
            
        })
        let wifiTransferAction = UIAlertAction(title: LocalizedString("WiFi Transfer"), style: .default, handler: nil)
        let gitCloneAction = UIAlertAction(title:LocalizedString("Git Clone"), style: .default, handler: {(action) in
            
            let vc = CloneViewController()
            vc.modalPresentationStyle = .popover
            log("width:\(SCREEN_WIDTH),height:\(SCREEN_HEIGHT) scale:\(UIScreen.main.nativeScale)")
            if(IS_PAD){
                vc.preferredContentSize = CGSize(width: SCREEN_WIDTH/2 - 300, height: SCREEN_HEIGHT/4)
            }
            
            self.present(vc, animated: true, completion: nil)
            
            
            let presentationController = vc.popoverPresentationController
            // Get the popover presentation controller and configure it.

            presentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            
            presentationController?.sourceView = self.view
            presentationController?.sourceRect = CGRect(x:SCREEN_WIDTH/4,y:SCREEN_HEIGHT*3/16,width:0,height:0)
        })
        alertController.addAction(createFolderAction)
        alertController.addAction(createFileAction)
        alertController.addAction(wifiTransferAction)
        alertController.addAction(gitCloneAction)
        alertController.addAction(initRepositoryAction)
        
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

            if(currentRepo != nil){
                let path = (currentRepo?.directoryURL?.path)!
                let pathStr = path.components(separatedBy: documentDir).last?.trimmingCharacters(in: .whitespacesAndNewlines)
                if(!str.contains(pathStr!)){
                    currentRepo = nil
                }
                
            }
            currentDir = str
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadCurPage(){
        self.loadFileAtPath(self.currentDir)
        
        if(currentRepo == nil){
            return
        }
        
        let statusResult = currentRepo?.allStatus()
        if let allStatus = statusResult?.value {
            
            if(allStatus.count > 0){
                print("allStatus:\(allStatus)")
                for status in allStatus {
                    if(status.indexToWorkdir != nil){
                        let key = status.indexToWorkdir?.newFile.path
                        
                        currentStatus[key!] = status
                    }
                }
            }
        }

    }
    
    func loadFileAtPath(_ path: String){
        dataSource = VKFileManager.default.loadFile(at: path)
        
        dataSource.sort(by: {(file1,file2) -> Bool in
            return file1.compare(withOtherFile: file2, bySortType: .name)
        })
        
        currentDir = path
        
        DispatchQueue.main.async {
            let indexSet = self.currentRepo == nil ? IndexSet(integer: 0) : IndexSet(integersIn: 0...1)
            if( self.currentRepo == nil){
                self.tableView.reloadData()
//                self.tableView.reloadSections(indexSet, with: self.shouldNoAnim ? .none : (self.shouldGoPrev ? .right: .left))
            }
            else{
                self.tableView.reloadData()
            }
            
            
        }
        

        
    }
    
    
    func selectFile(_ file :VKFile){
        
        
        
        let fileDir : String = file.filePath!.appending("/\(file.name!)")
        
        if file.isDirectory {
            
            if(currentRepo != nil){
                if(!fileDir.contains(self.currentDir)){
                    
                    currentRepo = nil
                }
                
            }
            if (currentRepo == nil){
                if RepositoryUtils.isGitRepository(file.toFileURL()) {
                    //当前处于git仓库下
                    currentRepo = RepositoryUtils.at(file.toFileURL()).value
                    
                    //读取status
                    
                    let statusResult = currentRepo?.allStatus()
                    if let allStatus = statusResult?.value {
                        
                        if(allStatus.count > 0){
                            for status in allStatus {
                                if(status.indexToWorkdir != nil){
                                    let key = status.indexToWorkdir?.newFile.path
                                    
                                    currentStatus[key!] = status
                                }
                            }
                        }
                    }
                    
                    
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
//                let markdownVC = MarkdownViewController()
//                markdownVC.mFile = file
//                
//                self.pushDetailViewController(markdownVC, sender: nil)
                let sourceCodeVC = SourceViewController()
                sourceCodeVC.mFile = file
                
                self.pushDetailViewController(sourceCodeVC, sender: nil)
                
                return
            }
            
            log("fileDir:\(fileDir) == file.type:\(file.type)")
            
            let nextVc = DocumentPreviewObject(_ : URL(fileURLWithPath: fileDir))
            nextVc.previewVC = self.detailViewController() as! UINavigationController?
            
            nextVc.startPreview()
        }
    }
    

    

}

// MARK: UITableView  DataSouce And Delegate

extension RootViewController  {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(currentRepo != nil && section == 0){ return 1}
        return dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(currentRepo != nil && section == 0){
            return nil
        }
        if(currentRepo != nil && section == 1){
            return "master branch"
        }
        
        return nil
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if(currentRepo != nil){ return 2}
        return 1
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if(currentRepo != nil && indexPath.section == 0){
            let cell = UITableViewCell(style:.subtitle , reuseIdentifier: repoReuseIdentifier)
            cell.textLabel?.text = LocalizedString("Repository")
            cell.detailTextLabel?.text = LocalizedString("Status and Configuration")
            return cell
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: fileReuseIdentifier) as? SwipeTableViewCell
        if (cell == nil) {
            cell = SwipeTableViewCell(style:.default, reuseIdentifier: fileReuseIdentifier)
            
            
            cell?.delegate = self
        }
        let file = dataSource[indexPath.row]
        cell?.imageView?.image = file.isDirectory ? UIImage(named: "folder") : UIImage(named: "file")
        
        var statusImgView = cell?.contentView.viewWithTag(100) as? UIImageView
        if(statusImgView == nil){
            statusImgView = UIImageView(frame: CGRect(x: 20, y: 5, width: 32, height: 32))
            statusImgView?.image = UIImage(named: "AddedIcon")
            statusImgView?.tag = 100
            statusImgView?.isHidden = true
            cell?.contentView.addSubview(statusImgView!)
            
        }
        statusImgView?.isHidden = true
        
        
        cell?.textLabel?.text = file.name
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        if let status = currentStatus[file.name] {
            
            if(status.isNewFile){
                statusImgView?.isHidden = false
                statusImgView?.image = UIImage(named: "AddedIcon")
            }else if(status.isModified){
                statusImgView?.isHidden = false
                statusImgView?.image = UIImage(named: "ModifiedIcon")
            }
        }
        
        
        
        
        
        
        if file.isDirectory {
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(self.currentRepo != nil &&  indexPath.section == 0){
            
            
            let repoVC = RepositoryViewController()
            
            repoVC.currentRepo = currentRepo
            
            self.pushDetailViewController(repoVC, sender: nil)
            
            return
        }
        let file = dataSource[indexPath.row]
        selectFile(file)
        
        
        
    }
    
    
    
}

//FileManager Delegate
extension RootViewController :FileManagerDelegate {
    
    func fileManager(_ fileManager: FileManager, shouldRemoveItemAtPath path: String) -> Bool {
//        log("shouldRemoveItemAtPath",path)
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
                try? self.fm.removeItem(at: file.toFileURL())

                self.dataSource.remove(at: indexPath.row)
                
                self.tableView.reloadData()
            }
            
            return [deleteAction]
        }
        else{
            
            var actions = [SwipeAction]()
            
            
            let action = SwipeAction(style: .default, title: "Action"){ action ,indexPath in
                
            }
            actions.append(action)
            
            
            let file = dataSource[indexPath.row]
            
//            if let status = currentStatus[file.name] {
//                
//                if(status != nil){
//                    
                    let commitAction = SwipeAction(style: .default, title: "Commit"){ action ,indexPath in
                        
                        self.currentRepo!.commitFiles([file.gitPath!], true)
                    }
                    commitAction.backgroundColor = UIColor.green
                    actions.append(commitAction)
                    
                    
//                }
//            }
//            
            
            return actions
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
//        options.expansionStyle = .destructiveAfterFill
        options.transitionStyle = .drag
        return options
    }
}

extension RootViewController : UIPopoverPresentationControllerDelegate {
}
