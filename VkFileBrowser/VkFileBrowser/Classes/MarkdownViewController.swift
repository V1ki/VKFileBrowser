//
//  MarkdownViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/10.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Alamofire

class MarkdownViewController: BaseViewController {
    
    @IBOutlet weak var sourceTV: UITextView!
    
    var filePath:String!
    
    var mFile:VKFile!{
        
        didSet{
            filePath = "\(mFile.filePath!)/\(mFile.name!)"
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        DispatchQueue.global().async{
            
            let content = self.mFile.readContent()
            
            
            let aStr = NSMutableAttributedString()
            content.enumerateLines(invoking: {(line,flag) in
                let attributedLine = NSMutableAttributedString(string: line+"\n")
                
                //  图片。 行内式
                //![Alt text](/path/to/img.jpg "Optional title")
                
                
                
                //  图片。 参考式
                //  ![Alt text][id]
                //[id]: url/to/image  "Optional title attribute"
                
                
                aStr.append(attributedLine)
            })
            
            DispatchQueue.main.async {
                self.sourceTV.attributedText = aStr
            }
            
            
        }
        
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
