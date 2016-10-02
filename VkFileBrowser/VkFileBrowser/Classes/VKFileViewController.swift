//
//  VKFileViewController.swift
//  VkFileBrowser
//
//  Created by Vk on 2016/9/26.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit



public func LocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}


class VKFileViewController: BaseViewController ,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate {
    
    
    let fileManager = FileManager.default
    let documentDir : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    var currentDir : String!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var bottomIconOrListBarItem: UIBarButtonItem!
    
    
    var dataSource = [VKFile]()
    
    
    let reuseIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false 
        self.initViewStyle()
        self.setTableExtraHidden()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if (currentDir == nil) {
            currentDir = documentDir
        }
        print(currentDir)
        
        self.title = currentDir.components(separatedBy: "/").last
        
        
        self.loadFileAtPath(currentDir)
    }
    
    
    
    func setTableExtraHidden(){
        let view = UIView()
        view.backgroundColor = UIColor.clear
        mTableView.tableFooterView = view
        
    }
    
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
    

    
    func showAlertController(_ title : String? , _ message : String? , _ cancelTitlte : String? , _ defaultTitle : String? ,_ cancelHandler:((UIAlertAction) -> Swift.Void)? = nil ,_ defalutHandler: ((UIAlertAction,String) -> Swift.Void)? = nil  ){
        
        let alertController = UIAlertController(title:title, message:message, preferredStyle: .alert)

        let alertActionCancel = UIAlertAction(title:cancelTitlte, style: .cancel, handler: {(action) in

                cancelHandler!(action)
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
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    func loadFileAtPath(_ path: String){
        dataSource.removeAll()
        
        
        let resourceKeys = [URLResourceKey.nameKey,URLResourceKey.isDirectoryKey,URLResourceKey.pathKey,URLResourceKey.typeIdentifierKey]
        let directoryEnumerator = fileManager.enumerator(at:URL(fileURLWithPath: path), includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil)!
        
        for case let fileURL as NSURL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                let isDirectory = resourceValues[URLResourceKey.isDirectoryKey] as? Bool ,
                let name = resourceValues[URLResourceKey.nameKey] as? String ,
                let type = resourceValues[URLResourceKey.typeIdentifierKey] as? String
                else {
                    
                    continue
            }
            let file = VKFile(name, isDirectory, type)
            print(name+"\(type)")
            dataSource.append(file)
        }
        
        currentDir = path
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.mTableView.reloadData()
        }
        
        
    }
    
    
    
    // MARK: UICollectionView  DataSouce And Delegate
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.red
        let file = dataSource[indexPath.row]
        
        var imgView : UIImageView? = cell.viewWithTag(1) as! UIImageView?
        
        if(imgView == nil)
        {
            imgView = UIImageView(frame: CGRect(x: 20, y: 15, width: 55, height: 55))
            cell.addSubview(imgView!)
        }
        
        imgView?.tag = 1
        imgView?.image = file.isDirectory ? #imageLiteral(resourceName: "folder") : #imageLiteral(resourceName: "file")
        
        
        
        
        var checkBtn : UIButton? = cell.viewWithTag(10) as! UIButton?
        
        if(checkBtn == nil)
        {
            checkBtn = UIButton(frame: CGRect(x: 60, y: 50, width: 20, height: 20))
            cell.addSubview(checkBtn!)
        }
        
        checkBtn?.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        checkBtn?.setImage(#imageLiteral(resourceName: "check"), for: .selected)
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
        print("numberOfItemsInSection\(collectionView.frame)")
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("numberOfSections")
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let file = dataSource[indexPath.row]
        let fileDir : String = self.currentDir.appending("/\(file.name!)")
        if file.isDirectory {
            let nextVc = VKFileViewController()
            nextVc.currentDir = fileDir
            self.navigationController?.pushViewController(nextVc, animated: true)
        }
        else
        {
            let nextVc = DocumentPreviewObject(_ : URL(fileURLWithPath: fileDir))
            nextVc.previewVC = self.navigationController
            nextVc.startPreview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("destinationIndexPath")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
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
        
        
        cell?.imageView?.image = file.isDirectory ? #imageLiteral(resourceName: "folder") : #imageLiteral(resourceName: "file")
        
        if file.isDirectory {
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let file = dataSource[indexPath.row]
        let fileDir : String = self.currentDir.appending("/\(file.name!)")
        if file.isDirectory {
            let nextVc = VKFileViewController()
            nextVc.currentDir = fileDir
            self.navigationController?.pushViewController(nextVc, animated: true)
        }
        else
        {
            let nextVc = DocumentPreviewObject(_ : URL(fileURLWithPath: fileDir))
            nextVc.previewVC = self.navigationController
            nextVc.startPreview()
        }
        
    }
    
    
}
