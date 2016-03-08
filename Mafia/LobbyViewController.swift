//
//  LobbyViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var game: Game?

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startGameButton: UIButton!
    
    var refreshTimer = NSTimer()
    var players: [Player]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Player.currentPlayer?.isGameCreator == false{
            startGameButton.hidden = true
        }
        
        codeLabel.text = Game.currentGame?.token
        
        tableView.delegate = self
        tableView.dataSource = self
        players = Game.currentGame?.players
        tableView.reloadData()
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("refreshPlayers"), userInfo: nil, repeats: true)
        
    }

    @IBAction func onStartGameClick(sender: AnyObject) {
        MafiaClient.instance.changeGameStatus("Active") { (game: Game) -> Void in
            self.game = game
            self.refreshTimer.invalidate()
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private Methods
    func refreshPlayers() {
        MafiaClient.instance.pollGameStatus { (game: Game) -> Void in
            self.players = game.players
            self.tableView.reloadData()
        }
    }
    
    //MARK: Table View Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerTableViewCell", forIndexPath: indexPath) as! PlayerTableViewCell
        let player = players![indexPath.row]
        print(player.name)
        cell.playerNameLabel.text = player.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Game.currentGame?.players.count)!
//        if game?.players == nil {
//            return 0
//        } else {
//            return (game?.players.count)!
//        }
        
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
