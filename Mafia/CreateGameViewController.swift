//
//  PlayerProfileViewController.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/2/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit
import AVFoundation

class CreateGameViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarImageButton: UIButton!
    
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!

    var gameCreated = false
    var bufferedJoin = false

    var originalJoinButtonText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapper = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboardOnTap"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper);
        
        MafiaClient.instance.createGame(
            completion: { (game: Game) -> Void in
                self.gameCreated = true
                if self.bufferedJoin {
                    NSLog("Join was waiting for create, now joining...")
                    self.joinGame()
                }
            },
            failure: { NSLog("Failed to create game") }
        )
    }

    func dismissKeyboardOnTap() {
        playerNameTextField.endEditing(true)
    }

    //MARK: Configure Camera
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



    //MARK: Private Methods

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.font = UIFont(name: "Avenir", size: 26)
    }

    @IBAction func onNextButtonClick(sender: AnyObject) {
        joinGame()
    }

    @IBAction func onHomeButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func joinGame() {
        playerNameTextField.enabled = false
        joinButton.enabled = false
        
        dispatch_async(dispatch_get_main_queue()) {
            self.originalJoinButtonText = self.joinButton.titleLabel!.text
            self.joinButton.titleLabel!.text = "Creating game..."
        }
        
        if gameCreated {
            MafiaClient.instance.joinGame(MafiaClient.instance.game!.token,
                playerName: self.playerNameTextField.text!,
                avatarType: MafiaClient.randomAvatarType(),
                completion: { (player: Player) in
                    player.isGameCreator = true
                    MafiaClient.instance.player = player
                    
                    // manually insert player data, so they show up before the next network request finishes
                    let playerData = [
                        // arbitrary id, will be reset on next load
                        "id": 0,
                        "name": self.playerNameTextField.text!,
                        "avatar_type": MafiaClient.randomAvatarType()]
                    MafiaClient.instance.game!.players.append(Player(fromDictionary: NSDictionary(dictionary: playerData)))
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.playerNameTextField.enabled = true
                        self.joinButton.enabled = true
                        self.joinButton.titleLabel!.text = self.originalJoinButtonText
                        
                        self.performSegueWithIdentifier("newGame2LobbySegue", sender: self)
                    }
                },
                failure: { NSLog("Failed to join game") }
            )
        } else {
            bufferedJoin = true
        }
    }
}
