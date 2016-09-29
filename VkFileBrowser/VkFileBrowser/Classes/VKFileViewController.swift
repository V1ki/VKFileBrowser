//
//  VKFileViewController.swift
//  VkFileBrowser
//
//  Created by Vk on 2016/9/26.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit

class VKFileViewController: BaseViewController ,UICollectionViewDataSource,UICollectionViewDelegate {
    
    
    let fileManager = FileManager.default
    let documentDir : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    var currentDir : String!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    var dataSource = [VKFile]()
    
    
    let reuseIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initViewStyle()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.loadFileAtPath(documentDir)
        
        
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
        
        let alertController = UIAlertController(title: NSLocalizedString("Create New Folder", comment: ""), message: NSLocalizedString("Input Name", comment: ""), preferredStyle: .alert)
        var nameTf : UITextField!
        alertController.addTextField(configurationHandler: {(tf) in
            nameTf = tf
        })
        let alertActionCancel = UIAlertAction(title:NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {(action) in
        })
        alertController.addAction(alertActionCancel)
        
        let alertActionSave = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: {(action) in
            let filename : String = nameTf.text!
            let fileDir = self.currentDir.appending("/\(filename)")
            
            do{
                try self.fileManager.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
                self.loadFileAtPath(self.currentDir)
            }catch let error{
                print(error)
            }
        })
        alertController.addAction(alertActionSave)
        self.present(alertController, animated: true, completion: {() -> Void in
            
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
        
        currentDir = documentDir
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        
    }
    
    
    
    // MARK: UICollectionViewDataSouce
    
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
        imgView?.image = file.isDirectory ? #imageLiteral(resourceName: "folder") : #imageLiteral(resourceName: "file")
        
        
        
        var checkBtn : UIButton? = cell.viewWithTag(10) as! UIButton?
        
        if(checkBtn == nil)
        {
            checkBtn = UIButton(frame: CGRect(x: 60, y: 50, width: 20, height: 20))
            cell.addSubview(checkBtn!)
        }
        
        checkBtn?.setImage(UIImage(named:"uncheck"), for: .normal)
        checkBtn?.setImage(UIImage(named:"check"), for: .selected)
        checkBtn?.tag = 10
        checkBtn?.isHidden = true
        
        
        
        
        var label : UILabel? = cell.viewWithTag(100) as! UILabel?
        if(label == nil)
        {
            label = UILabel(frame: CGRect(x: 0, y: 85, width: 95, height: 25 ))
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
        print("didSelect")
    }
    
    
    
    
}
