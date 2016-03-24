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

    @IBOutlet weak var titleLabel: UILabel!
    
    var refreshTimer: NSTimer = NSTimer()
    var originalStartButtonText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = UIFont(name: "a_StamperBrk", size: 40)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.createRefreshTimer()
            self.codeLabel.text = MafiaClient.instance.game?.token
        }
    }

    func pendingState(disable: Bool) {
        startGameButton.enabled = !disable
        originalStartButtonText = startGameButton.titleLabel!.text!
        startGameButton.setTitle(disable ? "Starting game..." : originalStartButtonText, forState: .Normal)
    }
    
    func createRefreshTimer() {
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("refreshPlayers"), userInfo: nil, repeats: true)
    }
    
    @IBAction func onStartGameClick(sender: AnyObject) {
        
        pendingState(true)
        refreshTimer.invalidate()
        
        MafiaClient.instance.startGame(
            completion: { (_: Game) in
                NSLog("Started game!")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.pendingState(false)
                    self.performSegueWithIdentifier("startGameSegue", sender: self)
                }
            },
            failure: {
                NSLog("Failed to start game")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.createRefreshTimer()
                
                    self.pendingState(false)
                    let alertController = UIAlertController(title: "Failed to start game", message:
                        "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
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
                        self.refreshTimer.invalidate()
                        self.performSegueWithIdentifier("startGameSegue", sender: self)
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
        if(player.name != MafiaClient.instance.player?.name) {
            cell.leaveButton.hidden = true
        }
        
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MafiaClient.instance.game?.players.count ?? 0
    }
    
    func playerCell(playerCell: PlayerTableViewCell, leaveButtonPressed value: Bool) {
        refreshTimer.invalidate()
        
        MafiaClient.instance.deletePlayer((MafiaClient.instance.player?.id)!,
            completion: { (game: Game) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    MafiaClient.instance.game = nil
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let homeView: HomeViewController = storyboard.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                    UIApplication.sharedApplication().keyWindow?.rootViewController = homeView
                }
            }) { () -> Void in
                print("failed to remove player from game")
        }
    }
}
