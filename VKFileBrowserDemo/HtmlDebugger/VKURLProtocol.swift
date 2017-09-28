//
//  VKURLProtocol.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/9/11.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

let URLProtocolHandledKey = "URLProtocolHandledKey"

class VKURLProtocol: URLProtocol {

    //URLSession数据请求任务
    var dataTask:URLSessionDataTask?
    
    var session : URLSession?
    
    /*!
     @method canInitWithRequest:
     @abstract This method determines whether this protocol can handle
     the given request.
     @discussion A concrete subclass should inspect the given request and
     determine whether or not the implementation can perform a load with
     that request. This is an abstract method. Sublasses must provide an
     implementation.
     @param request A request to inspect.
     @result YES if the protocol can handle the given request, NO if not.
     */
    open override class func canInit(with request: URLRequest) -> Bool {

        //对于已处理过的请求则跳过，避免无限循环标签问题
//        print("request:\(request) ")
        if let value = URLProtocol.property(forKey: URLProtocolHandledKey, in: request) {
            return false
        }
        
        return true
    }

    /*!
     @method canonicalRequestForRequest:
     @abstract This method returns a canonical version of the given
     request.
     @discussion It is up to each concrete protocol implementation to
     define what "canonical" means. However, a protocol should
     guarantee that the same input request always yields the same
     canonical form. Special consideration should be given when
     implementing this method since the canonical form of a request is
     used to look up objects in the URL cache, a process which performs
     equality checks between NSURLRequest objects.
     <p>
     This is an abstract method; sublasses must provide an
     implementation.
     @param request A request to make canonical.
     @result The canonical form of the given request.
     */
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    /*!
     @method requestIsCacheEquivalent:toRequest:
     @abstract Compares two requests for equivalence with regard to caching.
     @discussion Requests are considered euqivalent for cache purposes
     if and only if they would be handled by the same protocol AND that
     protocol declares them equivalent after performing
     implementation-specific checks.
     @result YES if the two requests are cache-equivalent, NO otherwise.
     */
    open override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool{
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    
    override func startLoading() {
        
        let mutableRequest = (self.request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty("done", forKey: URLProtocolHandledKey, in: mutableRequest )
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        
        
        //使用URLSession从网络获取数据
        self.dataTask = session!.dataTask(with: self.request)
//        print("---------")
//        for (key,value) in (dataTask?.currentRequest?.allHTTPHeaderFields)! {
//            print("\(key) : \(value)")
//        }
//        print("---------")
        self.dataTask!.resume()
    }
    
    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
}

extension VKURLProtocol : URLSessionDataDelegate {
    

    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        if let httpResp = response as? HTTPURLResponse {

            //使用默认的数据库
            let realm = try! Realm()
            //查询所有的network 请求
//            let items = realm.objects(NetworkItem.self)
            
            let item = NetworkItem()
            item.url = httpResp.url?.relativeString ?? ""
            item.status = httpResp.statusCode
            item.size = (httpResp.allHeaderFields["Content-Length"] as? Int) ?? 0
            
            for (key,value) in httpResp.allHeaderFields {
                let header = HeaderItem()
                header.key = key as? String
                header.value = value as? String
                item.headers.append(header)
            }
            
            
            // 数据持久化操作（类型记录也会自动添加的）

            try! realm.write {
                realm.add(item)
            }
        }

        
        
        self.client?.urlProtocol(self, didReceive: response,
                                 cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
        
        guard let urlStr = dataTask.originalRequest?.url?.absoluteString else {
            return
        }
        
        //使用默认的数据库
        let realm = try! Realm()
        //查询所有的network 请求
        let items = (realm.objects(NetworkItem.self).filter{ $0.url == urlStr })
        guard let item = items.first else{
            return
        }
        
        try! realm.write {
            item.data = data as NSData
        }
        
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("didBecomeInvalidWithError - error:\(error)")
    }
    
    
    
}
extension VKURLProtocol : URLSessionTaskDelegate {
    //URLSessionTaskDelegate相关的代理方法
    func urlSession(_ session: URLSession, task: URLSessionTask
        , didCompleteWithError error: Error?) {
        if error != nil {
            self.client?.urlProtocol(self, didFailWithError: error!)
        } else {
            //保存获取到的请求响应数据
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
}
