//
//  ViewController.swift
//  DemoTest01
//
//  Created by sothea007 on 8/12/25.
//

import UIKit

class DemoViewTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    

    @IBOutlet weak var tableView        : UITableView!
    
    let numberOfRow = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 120.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewDemo01Cell {
            
            cell.TitleLable.text = "\(indexPath.row)"
            
         
            
            if indexPath.row == 0 {
                cell.imageViewDemo.image = UIImage(named: "appstore")
            }else if indexPath.row == 1 {
                cell.imageViewDemo.image = UIImage(named: "appstore2")
            }else {
                cell.imageViewDemo.image = nil
            }
           
            
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }


}




