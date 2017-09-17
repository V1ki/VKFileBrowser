//
//  AppDelegate.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2016/9/30.
//  Copyright © 2016年 vk. All rights reserved.
//

import UIKit
import CoreData
import GCDWebServer
import SwiftyUserDefaults
import ChameleonFramework
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,GCDWebUploaderDelegate{

    var window: UIWindow?
    var uploader :GCDWebUploader?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        // Override point for customization after application launch.
        
        ///NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        ////_webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
        /// [_webUploader start];
        
//        let webUploader = GCDWebDAVServer(uploadDirectory: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)
//        webUploader?.start()
        
        URLProtocol.registerClass(VKURLProtocol.self)
        
        Chameleon.setGlobalThemeUsingPrimaryColor(.flatSkyBlueDark, with: .contrast)
        
        UIButton.appearanceWhenContained(within: [UITableViewCell.self]).tintColor = .clear
        UIButton.appearanceWhenContained(within: [UITableViewCell.self]).backgroundColor = .clear
        
        RepositoryUtils.initGit()
        
        let reachability = Reachability()
        
        reachability?.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    if(Defaults[.autoStart]){
                        
                        self.uploader = GCDWebUploader(uploadDirectory: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)
                        self.uploader!.start()
                        
                        self.uploader!.delegate = self
                        
                        let str = (self.uploader!.serverURL?.absoluteString)!
                        
                        Defaults[.url] = str
                        
                        Defaults[.port] = Int(self.uploader!.port)
                        
                    }
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability?.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                print("Not reachable")
            }
        }
        
        
        
        return true
    }
    
    func reloadData(){
        
        spiltController.reloadRootData()
    }
    
    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        log("didDeleteItemAtPath",path)
        reloadData()
    }
    
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        log("didUploadFileAtPath",path)
        reloadData()
    }
    
    func webUploader(_ uploader: GCDWebUploader, didDownloadFileAtPath path: String) {
        log("didDownloadFileAtPath",path)
        
        reloadData()
    }
    
    func webUploader(_ uploader: GCDWebUploader, didCreateDirectoryAtPath path: String) {
        log("didCreateDirectoryAtPath",path)
        reloadData()
    }
    
    func webUploader(_ uploader: GCDWebUploader, didMoveItemFromPath fromPath: String, toPath: String) {
        log("didMoveItemFromPath",fromPath,toPath)
        reloadData()
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        log("url:\(url)  options:\(options)  url.lastPathComponent:\(url.lastPathComponent)")
        let documentDir =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        
        do{
        try FileManager.default.copyItem(at: url, to: URL(fileURLWithPath:documentDir.appending("/\(url.lastPathComponent)")))
        }catch let error{
            print(error)
        }
        reloadData()
        return true
        
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        RepositoryUtils.shutdownGit()
    }
    

    
    

}

