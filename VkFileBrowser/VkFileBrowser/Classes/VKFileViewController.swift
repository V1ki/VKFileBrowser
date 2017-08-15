//
//  VKFileViewController.swift
//  VkFileBrowser
//
//  Created by Vk on 2016/9/26.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire

public func LocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}



let documentDir : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
let resourceKeys = [URLResourceKey.nameKey,URLResourceKey.isDirectoryKey,URLResourceKey.pathKey,URLResourceKey.typeIdentifierKey,URLResourceKey.totalFileSizeKey,URLResourceKey.creationDateKey]

class VKFileViewController: BaseViewController ,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,FileManagerDelegate,SSZipArchiveDelegate  {
    
    let fileManager = FileManager.default
    /// MARK: -- Property
    var currentDir : String! {
        didSet{
            if(currentDir != nil && currentDir != oldValue){
                reloadCurPage()
                self.title = currentDir.components(separatedBy: "/").last
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var bottomIconOrListBarItem: UIBarButtonItem!
    
    let reuseIdentifier = "Cell"
    
    var selectedIndexPath : IndexPath?
    
    var dataSource = [VKFile]()
    
    
    // MARK: - FileManager delegate -- start
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
        log("shouldMoveItemAt",srcURL ,dstURL)
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

    // MARK: - FileManager delegate -- end
    
    
    // MARK: -- method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        self.initViewStyle()
        mTableView.hideExtraCell()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {() in
            self.reloadCurPage()
            self.collectionView.mj_header.endRefreshing()
        })
        
        
        let btn = UIButton(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:50,height:40)))
        btn.setTitle(LocalizedString("back"), for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(clickBackBtn), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(contextMenuHandler))
        longPressRecognizer.minimumPressDuration = 0.3
        longPressRecognizer.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(longPressRecognizer)
        
        
        fileManager.delegate = self
        
        if (currentDir == nil) {
            currentDir = documentDir
        }
        
