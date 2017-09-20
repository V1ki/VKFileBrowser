//
//  WebBrowserController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/11.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import ChameleonFramework
import SnapKit
import SwiftyUserDefaults
import RxSwift
import RxCocoa
import RealmSwift
import RxDataSources
import RxRealm
import RxRealmDataSources
import VBFPopFlatButton
import AMScrollingNavbar

class WebBrowserController: UIViewController {
    
    
    
    var webView: UIWebView = UIWebView()
    
    var jsContext : JSContext?
    
    var consoleTabBar : UITabBar = UITabBar()
    var consoleView : UITextView = {
        var textView = UITextView()
        textView.isEditable = false
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.isSelectable = false
        textView.backgroundColor = .white
        textView.attributedText = NSMutableAttributedString()
        textView.textColor = UIColor(hexString: "#242B33")
        
        return textView
    }()
    
    var urlTextField : UITextField = {
        let textView = UITextField()
        
        return textView
    }()
    
    var elementTextview : UITextView = {
        debugStr("init elementView")
        let textView = UITextView()
        textView.isHidden = true
        textView.isEditable = false
        return textView
    }()
    
    var networkTableview : UITableView = {
        let tbview = UITableView()
        tbview.isHidden = true
        tbview.hideExtraCell()
        tbview.separatorStyle = .none
        return tbview
    }()
    
    
    var networkContentView : UITableView = {
        let tbview = UITableView()
        tbview.isHidden = true
        return tbview
    }()
    
    let realm = try! Realm()
    
    
    
    let dis = DisposeBag()
    
    var selectIp : IndexPath?
    
    
    let disposeBag = DisposeBag()
    
    var backItem : UIBarButtonItem{
        
        get{
            
            let btn = VBFPopFlatButton(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:28,height:28)), buttonType: .buttonBackType, buttonStyle: .buttonRoundedStyle, animateToInitialState: false)
        
            btn?.rx.tap.bind {
                self.webView.goBack()
            }.disposed(by: disposeBag)
            
