//
//  JoinGameViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class JoinGameViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var gameCodeLabel: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var codeErrorLabel: UILabel!
    
    @IBOutlet weak var joinButton: UIButton!
    var originalJoinButtonText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboardOnTap"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper);

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //add observers for when keyboard shows
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //remove observers when keyboard disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: Camera Methods
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
        avatarImageView.frame = cameraButton.frame
        
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .ScaleAspectFill
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Keyboard methods
    
    func dismissKeyboardOnTap() {
        nameLabel.endEditing(true)
        gameCodeLabel.endEditing(true)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }

    //MARK: IBActions for button clicks
    
    @IBAction func onNextButtonClick(sender: AnyObject) {
        nameErrorLabel.hidden = nameLabel.text != ""
        codeErrorLabel.hidden = gameCodeLabel.text != ""
        if !nameErrorLabel.hidden || !codeErrorLabel.hidden {
            return
        }
        
        MafiaClient.instance.joinGame(gameCodeLabel.text!,
            playerName: nameLabel.text!,
            avatarImageView: avatarImageView,
            completion: { (player: Player) -> Void in
                player.isGameCreator = false
                
                MafiaClient.instance.pollGameStatus(completion: { (game) -> Void in
                    
                    self.setPendingState(false)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("joinGameSegue", sender: self)
                    }
                    
                    }) { () -> Void in
                        // join anyways, it just won't have lobby data
                        self.setPendingState(false)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.performSegueWithIdentifier("joinGameSegue", sender: self)
                        }
                }
            },
            failure: {
                self.setPendingState(false)
                NSLog("Failed to join game")
            }
        )

    }
    
    @IBAction func onHomeButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlert(message: String, completion: () -> Void) {
        let alertController = UIAlertController(title: "Failed to join game", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { _ in
            completion()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
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
        self.nameLabel.enabled = false
        self.gameCodeLabel.enabled = false
        self.joinButton.enabled = false
        
        dispatch_async(dispatch_get_main_queue()) {
            if isPending {
                self.originalJoinButtonText = self.joinButton.titleLabel!.text
                self.joinButton.setTitle("Joining game...", forState: .Normal)
            } else {
                self.joinButton.setTitle(self.originalJoinButtonText, forState: .Normal)
            }
        }
    }
}