        self.loadFileAtPath(currentDir)
        
    }
    
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
    
    
    func contextMenuHandler(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.began {
            
            let indexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView))
            
            if indexPath != nil {
                
                self.selectedIndexPath = indexPath
                
                let cell = self.collectionView?.cellForItem(at: self.selectedIndexPath!)
                let menu = UIMenuController.shared
                let sendMenuItem = UIMenuItem(title: LocalizedString("delete"), action: #selector(deleteAction))
                menu.setTargetRect(CGRect(x:0,y:5,width:60,height:80), in: (cell?.contentView)!)
                menu.arrowDirection = .down
                
                
                menu.menuItems = [sendMenuItem]
                menu.setMenuVisible(true, animated: true)
            }
        }
    }
    
    func deleteAction() {
        log("deleteAction performed! selectedIndex:\(self.selectedIndexPath)")
        if(self.selectedIndexPath != nil){
            let row = selectedIndexPath!.row
            let file = dataSource[row]
            let filePath : String = self.currentDir.appending("/\(file.name!)")
            do{
                try fileManager.removeItem(atPath: filePath)
                reloadCurPage()
            }catch let err{
                log(err)
            }
        }
        
    }
    
    func runGrok(){}
    
    
    func initViewStyle(){
        var containerTypes = [UIAppearanceContainer.Type]()
        containerTypes.append(VKFileViewController.self)
        if #available(iOS 9.0, *) {
            //let toolBar = UIToolbar.appearance(whenContainedInInstancesOf:containerTypes )
            
            var itemContainerTypes = [UIAppearanceContainer.Type]()
            itemContainerTypes.append(UIToolbar.self)
            itemContainerTypes.append(VKFileViewController.self)
            let toolBarItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: itemContainerTypes)
            toolBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.black ], for: .normal)
            
            
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Click Event
    @IBAction func clickNewFolder(_ sender: AnyObject) {
        
        
        self.showAlertController(LocalizedString("Create New Folder"), LocalizedString("Input Name"), LocalizedString("Cancel"), LocalizedString("Save"), nil , {(action,filename) in
            let fileDir = self.currentDir.appending("/\(filename)")
            let createSuccess = self.createNewFolder(fileDir)
            if(!createSuccess){
                self.showAlertController(LocalizedString("Warning"), LocalizedString("File Already Exist"), LocalizedString("Confirm"), nil, nil, nil)
            }
        })
        
    }
    
    @IBAction func clickSort(_ sender: AnyObject) {
        self .showSortActionSheet()
    }
    
    
    @IBAction func clickSearchBtn(_ sender: Any) {
        let searchVC = VKSearchViewController()
        searchVC.callBack = {(fileURL) in
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                let isDirectory = resourceValues[.isDirectoryKey] as? Bool ,
                let name = resourceValues[.nameKey] as? String ,
                let type = resourceValues[.typeIdentifierKey] as? String
                
                else {
                    return
            }
            
            let fileSize = resourceValues[URLResourceKey.totalFileSizeKey] as? NSNumber
            var fileSizeFloatValue = fileSize?.intValue
            fileSizeFloatValue = fileSizeFloatValue == nil ? 0 : fileSizeFloatValue
            
            let creationDate = resourceValues[.creationDateKey]
            
            let file = VKFile(name,(fileURL.deletingLastPathComponent?.path)!, isDirectory, type,fileSizeFloatValue)
            file.creationDate = creationDate as! NSDate?

            print(file)
            
            self.selectFile(file)

        }
        self.present(searchVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(searchVC, animated: true)
        
    }
    
    
    func showAlertController(_ title : String? , _ message : String? , _ cancelTitlte : String? , _ defaultTitle : String? ,_ cancelHandler:((UIAlertAction) -> Swift.Void)? = nil ,_ defalutHandler: ((UIAlertAction,String) -> Swift.Void)? = nil  ){
        
        let alertController = UIAlertController(title:title, message:message, preferredStyle: .alert)
        
        let alertActionCancel = UIAlertAction(title:cancelTitlte, style: .cancel, handler: {(action) in
            if(cancelHandler != nil){
                cancelHandler!(action)
            }
            
        })
        alertController.addAction(alertActionCancel)
        
        if(defaultTitle != nil){
            
            var nameTf : UITextField!
            alertController.addTextField(configurationHandler: {(tf) in
                nameTf = tf
            })
            
            let alertActionSave = UIAlertAction(title:defaultTitle, style: .default, handler: {(action) in
                let filename : String = nameTf.text!
                defalutHandler!(action,filename)
            })
            alertController.addAction(alertActionSave)
        }
        self.present(alertController, animated: true, completion: {() -> Void in
            
        })
        
    }
    
    
    func showSortActionSheet(){
        
        let alertController = UIAlertController(title:LocalizedString("Sort Type"), message:nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(title:LocalizedString("Cancel"), style: .cancel, handler: {(action) in
            
            
        })
        alertController.addAction(alertActionCancel)
        
        
        let nameAction = UIAlertAction(title: LocalizedString("Name"), style: .default, handler: {(action) in
            self.dataSource.sort(by: {(file1,file2) -> Bool in
                return file1.compare(withOtherFile: file2, bySortType: .name)
            })
            DispatchQueue.main.async {
                self.mTableView.reloadData()
                self.collectionView.reloadData()
            }
            
        })
        alertController.addAction(nameAction)
        
        
        let sizeAction = UIAlertAction(title: LocalizedString("Size"), style: .default, handler: {(action) in
            
            self.dataSource.sort(by: {(file1,file2) -> Bool in
                return file1.compare(withOtherFile: file2, bySortType: .fileSize)
            })
            DispatchQueue.main.async {
                self.mTableView.reloadData()
                self.collectionView.reloadData()
            }
        })
        alertController.addAction(sizeAction)
        
        
        
        let dateAction = UIAlertAction(title: LocalizedString("Date"), style: .default, handler: {(action) in
            self.dataSource.sort(by: {(file1,file2) -> Bool in
                return file1.compare(withOtherFile: file2, bySortType: .creationDate)
            })
            DispatchQueue.main.async {
                self.mTableView.reloadData()
                self.collectionView.reloadData()
            }
            
            
        })
        alertController.addAction(dateAction)
        
        
        let typeAction = UIAlertAction(title: LocalizedString("Type"), style: .default, handler: {(action) in
            
            self.dataSource.sort(by: {(file1,file2) -> Bool in
                return file1.compare(withOtherFile: file2, bySortType: .type)
            })
            DispatchQueue.main.async {
                self.mTableView.reloadData()
                self.collectionView.reloadData()
            }
            
        })
        alertController.addAction(typeAction)
        
        
        self.present(alertController, animated: true, completion: {() -> Void in
            
        })
        
    }
    
    
    func createNewFolder(_ fileDir : String) -> Bool {
        
        let fileExists = self.fileManager.fileExists(atPath: fileDir)
        if fileExists {
            return false
        }
        do{
            try self.fileManager.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
            self.loadFileAtPath(self.currentDir)
        }catch let error{
            print(error)
            return false
        }
        return true
    }
    
    
    func reloadCurPage(){
        self.loadFileAtPath(self.currentDir)
    }
    
    
    
    
    @IBAction func clickIconOrListBtn(_ sender: AnyObject) {
        if bottomIconOrListBarItem.tag == 10 {
            
            bottomIconOrListBarItem.title = NSLocalizedString("Icon", comment: "")
            bottomIconOrListBarItem.tag = 100
            
            collectionView.isHidden = true
            
            
        }else {
            bottomIconOrListBarItem.title = NSLocalizedString("List", comment: "")
            bottomIconOrListBarItem.tag = 10
            collectionView.isHidden = false
        }
        
    }
    
    func getDirContent(_ owner:String,repo:String,path:String = "" ,ref:String = "master"){
        Alamofire.request(URLRouter.getContents(owner: owner/*"Alamofire"*/, repo: repo/*"Alamofire"*/, path: path, ref: ref)).responseJSON { response in
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                
                if let result  = ContentItemModel.mj_objectArray(withKeyValuesArray: json){
                    
                    
                    for item in result{
                        let itemModel = (item as! ContentItemModel)
                        
                        if(itemModel.isFile()){
                            self.downloadContentItem(itemModel)
                        }
                        else{
                            
                            if let itemPath = itemModel.path{
                                print("itemPath:\(itemPath)")
                                self.getDirContent(owner, repo: repo,path:itemPath)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func downloadContentItem(_ itemModel : ContentItemModel){
        let request = Alamofire.download(itemModel.download_url!, to: { temporaryURL, response in
            let directoryURLs = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
            
            if !directoryURLs.isEmpty {
                var pathUrl = directoryURLs[0]
                if let pathComponents = response.url?.pathComponents {
                    for i in 0..<(pathComponents.count-1) {
                        pathUrl = pathUrl.appendingPathComponent(pathComponents[i])
                    }
                    if(!FileManager.default.fileExists(atPath: pathUrl.absoluteString)){
                        do {
                            try FileManager.default.createDirectory(at: pathUrl, withIntermediateDirectories: true, attributes:nil)
                        } catch let error {
                            print(error)
                        }
                    }
                    pathUrl = pathUrl.appendingPathComponent(pathComponents[pathComponents.count-1])
                    
                }
                
                
                return (pathUrl, [])
            }
            
            return (temporaryURL, [])
        })
        request.responseData(completionHandler: {(response) in
            switch response.result{
            case .success(_):
                print("文件下载完毕: \(response)");
                break
                
            case .failure(_): break
                
            }
            
        })
    }
    
    @IBAction func clickGithubBtn(_ sender: Any) {
        
        //getDirContent("Alamofire", repo: "Alamofire")
        
        
        let controller = UIAlertController(title:LocalizedString("Github"),message:LocalizedString("clone repositroy"),preferredStyle:.alert)
        
        controller.addTextField(configurationHandler: {(textField) in
            // textField
            textField.placeholder = LocalizedString("owner")
        })
        controller.addTextField(configurationHandler: {(textField) in
            // textField
            textField.placeholder = LocalizedString("repositroy")
        })
        
        let cloneAction = UIAlertAction(title: LocalizedString("clone"), style: .default, handler: {(action) in
            print(action)
            let textFields = controller.textFields
            let owner = textFields?.first?.text
            let repo = textFields?.last?.text
            
            if((owner?.isEmpty)! || (repo?.isEmpty)!){
                return
            }
            self.getDirContent(owner!, repo: repo!)
            
        })
        
        let cancelAction = UIAlertAction(title: LocalizedString("cancel"), style: .cancel, handler: {(action) in
            
        })
        
        let destructiveAction = UIAlertAction(title: LocalizedString("destructive"), style: .destructive, handler: {(action) in
            
        })
        controller.addAction(cloneAction)
        controller.addAction(cancelAction)
        controller.addAction(destructiveAction)
        
        self.present(controller, animated: true, completion: nil)
        
        
    }
    
    
    
    func selectFile(_ file :VKFile){
        let fileDir : String = file.filePath!.appending("/\(file.name!)")
        
        if file.isDirectory {
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
                    
                    
                    self.navigationController?.pushViewController(browser!, animated: true)
                    
                    return ;
                }
            }
            else if(file.isSourceCodeType()){
                
                let sourceCodeVC = SourceViewController()
                sourceCodeVC.mFile = file
                self.navigationController?.pushViewController(sourceCodeVC, animated: true)
                
                return
            }
            else if(file.name.hasSuffix(".md")){
                let markdownVC = MarkdownViewController()
                markdownVC.mFile = file
                self.navigationController?.pushViewController(markdownVC, animated: true)
                
                return
            }
            
            print("fileDir:\(fileDir) == file.type:\(file.type)")
            
            let nextVc = DocumentPreviewObject(_ : URL(fileURLWithPath: fileDir))
            nextVc.previewVC = self.navigationController
            nextVc.startPreview()
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
    
    func zipArchiveDidUnzipFile(at fileIndex: Int, totalFiles: Int, archivePath: String!, fileInfo: unz_file_info) {
        //        log("zipArchiveDidUnzipFile==  fileIndex:\(fileIndex)  totalFiles:\(totalFiles)  archivePath:\(archivePath)  fileInfo:\(fileInfo)")
    }
    
    
    func zipArchiveDidUnzipArchive(atPath path: String!, zipInfo: unz_global_info, unzippedPath: String!, withFilePaths filePaths: NSMutableArray!) {
        //        log("zipArchiveDidUnzipArchive== path:\(path)  zipInfo:\(zipInfo)  unzippedPath:\(unzippedPath)  filePaths:\(filePaths)")
        reloadCurPage()
    }
    
    
    func zipArchiveWillUnzipArchive(atPath path: String!, zipInfo: unz_global_info) {
        //        log("zipArchiveWillUnzipArchive==   path:\(path)  zipInfo:\(zipInfo)")
    }
    
    func zipArchiveWillUnzipFile(at fileIndex: Int, totalFiles: Int, archivePath: String!, fileInfo: unz_file_info) {
        //        log("zipArchiveWillUnzipFile==   fileIndex:\(fileIndex)  totalFiles:\(totalFiles)  archivePath:\(archivePath)  fileInfo:\(fileInfo)")
    }
    
    func loadFileAtPath(_ path: String){
        dataSource.removeAll()
        
        let directoryEnumerator = fileManager.enumerator(at:URL(fileURLWithPath: path), includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil)!
        
        
        for case let fileURL as NSURL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                let isDirectory = resourceValues[.isDirectoryKey] as? Bool ,
                let name = resourceValues[.nameKey] as? String ,
                let type = resourceValues[.typeIdentifierKey] as? String
                
                else {
                    
                    continue
            }
            
            let fileSize = resourceValues[URLResourceKey.totalFileSizeKey] as? NSNumber
            var fileSizeFloatValue = fileSize?.intValue
            fileSizeFloatValue = fileSizeFloatValue == nil ? 0 : fileSizeFloatValue
            
            let creationDate = resourceValues[.creationDateKey]
            
            let file = VKFile(name,path, isDirectory, type,fileSizeFloatValue)
            file.creationDate = creationDate as! NSDate?
            
            dataSource.append(file)
            
            if(isDirectory){
                directoryEnumerator.skipDescendents()
            }
            
        }
        
        dataSource.sort(by: {(file1,file2) -> Bool in
            return file1.compare(withOtherFile: file2, bySortType: .name)
        })
        print(dataSource)
        currentDir = path
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.mTableView.reloadData()
        }
        
        
    }
    
    
    
    // MARK: UICollectionView  DataSouce And Delegate
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let file = dataSource[indexPath.row]
        
        var imgView : UIImageView? = cell.viewWithTag(1) as! UIImageView?
        
        if(imgView == nil)
        {
            imgView = UIImageView(frame: CGRect(x: 20, y: 15, width: 55, height: 55))
            cell.addSubview(imgView!)
        }
        
        imgView?.tag = 1
        imgView?.image = file.isDirectory ? UIImage(named: "folder") : UIImage(named: "file")
        
        
        if(file.name.contains(".jpg")||file.name.contains(".jp2") ){
            
            imgView?.image = UIImage(contentsOfFile: self.currentDir.appending("/\(file.name!)"))
        }
        
        
        var checkBtn : UIButton? = cell.viewWithTag(10) as! UIButton?
        
        if(checkBtn == nil)
        {
            checkBtn = UIButton(frame: CGRect(x: 60, y: 50, width: 20, height: 20))
            cell.addSubview(checkBtn!)
        }
        
        checkBtn?.setImage(UIImage(named: "uncheck"), for: .normal)
        checkBtn?.setImage(UIImage(named: "check"), for: .selected)
        checkBtn?.tag = 10
        checkBtn?.isHidden = true
        
        
        var label : UILabel? = cell.viewWithTag(100) as! UILabel?
        if(label == nil)
        {
            label = UILabel(frame: CGRect(x: 0, y: 80, width: 95, height: 30))
            label?.font = UIFont.systemFont(ofSize: 12)
            label?.numberOfLines = 0
            label?.adjustsFontSizeToFitWidth = true
            cell.addSubview(label!)
        }
        
        label?.textAlignment = .center
        label?.text = file.name
        label?.tag = 100
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let file = dataSource[indexPath.row]
        selectFile(file)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("destinationIndexPath")
    }
    
    //    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    //
    //        return true
    //    }
    //
    //
    //    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    //        log(action)
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    override var canBecomeFirstResponder: Bool {
        get{
            return true
        }
    }
    
    
    
    // MARK: UITableView  DataSouce And Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataSource.count
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style:.default, reuseIdentifier: reuseIdentifier)
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
        if(action == #selector(deleteAction)){
            return true
        }
        return false
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let file = dataSource[indexPath.row]
        
        selectFile(file)
    }
    
    
}