            return UIBarButtonItem(customView: btn!)
            
        }
    }
    
    var consoleAT : NSMutableAttributedString = NSMutableAttributedString()
    
    
    fileprivate func cellForItem(_ tableView: UITableView, _ item: NetworkItem) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? NetworkItemCell
        
        if cell == nil {
            cell = NetworkItemCell(reuseIdentifier:"Cell")
        }
        cell?.item = item
        return cell!
    }
    
    fileprivate func addSubViews() {
        // MARK: - 添加子控件
        self.view.addSubview(webView)
        self.view.addSubview(consoleView)
        self.view.addSubview(consoleTabBar)
        self.view.addSubview(networkTableview)
        self.view.addSubview(networkContentView)
        self.view.addSubview(elementTextview)
    }
    
    
    fileprivate func initConsoleAndNetView(){
        // MARK: - 初始化Console 和 network view
        var consoleHeight : CGFloat = CGFloat(Defaults[.consoleViewHeight])
        // 设置位置和大小
        consoleTabBar.snp.makeConstraints{ make in
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalTo(consoleView.snp.top)
        }
        
        consoleView.snp.makeConstraints{ make in
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.height.equalTo(consoleHeight)
            make.width.equalToSuperview()
        }
        
        networkTableview.snp.makeConstraints{ make in
            make.top.equalTo(consoleView)
            make.left.equalTo(consoleView)
            make.height.equalTo(consoleView)
            make.width.equalToSuperview()
        }
        
        
        networkContentView.snp.makeConstraints{ make in
            make.right.equalTo(networkTableview)
            make.top.equalTo(consoleView)
            make.bottom.equalTo(consoleView)
            make.width.equalTo(400)
            
            
        }
        consoleView.attributedText = consoleAT
        
        
        // MARK: - 初始化 UITabBar ，并增加拖动手势
        consoleTabBar.barTintColor = .flatSkyBlueDark
        let seg = UISegmentedControl(items: [LocalizedString("Console"),LocalizedString("Network")])
        seg.tintColor = .white
        seg.selectedSegmentIndex = 0
        
        consoleTabBar.addSubview(seg)
        
        seg.snp.makeConstraints{ make in
            make.center.equalTo(self.consoleTabBar)
        }
        
        seg.rx.value.map{ $0 == 0 }.bind(to: self.networkTableview.rx.isHidden).disposed(by: disposeBag)
        
        
        let pangr = UIPanGestureRecognizer()
        consoleTabBar.addGestureRecognizer(pangr)
        
        
        pangr.rx.event.bind{ _ in
            
            if pangr.state == .began {
                consoleHeight = CGFloat(Defaults[.consoleViewHeight])
            }
            let translationPoint = pangr.translation(in: self.consoleTabBar)
            
            let tempHeight = consoleHeight - translationPoint.y
            
            if tempHeight > SCREEN_HEIGHT - self.consoleTabBar.frame.size.height - 64 - 50 {
                return
            }
            else if tempHeight < 50 {
                return
            }
            
            self.consoleView.snp.updateConstraints{ make in
                make.height.equalTo(tempHeight)
            }
            
            if pangr.state == .ended || pangr.state == .cancelled {
                
                Defaults[.consoleViewHeight] = Double(tempHeight)
            }
            
            }.disposed(by: disposeBag)
        
        
        // MARK: - 清除控制台内容按钮
        let delImg = UIImage(named: "delete_icon_normal")
        let clearConsoleBtn = UIButton()
        clearConsoleBtn.setImage(delImg, for: .normal)
        clearConsoleBtn.backgroundColor = .clear
        clearConsoleBtn.setImage(UIImage(named: "delete_icon_pressed"), for: .highlighted)
        
        clearConsoleBtn.rx.tap.bind {
            // clear out
            self.consoleView.clear()
            
            }.disposed(by: disposeBag)
        
        consoleTabBar.addSubview(clearConsoleBtn)
        
        clearConsoleBtn.snp.makeConstraints{ make in
            make.height.equalToSuperview()
            make.width.equalTo(clearConsoleBtn.snp.height)
            make.left.equalTo(0)
            make.top.equalTo(0)
            
        }
        
        // MARK: - 初始化 Network Tableview
        
        self.networkTableview.register(NetworkItemCell.self, forCellReuseIdentifier: "Cell")
        let items = realm.objects(NetworkItem.self)
        
        let dataSource = RxTableViewRealmDataSource<NetworkItem>(cellIdentifier: "Cell"){ dataSource ,tableView,ip,item in
            return self.cellForItem(tableView, item)
        }
        
        let laps = Observable.changeset(from: items)
        
        // bind to table view
        laps
            .bind(to:self.networkTableview.rx.realmChanges(dataSource))
            .addDisposableTo(disposeBag)
        
        
        
        
        let closeBtn = VBFPopFlatButton(frame: CGRect(x:0,y:0,width:28,height:28), buttonType: .buttonCloseType, buttonStyle: .buttonRoundedStyle, animateToInitialState: true)
        closeBtn?.backgroundColor = UIColor.clear
        closeBtn?.tintColor = .white
        closeBtn?.isHidden = true
        closeBtn?.rx.tap.bind {
            self.networkContentView.isHidden = true
            closeBtn?.isHidden = true
            
            self.networkTableview.deselectRow(at: self.selectIp!, animated: true)
            
            }.disposed(by: disposeBag)
        consoleTabBar.addSubview(closeBtn!)
        
        closeBtn!.snp.makeConstraints{ make in
            make.right.equalTo(0)
            make.top.equalTo(11)
            
        }
        
        
        let headerVar = Variable<List<HeaderItem>>(List<HeaderItem>())
        
        
        self.networkTableview.rx.itemSelected.bind { ip in
            self.selectIp = ip
            
            let item = items[ip.row]
            headerVar.value = item.headers
            
            self.networkContentView.isHidden = false
            
            }.disposed(by: disposeBag)
        
        
        headerVar.asObservable().bind(to:  networkContentView.rx.items) {  (tableView, row, element) in
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                cell?.backgroundColor = UIColor.flatSand
            }
            cell?.textLabel?.text = "\(element.key!) : \(element.value!)"
            return cell!
            }.disposed(by: disposeBag)
        
        
        
        // MARK: - 初始化 命令输入栏
        let inputTF = UITextField()
        inputTF.placeholder = LocalizedString("input cmd")
        inputTF.backgroundColor = .clear
        inputTF.textColor = UIColor(hexString: "#242B33") 
        inputTF.autocorrectionType = .no
        inputTF.autocapitalizationType = .none
        self.view.addSubview(inputTF)
        seg.rx.value.map{ $0 == 1 }.bind(to: inputTF.rx.isHidden).disposed(by: disposeBag)
        
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 48) )
        inputTF.inputAccessoryView = bar
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH , height: 48) )
        bar.addSubview(label)
        inputTF.rx.shouldReturn.bind{
            
            let text = inputTF.text
            self.addStrToConsole(str: text!,input:true)
            let result = self.jsContext?.evaluateScript(text)
            self.addStrToConsole(str: result!.description)
            inputTF.clear()
            
            }.disposed(by: disposeBag)
        inputTF.rx.text.bind(to: label.rx.text).disposed(by: disposeBag)
        
        
        inputTF.snp.makeConstraints{ make in
            make.height.equalTo(50)
            make.width.equalToSuperview()
            make.bottom.equalTo(0)
            make.left.equalTo(0)
        }
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow).takeUntil(self.rx.deallocated).subscribe{ value in
//            debugStr("keyboard will show:\(value)")
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardDidShow).takeUntil(self.rx.deallocated).subscribe{ value in
//            debugStr("keyboard did show:\(value)")
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide).takeUntil(self.rx.deallocated).subscribe{ value in
//            debugStr("keyboard will hide:\(value)")
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardDidHide).takeUntil(self.rx.deallocated).subscribe{ value in
//            debugStr("keyboard did hide:\(value)")
        }.disposed(by: disposeBag)
        
        self.consoleTabBar.rx.hidden.bind { bool in 
            
            if bool {
                self.consoleView.snp.updateConstraints{ make in
                    make.height.equalTo(0)
                    make.bottom.equalTo(50)
                }
            }
            else {
                self.consoleView.snp.updateConstraints{ make in
                    make.height.equalTo(CGFloat(Defaults[.consoleViewHeight]))
                    make.bottom.equalTo(0)
                }
            }
            self.consoleView.isHidden = bool
        }.disposed(by: disposeBag)
        
        self.consoleView.rx.hidden.bind(to: inputTF.rx.isHidden).disposed(by: disposeBag)
        
        self.networkTableview.rx.hidden.filter{$0}.bind(to: self.networkContentView.rx.isHidden).disposed(by: disposeBag)
        self.networkContentView.rx.hidden.bind(to: closeBtn!.rx.isHidden).disposed(by: disposeBag)
        
        self.networkTableview.rx.hidden.filter{$0 && (self.selectIp != nil)}.bind{ _ in
            self.networkTableview.deselectRow(at: self.selectIp!, animated: false)
            }.disposed(by: disposeBag)
        
        
        self.consoleTabBar.isHidden = !Defaults[.showConsoleView]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Defaults[.consoleViewHeight] < 50 {
            Defaults[.consoleViewHeight] = 50
        }
        
        
        addSubViews()

        
        initConsoleAndNetView()
        
        
        
        // MARK: -   设置导航栏 titleView
        urlTextField.frame = CGRect(x:0,y:0,width:SCREEN_WIDTH/4,height:40)
        urlTextField.backgroundColor = .flatSkyBlueDark
        urlTextField.textColor = .white
        urlTextField.textAlignment = .center
        urlTextField.keyboardType = .URL
        urlTextField.returnKeyType = .go
        urlTextField.rx.shouldReturn.bind {
            guard let text  = self.urlTextField.text else {
                return
            }
            guard let url = URL(string:text) else{
                self.view.showTips(LocalizedString("Please Check URL"))
                return
            }
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
            
            try! self.realm.write {
                self.realm.deleteAll()
            }

        }.disposed(by: disposeBag)
        
        self.navigationItem.titleView = urlTextField
        
        // MARK: -   设置 导航栏左侧按钮
