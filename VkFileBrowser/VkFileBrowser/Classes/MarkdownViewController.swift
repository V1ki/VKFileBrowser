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
    
    func getSavePathStr(_ url: URL?) -> String {
        
        var pathUrl = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        if let pathComponents = url?.pathComponents {
            for i in 0..<(pathComponents.count-1) {
                pathUrl?.append("/"+pathComponents[i])
            }
            if(!FileManager.default.fileExists(atPath: pathUrl!)){
                do {
                    try FileManager.default.createDirectory(atPath: pathUrl!, withIntermediateDirectories: true, attributes:nil)
                } catch let error {
                    print(error)
                }
            }
            pathUrl?.append("/"+pathComponents[pathComponents.count-1])
            
        }
        
        
        return pathUrl!
        
    }
    
    
    func getSavePath(_ str: String) -> DownloadRequest.DownloadFileDestination {
        return { temporaryURL, response in
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
    
    
    
    func downloadImg(_ imgPath : String , completionHandler:@escaping (Bool) -> Void){

        let savePath = self.getSavePath(imgPath)
        let savePathURL = self.getSavePathStr(URL(string: imgPath))
        print("path:\(savePathURL)  isExist:\(FileManager.default.fileExists(atPath: savePathURL))")
        
        if(!FileManager.default.fileExists(atPath: savePathURL)){
            let request = Alamofire.download(imgPath, to: savePath)
            request.responseData(completionHandler: {(response) in
                switch response.result{
                case .success(_):
                    completionHandler(true)
                    break
                    
                case .failure(_):
                    completionHandler(false)
                    break
                    
                }
            })
        }else{
            completionHandler(true)
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
