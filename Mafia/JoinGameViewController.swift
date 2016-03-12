//
//  JoinGameViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class JoinGameViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var gameCodeLabel: UITextField!
    
    @IBOutlet weak var joinButton: UIButton!
    var originalJoinButtonText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboardOnTap"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper);

        // Do any additional setup after loading the view.
    }
    
    func dismissKeyboardOnTap() {
        nameLabel.endEditing(true)
        gameCodeLabel.endEditing(true)
    }
    
    @IBAction func onAvatarButtonClick(sender: AnyObject) {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imageFromSource.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            imageFromSource.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let temp: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        avatarImageView.image = temp
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .ScaleAspectFill
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNextButtonClick(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.nameLabel.enabled = false
            self.gameCodeLabel.enabled = false
            self.joinButton.enabled = false
            
            self.originalJoinButtonText = self.joinButton.titleLabel!.text
            self.joinButton.titleLabel!.text = "Joining game..."
        }
        
        let avatar = MafiaClient.randomAvatarType()
        MafiaClient.instance.joinGame(gameCodeLabel.text!,
            playerName: nameLabel.text!,
            avatarType: avatar,
            completion: { (player: Player) -> Void in
                player.isGameCreator = false
                
                let game = Game(gameToken: self.gameCodeLabel.text!)
                MafiaClient.instance.game = game
                game.players.append(Player(playerName: self.nameLabel.text!, avatar: avatar))
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.reenableUI()
                    self.performSegueWithIdentifier("joinGameSegue", sender: self)
                }
            },
            failure: {
                dispatch_async(dispatch_get_main_queue()) {
                    self.reenableUI()
                }
                
                NSLog("Failed to join game")
            }
        )
    }
    
    func reenableUI() {
        nameLabel.enabled = true
        gameCodeLabel.enabled = true
        joinButton.enabled = true
        joinButton.titleLabel!.text = self.originalJoinButtonText
    }

    @IBAction func onHomeButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
