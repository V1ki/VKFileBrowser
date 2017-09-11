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

class WebBrowserController: UIViewController {
    
    var webView: UIWebView = UIWebView()
    var consoleView : UITextView = UITextView()
    var urlTextField : UITextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(webView)
        self.view.addSubview(consoleView)
        
        consoleView.isEditable = false
        consoleView.backgroundColor = .black
        consoleView.textColor = UIColor.hexColor(0x00F900)
        
        urlTextField.frame = CGRect(x:0,y:0,width:SCREEN_WIDTH/4,height:40)
        urlTextField.backgroundColor = .flatSkyBlueDark
        urlTextField.textColor = .white
        urlTextField.textAlignment = .center
        urlTextField.keyboardType = .URL
        urlTextField.returnKeyType = .go
        urlTextField.delegate = self
        
        consoleView.snp.makeConstraints{ make in
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalTo(200)
        }
        
        
        webView.snp.makeConstraints{ make in
            make.top.equalTo(0)
            make.bottom.equalTo(consoleView.snp.top)
            make.left.equalTo(0)
            make.width.equalToSuperview()
        }
        
        
        
        self.navigationItem.titleView = urlTextField
        
        
        UserDefaults.standard.register(defaults: ["UserAgent":
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36"])
        // Do any additional setup after loading the view.
        let request = URLRequest(url: URL(string:"https://www.baidu.com/")! )
        webView.loadRequest(request)
        
        webView.delegate = self
        
        
   /*
         JSContext *ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
         ctx[@"console"][@"log"] = ^(JSValue * msg) {
         NSLog(@"H5  log : %@", msg);
         };
         ctx[@"console"][@"warn"] = ^(JSValue * msg) {
         NSLog(@"H5  warn : %@", msg);
         };
         ctx[@"console"][@"error"] = ^(JSValue * msg) {
         NSLog(@"H5  error : %@", msg);
         };
         */
        
        if let ctx : JSContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext {
//            ctx.objectForKeyedSubscript("console").objectForKeyedSubscript("log") = { msg in
//                print("log:\(msg)")
//            }
//
            print("ctx:\(ctx)")
            ctx.exceptionHandler = {context,exec in
                print("exec:\(exec)")
            }
//            ctx.setObject(<#T##object: Any!##Any!#>, forKeyedSubscript: "console")

            let logFunction : @convention(block) (String) -> Void =
            {
                (msg: String) in
                
//                print("Console: %@", msg)
//                self.consoleView.text.append(msg)
//                self.consoleView.text.append("\n")
                DispatchQueue.main.async {
                    self.consoleView.text = "\((self.consoleView.text)!)\n\(msg)"
                }
                
            }
            ctx.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self),
                                                             forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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


extension WebBrowserController : UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.urlTextField.text = webView.request?.url?.absoluteString
        self.consoleView.text = ""
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.urlTextField.text = webView.request?.url?.absoluteString
        
    }

}

extension WebBrowserController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text  = textField.text else {
            return false
        }
        guard let url = URL(string:text) else{
            self.view.showTips(LocalizedString("Please Check URL"))
            return false
        }
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        return true
    }
}
