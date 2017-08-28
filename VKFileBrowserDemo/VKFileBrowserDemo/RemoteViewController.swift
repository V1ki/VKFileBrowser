//
//  RemoteViewController.swift
//  VKFileBrowserDemo
//
//  Created by Vk on 2017/8/23.
//  Copyright © 2017年 vk. All rights reserved.
//

import UIKit

let strs = ["Fetch","Merge","Push"]


class RemoteViewController: BaseViewController {

    @IBOutlet weak var mTableView: UITableView!
    var repo:Repository?
    var remote:Remote?
    
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

extension RemoteViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if(cell == nil){
            cell = UITableViewCell(style: .default, reuseIdentifier: "CELL")
            
        }
        cell?.textLabel?.text = strs[indexPath.row]
        
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    
}

extension RemoteViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            RepositoryUtils.fetchRemote(repo!)
        }
    }
    
}
