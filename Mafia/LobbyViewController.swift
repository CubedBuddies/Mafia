//
//  LobbyViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startGameButton: UIButton!

    var refreshTimer: NSTimer = NSTimer()

    override func viewDidLoad() {
        super.viewDidLoad()
        if MafiaClient.instance.player?.isGameCreator == false{
            startGameButton.hidden = true
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()

        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("refreshPlayers"), userInfo: nil, repeats: true)

    }

    @IBAction func onStartGameClick(sender: AnyObject) {
        MafiaClient.instance.startGame(
            completion: { (_: Game) in
                self.refreshTimer.invalidate()
                self.presentViewController(GameViewController(), animated: true, completion: nil)
            },
            failure: { NSLog("Failed to start game") }
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
                        self.presentViewController(GameViewController(), animated: true, completion: nil)
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

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MafiaClient.instance.game?.players.count ?? 0
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
