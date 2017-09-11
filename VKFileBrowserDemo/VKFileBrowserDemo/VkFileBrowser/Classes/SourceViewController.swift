//
//  SourceViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/2.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Highlightr
//import RxSwift
import RxCocoa
import SnapKit
import ChameleonFramework

class SourceViewController: BaseViewController{
    
    var sourceTV: VKTextView = VKTextView()
    var bottomBar : UITabBar = UITabBar()
//    var diffView : VKDiffView = VKDiffView()
    
    var repo : Repository? 
    var commits : [Commit] = [Commit]()
    
    var saveItem : UIBarButtonItem = UIBarButtonItem()
    
    
    let highlightr = Highlightr()
    
    var filePath:String!
    
    
    
    var mFile:VKFile!{
        
        didSet{
            filePath = "\(mFile.filePath!)/\(mFile.name!)"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(sourceTV)
//        self.view.addSubview(diffView)
//        self.view.addSubview(bottomBar)
        
        
        
        let contentItem = UITabBarItem(tabBarSystemItem: .downloads , tag: 1)
        let changeItem = UITabBarItem(tabBarSystemItem: .featured, tag: 2)
        
        bottomBar.delegate = self
        bottomBar.setItems([contentItem,changeItem], animated: true)
        bottomBar.tintColor = .black
//
//        bottomBar.snp.makeConstraints{ make in
//            make.bottom.equalTo(0)
//            make.left.equalTo(0)
//            make.width.equalTo(self.view)
//            make.height.equalTo(50)
//        }

        sourceTV.snp.makeConstraints{ make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
        }
        
//
//        diffView.snp.makeConstraints{ make in
//            make.top.equalTo(64)
//            make.left.equalTo(0)
//            make.width.equalTo(self.view)
//            make.height.equalTo(self.view).offset(-50)
//        }
        
//        sourceTV.frame = CGRect(x: 0, y: 0, width: self.view.width , height: self.view.snp.height)

        sourceTV.delegate = self
        sourceTV.isEditable = true
//        navigationItem.leftBarButtonItems?.append((self.splitViewController?.displayModeButtonItem)!)
//        sourceTV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTextView)))
        self.title = mFile.name
        
        let saveBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        
        saveBtn.addTarget(self, action: #selector(clickSaveBtn(_:)), for: .touchUpInside)
        saveBtn.setTitle(LocalizedString("save"), for: .normal)
        saveBtn.setTitleColor(saveBtn.tintColor, for: .normal)
        
        saveItem = UIBarButtonItem(customView: saveBtn)
//        self.navigationItem.rightBarButtonItem = saveItem

//        self.navigationItem.leftBarButtonItems?.append((self.splitViewController?.displayModeButtonItem)!)
        
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        DispatchQueue.global().async{
            let startDate = Date()
            
            let content = self.mFile.readContent()
            
            if(self.mFile.isXcodeFileType()){
                
                self.highlightr?.setTheme(to: "xcode")
                
                DispatchQueue.main.async {
                    self.sourceTV.backgroundColor = UIColor.white
                }
            }
            
            // You can omit the second parameter to use automatic language detection.
            let highlightedCode = self.highlightr?.highlight(content)
//            let endDate = Date()
//            let interval = endDate.timeIntervalSince(startDate)
            
//            let bStr = HighlightJS().paint(code: content)
            
//            log("interval:\(interval)")
            
            DispatchQueue.main.async {
                self.sourceTV.attributedText = highlightedCode
//                self.diffView.beforeView.attributedText = highlightedCode
                //                self.sourceTV.backgroundColor = UIColor.hexColor(0x1F2029)
                SVProgressHUD.dismiss()
            }
            
            if let repo = self.repo {
                if let gitPath = self.mFile.gitpath(repo) {
                    self.commits = repo.log(gitPath)
                }
                
            }

        }
        
        
        
        
    }
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func clickSaveBtn(_ sender:Any){
        
        let sourceCode = sourceTV.text
        
        try? sourceCode?.write(to: mFile.toFileURL(), atomically: true, encoding: .utf8)
        
        sourceTV.resignFirstResponder()
    }
    
    
    func tapTextView(_ gr:UITapGestureRecognizer){
        let content = sourceTV.text
        let touchPosition = gr.location(in: sourceTV)
        let textRange = sourceTV.characterRange(at: touchPosition)!
        
        //起始位置
//        let startPosition = textRange.start
        
        //结束位置
        let endPosition = textRange.end
        
//        let startOffset = sourceTV.offset(from: sourceTV.beginningOfDocument, to:startPosition)
        let endOfsset = sourceTV.offset(from: sourceTV.beginningOfDocument, to: endPosition)
        
        let startStrRange = (content?.startIndex)! ..< (content?.index((content?.startIndex)!, offsetBy: endOfsset))!
        
        let endStrRange = (content?.index((content?.startIndex)!, offsetBy: endOfsset))! ..< (content?.endIndex)!
        
        let startBrRange = content?.range(of: "\n", options: .backwards, range: startStrRange, locale: nil)
        let endBrRange = content?.range(of: "\n", options: .caseInsensitive, range: endStrRange, locale: nil)
        
        //得到点击的行的内容
        let line = content?.substring(with: (startBrRange?.upperBound)!..<(endBrRange?.lowerBound)!)
        
        log("line:\(line)")
        
        // 找到 需要处理的行 的内容之后，判断 是否需要跳转，怎么跳转。
        
    }

    
    
}

extension SourceViewController : UITextViewDelegate {
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        log("textViewDidBeginEditing:\(self.navigationItem.rightBarButtonItems)")
        if(self.navigationItem.rightBarButtonItems == nil) {
            self.navigationItem.rightBarButtonItems = []
        }
        self.navigationItem.rightBarButtonItems?.append(saveItem)
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        log("textViewDidEndEditing")
        let index = self.navigationItem.rightBarButtonItems?.index(of: saveItem)
        self.navigationItem.rightBarButtonItems?.remove(at: index!)
        
        let highlightedCode = self.highlightr?.highlight(textView.text)
        textView.attributedText = highlightedCode
    }
    
    func textViewDidChange(_ textView: UITextView) {

    }
    
}


extension SourceViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension SourceViewController : UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.tag == 1 {
//            diffView.isHidden = true
        }
        else if item.tag == 2 {
//            diffView.isHidden = false
        }
        
    }
}
