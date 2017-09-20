//
//  RepositoryModel.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/4.
//  Copyright © 2017年 vk. All rights reserved.
//

import Foundation

class RepositoryModel : BaseModel {
    
    
    
    override var description: String{
        get{
            return "contents_url:\(contents_url)"
        }
    }
    
    var contents_url : String? // {+path}
    
//    var clone_url : String?
//    var contributors_url : String?
//    var created_at : String?
//    var default_branch : String?
//    var deployments_url : String?
//    //var description : String?
//    var downloads_url : String?
//    var events_url : String?
//    var fork : NSNumber?
//    var forks : NSNumber?
//    var forks_url : String?
//    var full_name : String?
//    var git_url : String?
    
    
    /**
     
     {
     "archive_url" = "https://api.github.com/repos/Alamofire/Alamofire/{archive_format}{/ref}";
     "assignees_url" = "https://api.github.com/repos/Alamofire/Alamofire/assignees{/user}";
     "blobs_url" = "https://api.github.com/repos/Alamofire/Alamofire/git/blobs{/sha}";
     "branches_url" = "https://api.github.com/repos/Alamofire/Alamofire/branches{/branch}";
     "clone_url" = "https://github.com/Alamofire/Alamofire.git";
     "collaborators_url" = "https://api.github.com/repos/Alamofire/Alamofire/collaborators{/collaborator}";
     "comments_url" = "https://api.github.com/repos/Alamofire/Alamofire/comments{/number}";
     "commits_url" = "https://api.github.com/repos/Alamofire/Alamofire/commits{/sha}";
     "compare_url" = "https://api.github.com/repos/Alamofire/Alamofire/compare/{base}...{head}";
     "contents_url" = "https://api.github.com/repos/Alamofire/Alamofire/contents/{+path}";
     "contributors_url" = "https://api.github.com/repos/Alamofire/Alamofire/contributors";
     "created_at" = "2014-07-31T05:56:19Z";
     "default_branch" = master;
     "deployments_url" = "https://api.github.com/repos/Alamofire/Alamofire/deployments";
     description = "Elegant HTTP Networking in Swift";
     "downloads_url" = "https://api.github.com/repos/Alamofire/Alamofire/downloads";
     "events_url" = "https://api.github.com/repos/Alamofire/Alamofire/events";
     fork = 0;
     forks = 4282;
     "forks_count" = 4282;
     "forks_url" = "https://api.github.com/repos/Alamofire/Alamofire/forks";
     "full_name" = "Alamofire/Alamofire";
     "git_commits_url" = "https://api.github.com/repos/Alamofire/Alamofire/git/commits{/sha}";
     "git_refs_url" = "https://api.github.com/repos/Alamofire/Alamofire/git/refs{/sha}";
     "git_tags_url" = "https://api.github.com/repos/Alamofire/Alamofire/git/tags{/sha}";
     "git_url" = "git://github.com/Alamofire/Alamofire.git";
     "has_downloads" = 1;
     "has_issues" = 1;
     "has_pages" = 0;
     "has_projects" = 1;
     "has_wiki" = 0;
     homepage = "";
     "hooks_url" = "https://api.github.com/repos/Alamofire/Alamofire/hooks";
     "html_url" = "https://github.com/Alamofire/Alamofire";
     id = 22458259;
     "issue_comment_url" = "https://api.github.com/repos/Alamofire/Alamofire/issues/comments{/number}";
     "issue_events_url" = "https://api.github.com/repos/Alamofire/Alamofire/issues/events{/number}";
     "issues_url" = "https://api.github.com/repos/Alamofire/Alamofire/issues{/number}";
     "keys_url" = "https://api.github.com/repos/Alamofire/Alamofire/keys{/key_id}";
     "labels_url" = "https://api.github.com/repos/Alamofire/Alamofire/labels{/name}";
     language = Swift;
     "languages_url" = "https://api.github.com/repos/Alamofire/Alamofire/languages";
     "merges_url" = "https://api.github.com/repos/Alamofire/Alamofire/merges";
     "milestones_url" = "https://api.github.com/repos/Alamofire/Alamofire/milestones{/number}";
     "mirror_url" = "<null>";
     name = Alamofire;
     "network_count" = 4282;
     "notifications_url" = "https://api.github.com/repos/Alamofire/Alamofire/notifications{?since,all,participating}";
     "open_issues" = 15;
     "open_issues_count" = 15;
     organization =     {
     "avatar_url" = "https://avatars3.githubusercontent.com/u/7774181?v=4";
     "events_url" = "https://api.github.com/users/Alamofire/events{/privacy}";
     "followers_url" = "https://api.github.com/users/Alamofire/followers";
     "following_url" = "https://api.github.com/users/Alamofire/following{/other_user}";
     "gists_url" = "https://api.github.com/users/Alamofire/gists{/gist_id}";
     "gravatar_id" = "";
     "html_url" = "https://github.com/Alamofire";
     id = 7774181;
     login = Alamofire;
     "organizations_url" = "https://api.github.com/users/Alamofire/orgs";
     "received_events_url" = "https://api.github.com/users/Alamofire/received_events";
     "repos_url" = "https://api.github.com/users/Alamofire/repos";
     "site_admin" = 0;
     "starred_url" = "https://api.github.com/users/Alamofire/starred{/owner}{/repo}";
     "subscriptions_url" = "https://api.github.com/users/Alamofire/subscriptions";
     type = Organization;
     url = "https://api.github.com/users/Alamofire";
     };
     owner =     {
     "avatar_url" = "https://avatars3.githubusercontent.com/u/7774181?v=4";
     "events_url" = "https://api.github.com/users/Alamofire/events{/privacy}";
     "followers_url" = "https://api.github.com/users/Alamofire/followers";
     "following_url" = "https://api.github.com/users/Alamofire/following{/other_user}";
     "gists_url" = "https://api.github.com/users/Alamofire/gists{/gist_id}";
     "gravatar_id" = "";
     "html_url" = "https://github.com/Alamofire";
     id = 7774181;
     login = Alamofire;
     "organizations_url" = "https://api.github.com/users/Alamofire/orgs";
     "received_events_url" = "https://api.github.com/users/Alamofire/received_events";
     "repos_url" = "https://api.github.com/users/Alamofire/repos";
     "site_admin" = 0;
     "starred_url" = "https://api.github.com/users/Alamofire/starred{/owner}{/repo}";
     "subscriptions_url" = "https://api.github.com/users/Alamofire/subscriptions";
     type = Organization;
     url = "https://api.github.com/users/Alamofire";
     };
     private = 0;
     "pulls_url" = "https://api.github.com/repos/Alamofire/Alamofire/pulls{/number}";
     "pushed_at" = "2017-07-23T07:26:47Z";
     "releases_url" = "https://api.github.com/repos/Alamofire/Alamofire/releases{/id}";
     size = 2815;
     "ssh_url" = "git@github.com:Alamofire/Alamofire.git";
     "stargazers_count" = 24668;
     "stargazers_url" = "https://api.github.com/repos/Alamofire/Alamofire/stargazers";
     "statuses_url" = "https://api.github.com/repos/Alamofire/Alamofire/statuses/{sha}";
     "subscribers_count" = 1058;
     "subscribers_url" = "https://api.github.com/repos/Alamofire/Alamofire/subscribers";
     "subscription_url" = "https://api.github.com/repos/Alamofire/Alamofire/subscription";
     "svn_url" = "https://github.com/Alamofire/Alamofire";
     "tags_url" = "https://api.github.com/repos/Alamofire/Alamofire/tags";
     "teams_url" = "https://api.github.com/repos/Alamofire/Alamofire/teams";
     "trees_url" = "https://api.github.com/repos/Alamofire/Alamofire/git/trees{/sha}";
     "updated_at" = "2017-08-04T13:35:43Z";
     url = "https://api.github.com/repos/Alamofire/Alamofire";
     watchers = 24668;
     "watchers_count" = 24668;
     }
     
     
 */
    
}
