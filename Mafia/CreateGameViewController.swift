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
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarImageButton: UIButton!
    
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

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
            failure: {
                NSLog("Failed to create game")
                self.showAlert("Please try again.") {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    //MARK: Configure Camera
    @IBAction func onAvatarButtonClick(sender: AnyObject) {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imageFromSource.sourceType = UIImagePickerControllerSourceType.Camera
            imageFromSource.cameraDevice = UIImagePickerControllerCameraDevice.Front
        } else {
            imageFromSource.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let temp: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        avatarImageView.image = temp
        avatarImageView.frame = avatarImageButton.frame

        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .ScaleAspectFill
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: Keyboard methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.font = UIFont(name: "Avenir", size: 26)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        resignFirstResponder()
    }
    
    func dismissKeyboardOnTap() {
        playerNameTextField.endEditing(true)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    //MARK: Button Actions


    @IBAction func onNextButtonClick(sender: AnyObject) {
        if playerNameTextField.text == "" {
            errorLabel.hidden = false
        } else {
            joinGame()
        }

    }

    @IBAction func onHomeButtonClicked(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
     //MARK: Private Methods
    
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey]as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntValue << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        bottomConstraint.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame)
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: [animationCurve, .BeginFromCurrentState], animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    func setPendingState(isPending: Bool) {
        playerNameTextField.enabled = !isPending
        joinButton.enabled = !isPending
        
        dispatch_async(dispatch_get_main_queue()) {
            if isPending {
                self.originalJoinButtonText = self.joinButton.titleLabel!.text
                self.joinButton.setTitle("Creating game...", forState: .Normal)
            } else {
                self.joinButton.setTitle(self.originalJoinButtonText, forState: .Normal)
            }
        }
    }
    
    func joinGame() {
        errorLabel.hidden = playerNameTextField.text != ""
        if !errorLabel.hidden {
            return
        }
        
        setPendingState(true)
        
        if gameCreated {
            MafiaClient.instance.joinGame(MafiaClient.instance.game!.token,
                playerName: self.playerNameTextField.text!,
                avatarImageView: avatarImageView,
                completion: { (player: Player) in
                    player.isGameCreator = true
                    
                    // manually insert player data, so they show up before the next network request finishes
                    MafiaClient.instance.game!.players.append(Player(playerName: self.playerNameTextField.text!))
                    MafiaClient.instance.player?.avatarImage = self.avatarImageView.image
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("newGame2LobbySegue", sender: self)
                    }
                },
                failure: {
                    self.setPendingState(false)
                    self.showAlert("Please try again.") {}
                }
            )
        } else {
            bufferedJoin = true
        }
    }
    
    func showAlert(message: String, completion: () -> Void) {
        let alertController = UIAlertController(title: "Failed to create game", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { _ in
            completion()
        }))
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
