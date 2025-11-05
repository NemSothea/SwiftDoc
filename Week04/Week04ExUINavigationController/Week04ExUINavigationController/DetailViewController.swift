//
//  DetailViewController.swift
//  Week04ExUINavigationController
//
//  Created by sothea007 on 5/11/25.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var lableTitle: UILabel!
    var selectedPost: Posts?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let post = selectedPost {
            // Use the post data to update your UI
            lableTitle.text = post.title
            
        }
    }
    
    @IBAction func Dimiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
