//
//  LobbyViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlayerCellDelegate {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startGameButton: UIButton!

    var refreshTimer: NSTimer = NSTimer()
    var originalStartButtonText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()

        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("refreshPlayers"), userInfo: nil, repeats: true)
        
        codeLabel.text = MafiaClient.instance.game?.token
    }

    func pendingState(disable: Bool) {
        startGameButton.enabled = !disable
        originalStartButtonText = startGameButton.titleLabel!.text!
        startGameButton.setTitle(disable ? "Starting game..." : originalStartButtonText, forState: .Normal)
    }
    
    @IBAction func onStartGameClick(sender: AnyObject) {
        pendingState(true)
        MafiaClient.instance.startGame(
            completion: { (_: Game) in
                self.pendingState(false)
                self.refreshTimer.invalidate()
            },
            failure: {
                self.pendingState(false)
                let alertController = UIAlertController(title: "Failed to start game", message:
                    "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                NSLog("Failed to start game")
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Private Methods
    func refreshPlayers() {
        MafiaClient.instance.pollGameStatus(
            completion: { (game: Game) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.codeLabel.text = MafiaClient.instance.game?.token
                    self.tableView.reloadData()
                    
                    // check if game was already started
                    if game.state == .IN_PROGRESS {
                        self.performSegueWithIdentifier("lobby2roleRevealSegue", sender: self)
                    }
                }
            },
            failure: { NSLog("Failed to poll game status") }
        )
    }

    //MARK: Table View Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerTableViewCell", forIndexPath: indexPath) as! PlayerTableViewCell

        let player = MafiaClient.instance.game!.players[indexPath.row]
        cell.playerNameLabel.text = player.name
        print(MafiaClient.instance.player?.id)
        if(player.name != MafiaClient.instance.player?.name) {
            cell.leaveButton.hidden = true
        }
        
        cell.delegate = self

        return cell
    }
    
    
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let deleteButton = UITableViewRowAction(style: .Normal, title: "Delete") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
//            let currPlayer = MafiaClient.instance.game?.players[indexPath.row]
//            MafiaClient.instance.deletePlayer((currPlayer?.id)!,
//                completion: { (game: Game) -> Void in
//                    dispatch_async(dispatch_get_main_queue()) {
//                        MafiaClient.instance.game?.players.removeAtIndex(indexPath.row)
//                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
////                        print(game.players.count)
//                    }
//                }, failure: { NSLog("Failed to delete player")}
//            )
//        }
//        deleteButton.backgroundColor = UIColor(red: 0.686, green: 0.0039, blue: 0.0, alpha: 1.0)
//        
//        return [deleteButton]
//    }
//    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        // you need to implement this method too or you can't swipe to display the actions
//    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MafiaClient.instance.game?.players.count ?? 0
    }
    
    func playerCell(playerCell: PlayerTableViewCell, leaveButtonPressed value: Bool) {
        MafiaClient.instance.deletePlayer((MafiaClient.instance.player?.id)!,
            completion: { (game: Game) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let homeView: HomeViewController = storyboard.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                    UIApplication.sharedApplication().keyWindow?.rootViewController = homeView
                }
            }) { () -> Void in
                print("failed to remove player from game")
        }
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