//        self.navigationItem.leftBarButtonItems = [self.backItem]
        self.navigationItem.leftBarButtonItem = self.backItem
        // KVO 的属性必须要是dynamic 的
        
        // MARK: -  设置导航栏右侧 按钮
        let sourceBtn = UIButton(type: .roundedRect)
        sourceBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        sourceBtn.setTitle(LocalizedString("Source"), for: .normal)
        sourceBtn.layer.borderColor = UIColor.white.cgColor
        sourceBtn.layer.borderWidth = 1
        sourceBtn.setTitleColor(.white, for: .normal)
        sourceBtn.rx.tap.bind {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : PopoverViewController = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as! PopoverViewController
            vc.preferredContentSize = CGSize(width:120, height: 200)
            
            vc.consoleToggleVar.asObservable().distinctUntilChanged().bind{ bool in
                debugStr("bool:\(bool)")
                self.consoleTabBar.isHidden = !bool
                
            }.disposed(by: vc.disposeBag)
            
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sourceBtn
            popover.sourceRect = sourceBtn.bounds
            self.present(vc, animated: true, completion: nil)
            
            
//            if sourceBtn.title(for: .normal) == LocalizedString("Source") {
//                self.elementTextview.isHidden = false
//                sourceBtn.setTitle(LocalizedString("Preview"), for: .normal)
//            }
//            else if sourceBtn.title(for: .normal) == LocalizedString("Preview") {
//                self.elementTextview.isHidden = true
//                sourceBtn.setTitle(LocalizedString("Source"), for: .normal)
//            }
//            
            }.disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sourceBtn)
        
        
        // MARK: - 视图大小及位置
        
        webView.snp.makeConstraints{ make in
            make.top.equalTo(0)
            make.bottom.equalTo(consoleTabBar.snp.top)
            make.left.equalTo(0)
            make.width.equalToSuperview()
        }
        
        elementTextview.snp.makeConstraints{ make in
            
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-64)
        }
        
        // MARK: -  设置 UserAgent
