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
    
    var refreshTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Player.currentPlayer?.isGameCreator == false{
            startGameButton.hidden = true
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("refreshPlayers"), userInfo: nil, repeats: true)
        
    }

    @IBAction func onStartGameClick(sender: AnyObject) {
        MafiaClient.instance.startGame { Void in
            // TODO
            self.refreshTimer.invalidate()
            self.presentViewController(GameViewController(), animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private Methods
    func refreshPlayers() {
        MafiaClient.instance.pollGameStatus { (game: Game) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.loadedGame(game)
                self.tableView.reloadData()
            }
        }
    }
    
    func loadedGame(game: Game) {
        Game.currentGame = game
        codeLabel.text = Game.currentGame?.token
    }
    
    //MARK: Table View Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerTableViewCell", forIndexPath: indexPath) as! PlayerTableViewCell
        let player = Game.currentGame!.players[indexPath.row]
        cell.playerNameLabel.text = player.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Game.currentGame?.players.count ?? 0
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
