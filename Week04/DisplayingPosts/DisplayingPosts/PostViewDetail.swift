//
//  PostViewDetail.swift
//  DisplayingPosts
//
//  Created by sothea007 on 22/12/25.
//

import UIKit

class PostViewDetail: UIViewController {
    
    var selectedPost : Post?

    @IBOutlet weak var userlbID: UILabel!
    @IBOutlet weak var userlbDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userlbID.text = "\(selectedPost?.id ?? 0)"
        userlbDetail.text = selectedPost?.title
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
