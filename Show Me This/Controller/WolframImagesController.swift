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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var searchQuery : String!
    var imageCache = NSCache<AnyObject,AnyObject>()

    @IBOutlet weak var resultTableView: UITableView!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.rowHeight = UITableViewAutomaticDimension
        resultTableView.estimatedRowHeight = view.frame.height
        resultTableView.decelerationRate = 0.2
        resultTableView.separatorStyle = .singleLine
        resultTableView.separatorColor = UIColor.black
        self.title = searchQuery

        
        DispatchQueue.global(qos: .userInitiated).async {
            Requests().fetchImages(self.searchQuery, completionHandler: { [weak self] success,result,keys in
                self?.currentResult = result
                self?.currentKeys = keys
                
                DispatchQueue.main.async {
                    self?.resultTableView.reloadData()
                    self?.loadingIndicator.stopAnimating()
                }
            })
        }
        
    }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentResult[currentKeys[section]]?.count)!
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let _ = resultTableView.indexPathsForVisibleRows?.last {
            let url = currentResult[currentKeys[(resultTableView.indexPathsForVisibleRows?.last?.section)!]]![(resultTableView.indexPathsForVisibleRows?.last?.row)!].1
            if let cell = resultTableView.visibleCells.last as? CustomCell {
                if cell.customCellImageView.image == nil {
                    resultTableView.reloadRows(at: [(resultTableView.indexPathsForVisibleRows?.last)!], with: .none)
                }
            }
            
            if let _ = imageCache.object(forKey: url as AnyObject){
                //print(resultTableView.indexPathsForVisibleRows?.last)
            }else {
                
                resultTableView.beginUpdates()
                
                resultTableView.reloadRows(at: resultTableView.indexPathsForVisibleRows!, with: .automatic)
                
                resultTableView.endUpdates()
            }
        }
        //}
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let _ = resultTableView.indexPathsForVisibleRows?.last {
            let url = currentResult[currentKeys[(resultTableView.indexPathsForVisibleRows?.last?.section)!]]![(resultTableView.indexPathsForVisibleRows?.last?.row)!].1
            
            if let _ = imageCache.object(forKey: url as AnyObject){
                resultTableView.isScrollEnabled = true
            }else {
                resultTableView.isScrollEnabled = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 20)
        headerView.backgroundColor = UIColor(displayP3Red: 242/255, green: 244/255, blue: 247/255, alpha: 1)
        let buttonS = UIButton(frame: CGRect(x: view.frame.width - 50, y: 0, width: 50, height: 20))
        
        buttonS.setTitle("SAVE", for: .normal)
        
        buttonS.setTitleColor(UIColor.black, for: .normal)
        buttonS.tag = section
        buttonS.addTarget(self, action: #selector(check), for: .touchUpInside)
        
        let titleLable = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 50, height: 20))
        titleLable.text = currentKeys[section]
        titleLable.textColor = UIColor.black
        headerView.addSubview(titleLable)
        headerView.addSubview(buttonS)
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.black.cgColor
    
        titleLable.center.y = headerView.center.y
        buttonS.center.y = headerView.center.y
        return headerView
    }
    @IBAction func check(_ sender:UIButton){
        print(sender.tag)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
        cell.customCellImageView.alpha = 0
        cell.isUserInteractionEnabled = false
        let url = currentResult[currentKeys[indexPath.section]]![indexPath.row].1
        if let image = imageCache.object(forKey: url as AnyObject){
            cell.customCellImageView?.image = UIImage(data: image as! Data)
            cell.customCellImageView.alpha = 1
            cell.textDetails.alpha = 0
            tableView.isScrollEnabled = true
            if (cell.customCellImageView.image?.size.width)! > cell.frame.width {
                print(indexPath)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }else{
            
            cell.customCellImageView.image = nil
            DispatchQueue.global(qos: .userInitiated).async {
                Requests().fetchImage(url, completionHandler: { [weak self] (success, imageData) in
                    if success {
                        DispatchQueue.main.async {
                            cell.customCellImageView.alpha = 1
                            cell.textDetails.alpha = 0
                            cell.customCellImageView.image = UIImage(data: imageData)
                            
                            
                            self?.imageCache.setObject(imageData as AnyObject, forKey: url as AnyObject)
                            
                            if cell.customCellImageView.frame.width > cell.frame.width {
                                
                                
                                if tableView.cellForRow(at: indexPath) == tableView.visibleCells.last {
                                    tableView.beginUpdates()
                                    
                                    tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .automatic)
                                    
                                    tableView.endUpdates()
                                }
                                
                            }
                            
                        }
                    }else{
                        
                        cell.customCellImageView.alpha = 0
                        cell.textDetails.alpha = 1
                        cell.textDetails.text = self?.currentResult[(self?.currentKeys[indexPath.section])!]![indexPath.row].2
                    }
                })
            }
            
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentResult.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentKeys[section]
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        // sleep(1/5)
        if resultTableView != nil {
            if resultTableView.hasUncommittedUpdates{
                resultTableView.endUpdates()
            }
        }
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
