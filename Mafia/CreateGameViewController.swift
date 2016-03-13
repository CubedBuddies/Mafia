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

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapper = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboardOnTap"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper);
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
        MafiaClient.instance.game?.clearGameState()
        print(MafiaClient.instance.game?.token)
        MafiaClient.instance.createGame(
            completion: { (game: Game) -> Void in
                NSLog("Created game, now joining...")

                MafiaClient.instance.joinGame(game.token,
                    playerName: self.playerNameTextField.text!,
                    avatarType: "asian",
                    completion: { (player: Player) in
                        Player.currentPlayer = player
                        Player.currentPlayer?.isGameCreator = true
                    },
                    failure: { NSLog("Failed to join game") }
                )
            },
            failure: { NSLog("Failed to create game") }
        )

        self.performSegueWithIdentifier("newGame2LobbySegue", sender: self)
    }

    @IBAction func onHomeButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
