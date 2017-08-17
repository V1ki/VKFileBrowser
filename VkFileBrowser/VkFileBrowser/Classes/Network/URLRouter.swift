//
//  URLRouter.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/4.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation
import Alamofire
import Foundation

public enum Method: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

public enum Order : String {
    case desc,asc
}

public enum Sort : String {
    case stars, forks, updated
}
enum URLRouter: URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        var pathStr: String!
        var params: [String: AnyObject]?
        var method: Method? = .GET
        
        switch self {
        case .searchUser(let page, let q, let sort):
            pathStr = "search/users?q=\(q)&sort=\(sort)&page=\(page)"
        case .userDetail(let name):
            pathStr = "users/\(name)"
        case .userRepos(let page, let name):
            pathStr = "users/\(name)/repos?sort=updated&page=\(page)"
        case .userFollowers(let page, let name):
            pathStr = "users/\(name)/followers?page=\(page)"
        case .userFollowing(let page, let name):
            pathStr = "users/\(name)/following?page=\(page)"
        case .searchRepos(let page, let q, let sort):
            pathStr = "search/repositories?q=\(q)&sort=\(sort)&page=\(page)"
        case .getRateLimite():
            pathStr = "rate_limit"
        case .getContents(let owner,let repo,let path,var ref):
            if(ref.characters.count == 0){
                ref = "master"
            }
            pathStr = "repos/\(URLEncoding.default.escape(owner))/\(URLEncoding.default.escape(repo))/contents/\(URLEncoding.default.escape(path))?ref=\(URLEncoding.default.escape(ref))"
            
        
        }
        
        let baseURL = "https://api.github.com/"
        let urlStr = baseURL + pathStr
        
        let url = URL(string: urlStr)
        log("urlStr:\(urlStr) -- url:\(url)")
        var request = URLRequest(url: url!)
        
        
        request.httpMethod = method!.rawValue
        
        
        do {
            let tt = try URLEncoding.default.encode(request, with: params)
            return tt
        } catch let error {
            log(error)
        }
        
        
        return request
    }
    
    
    case searchUser(page: Int, q: String, sort: String)
    case userDetail(name: String)
    
    case userRepos(page: Int, name: String)
    case userFollowing(page: Int, name: String)
    case userFollowers(page: Int, name: String)
    case getRateLimite()
    case searchRepos(page: Int, q: String, sort: String)
    
    case getContents(owner:String,repo:String,path:String ,ref:String)
    
}
