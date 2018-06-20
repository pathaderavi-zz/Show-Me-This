//
//  WolframImagesController.swift
//  Show Me This
//
//  Created by Ravikiran Pathade on 6/18/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import UIKit

class WolframImagesController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var currentResult = [String : [(String,String,String)]]()
    var currentKeys = [String]()
    var searchQuery : String!
    
    @IBOutlet weak var resultTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        DispatchQueue.global(qos: .userInitiated).async {
            Requests().fetchImages(self.searchQuery, completionHandler: { [weak self] success,result,keys in
                self?.currentResult = result
                self?.currentKeys = keys
                
                DispatchQueue.main.async {
                    self?.resultTableView.reloadData()
                }
            })
        }
        
    }
    
    // TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentResult[currentKeys[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = currentResult[currentKeys[indexPath.section]]![indexPath.row].2
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentResult.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentKeys[section]
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
