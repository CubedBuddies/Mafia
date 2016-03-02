//
//  PlayerProfileViewController.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/2/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class PlayerProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var isNewGameSwitch: UISwitch!
    @IBOutlet weak var codeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSubmitClick(sender: AnyObject) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
