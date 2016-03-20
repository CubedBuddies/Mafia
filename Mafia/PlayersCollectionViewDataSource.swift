//
//  PlayersCollectionViewDataSource.swift
//  Mafia
//
//  Created by Charles Yeh on 3/4/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit
import AFNetworking

class PlayersCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: GameViewControllerDelegate?
    var game: Game? {
        didSet {
            var filteredPlayers = [Player]()
            if let filter = filter {
                for player in game?.players ?? [] {
                    if filter(player) {
                        filteredPlayers.append(player)
                    }
                }
                players = filteredPlayers
            } else {
                players = game?.players
            }
        }
    }
    var players: [Player]?
    var round: Round? {
        didSet {
            if let round = round {
                lynchCounts = countVotes(round.lynchVotes)
                killCounts = countVotes(round.killVotes)
            }
        }
    }
    var filter: ((Player) -> Bool)?
    
    // maps player id to number of votes
    var lynchCounts: [Int: Int]?
    var killCounts: [Int: Int]?
    
    var collectionView: UICollectionView?
    var votes: Bool = false
    
    init(view: UICollectionView, showVotes: Bool, playerFilter: ((Player) -> Bool)?) {
        collectionView = view
        filter = playerFilter
        votes = showVotes
        view.registerNib(UINib(nibName: "PlayersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "playerCell")
    }
    
    func countVotes(votesOrNil: [Int: Int]?) -> [Int: Int] {
        /**
         Converts a mapping of player id to vote target,
         into player id to the number of people voting them.
         */
        
        var count = [Int: Int]()
        if let votes = votesOrNil {
            for voter in votes.keys {
                let votee = votes[voter]!
                count[votee] = (count[votee] ?? 0) + 1
            }
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let cellWidth = (collectionView.frame.size.width / 3) - 1
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playerCell", forIndexPath: indexPath) as! PlayersCollectionViewCell
        
        if let player = players?[indexPath.row] {
            cell.avatarImageView.setImageWithURL(player.getAvatarUrl(), placeholderImage: player.getPlaceholderAvatar())
            
            if player.state == .DEAD {
                cell.nameLabel.text = "DEAD"
            } else {
                cell.nameLabel.text = player.name
            }
            if votes {
                if delegate?.getRoleMode() == true && (MafiaClient.instance.player?.role == .MAFIA) {
                    cell.voteBubble.backgroundColor = UIColor.redColor()
                    cell.voteLabel.text = "\(killCounts?[player.id] ?? 0)"
                } else {
                    cell.voteBubble.backgroundColor = UIColor.blueColor()
                    cell.voteLabel.text = "\(lynchCounts?[player.id] ?? 0)"
                }
            } else {
                cell.voteBubble.hidden = true
                cell.voteLabel.hidden = true
            }
            cell.tag = player.id
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        delegate?.selectPlayer(cell.tag)
    }
    
    func showPlayerStats() {
        collectionView?.reloadData()
    }
}
