//
//  DocumentPreviewObject.swift
//  VKFileBrowser
//
//  Created by Vk on 2016/10/1.
//  Copyright © 2016年 vk. All rights reserved.
//

import UIKit

class DocumentPreviewObject : NSObject ,UIDocumentInteractionControllerDelegate {
    var url : URL?
    var document : UIDocumentInteractionController?
    var previewVC : UINavigationController?
    
    init(_ url: URL) {
        super.init()
        self.url = url
        document = UIDocumentInteractionController(url:url)
        document?.delegate = self
    }
    
    
    func startPreview(){
        document?.presentPreview(animated:true)
    }
    
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return previewVC!
    }

    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        print("end Preview")
        previewVC!.popViewController(animated: true)
        
    }
    
    
}