//        UserDefaults.standard.register(defaults: ["UserAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36"])

        // MARK: - 初始化 webview
        let request = URLRequest(url: URL(string:"https://www.baidu.com")! )

        // MARK: - 初始化 JSContext
        if let ctx : JSContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext {
            jsContext = ctx
            
            ctx.exceptionHandler = {context,exec in
                
                guard let exec = exec else {
                    return
                }
                debugStr(exec)
                debugStr(exec.toDictionary())
                
                self.addErrorJSToConsole(errorJS: exec)
               
            }
            
            let logFunction : @convention(block) (String) -> Void =
            {
                (msg: String) in
                self.addStrToConsole(str: msg)
                
            }
            //  设置 console log ，warn ,error
            ctx.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self),
                                                             forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
            ctx.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self),
                                                             forKeyedSubscript: "warn" as NSCopying & NSObjectProtocol)
            ctx.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self),
                                                             forKeyedSubscript: "error" as NSCopying & NSObjectProtocol)
            
        }
        
        webView.loadRequest(request)
        webView.delegate = self
        
        try! realm.write {
            realm.deleteAll()
        }
        
        
        
        
    }
    
    
    func addStrToConsole(str : String,input:Bool = false) {
        
        
            //self.consoleView.scrollRangeToVisible(NSRange(location: self.consoleView.text.count, length: 1))
        
        let text = "\(input ? "> ":"< ")\(str) \n"
        
        let textAt = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:UIColor(hexString: "#242B33")!,NSBackgroundColorAttributeName:UIColor.white])
        
        consoleAT.append(textAt)
        self.consoleView.attributedText = consoleAT
        
    }
    func addErrorJSToConsole(errorJS:JSValue) {
        
        let value = errorJS.toString()
        let dic = errorJS.toDictionary()
        let column  = dic!["column"] ?? 0
        let line = dic!["line"] ?? 0
        let sourceUrl = dic!["sourceURL"]  ?? "<anonymous>"
        // 254 , 236 , 236
        let bgColor = UIColor(hexString: "#FEECEC")!
        // 235,43,52
        let textColor = UIColor(hexString: "#EB2B34")!
        
        let text = " Uncaught \(value!) \n \t at \(sourceUrl) \(line):\(column) \n"
        
        let errorAttributeStr = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:textColor,NSBackgroundColorAttributeName:bgColor])
        
        consoleAT.append(errorAttributeStr)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Enable the navbar scrolling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(webView, delay: 50)
        }
    }
    
}


extension WebBrowserController : UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        try! realm.write {
            realm.deleteAll()
        }
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.urlTextField.text = webView.request?.url?.absoluteString
        self.consoleView.clear()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.urlTextField.text = webView.request?.url?.absoluteString
        
        let html = webView.stringByEvaluatingJavaScript(from: "document.documentElement.innerHTML")
        
        self.elementTextview.text = html
        
        //        DispatchQueue.global().async {
        //            let htmlContent = self.highlightr?.highlight(html!)
        //
        //            DispatchQueue.main.async {
        //                self.elementTextview.attributedText = htmlContent
        //            }
        //        }
        
    }
    
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        debugStr("error:\(error)")
    }
}

extension WebBrowserController:UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
