//
//  BaseViewController.swift
//  VkFileBrowser
//
//  Created by Vk on 2016/9/26.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import VBFPopFlatButton
import AMScrollingNavbar
import RxSwift

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    var backItem : UIBarButtonItem = {
        
        let btn = VBFPopFlatButton(frame: CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:28,height:28)), buttonType: .buttonBackType, buttonStyle: .buttonRoundedStyle, animateToInitialState: false)
        
        btn?.addTarget(self, action: #selector(clickBackBtn), for: UIControlEvents.touchUpInside)
        
        
        return UIBarButtonItem(customView: btn!)
    }()
    
    func clickBackBtn(){
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension UIViewController{
    
    func detailViewController() -> UIViewController? {
        if(splitViewController == nil){
            return nil
        }
        if(IS_PAD){
            if(splitViewController?.viewControllers.count == 2){
                return splitViewController?.viewControllers.last
            }else{
                return splitViewController?.viewControllers.first
            }
        }
        else if(IS_PHONE){
            return splitViewController?.viewControllers.first
        }
        
        return nil
    }
    func pushDetailViewController(_ vc: UIViewController, sender: Any?){
        let detailVC = detailViewController()
        print(splitViewController?.viewControllers.last)
        if(detailVC != nil && detailVC is UINavigationController ){
            (detailVC as! UINavigationController).popToRootViewController(animated: true)
            
            (detailVC as! UINavigationController).pushViewController(vc, animated: true)
        } else {
            self.showDetailViewController(vc, sender: sender)
        }
    }
    
    func showAlertController(_ title : String? , _ message : String? , _ cancelTitlte : String? , _ defaultTitle : String? ,_ cancelHandler:((UIAlertAction) -> Swift.Void)? = nil ,_ defalutHandler: ((UIAlertAction,String) -> Swift.Void)? = nil  ){
        
        let alertController = UIAlertController(title:title, message:message, preferredStyle: .alert)
        
        let alertActionCancel = UIAlertAction(title:cancelTitlte, style: .cancel, handler: {(action) in
            if(cancelHandler != nil){
                cancelHandler!(action)
            }
            
        })
        alertController.addAction(alertActionCancel)
        
        
        alertController.addTextField(configurationHandler: {(tf) in
            
        })
        
        if(defaultTitle != nil){
            
            let alertActionSave = UIAlertAction(title:defaultTitle, style: .default, handler: {(action) in
                let filename : String = (alertController.textFields!.last?.text!)!
                if(defalutHandler != nil){
                    defalutHandler!(action,filename)
                }
                
            })
            alertController.addAction(alertActionSave)
        }
        

        
        self.present(alertController, animated: true, completion: {() -> Void in
            
        })
        
    }
    
}
