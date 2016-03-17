//
//  MafiaClient.swift
//  Mafia
//
//  Created by Charles Yeh on 3/3/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class MafiaClient: NSObject {
    static let BASE_URL = "https://mafia-backend.herokuapp.com"

    var token: String?
    var _player: Player?
    var player: Player? {
        get {
            /*if _player == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let playerData = defaults.objectForKey("currentPlayerData") as? NSData
                if let playerData = playerData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(playerData, options: []) as! NSDictionary
                    _player = Player(fromResponse: dictionary)
                }
            }*/
            return _player
        
        }
        set(player) {
            /*
            let defaults = NSUserDefaults.standardUserDefaults()
            if let player = player {
                let data = try! NSJSONSerialization.dataWithJSONObject((player.dictionary)!, options: [])
                defaults.setObject(data, forKey: "currentPlayerData")
                
            } else {
                defaults.setObject(nil, forKey: "currentPlayerData")
            }
            defaults.synchronize()*/
            
            _player = player
        }
    }

    var _game: Game?
    var game: Game? {
        get {
            /*if _game == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let gameData = defaults.objectForKey("currentGameData") as? NSData
                if let gameData = gameData {
                let dictionary = try! NSJSONSerialization.JSONObjectWithData(gameData, options: []) as! NSDictionary
                _game = Game(fromResponse: dictionary)
                }
            }*/
            return _game
        }
        set(game) {
            /*let defaults = NSUserDefaults.standardUserDefaults()
            if let game = game {
                let data = try! NSJSONSerialization.dataWithJSONObject((game.dictionary)!, options: [])
                defaults.setObject(data, forKey: "currentGameData")

            } else {
                defaults.setObject(nil, forKey: "currentGameData")
            }
            defaults.synchronize()*/

            _game = game
        }
    }

    static var instance = MafiaClient()

    /**
      POST /games
      Calls completion with the new game's token.
     */
    func createGame(completion completion: Game -> Void, failure: () -> Void) {
        if token != nil {
            NSLog("Already connected to game \(token), but trying to create a new game.")
        }

        sendRequest(MafiaClient.BASE_URL + "/games", method: "POST", data: nil) {
            (data, response, error) -> Void in
            let statusCode = (response as! NSHTTPURLResponse).statusCode

            if statusCode < 400 {
                let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as! NSDictionary

                let newGame = Game(fromResponse: responseDictionary)
                self.cacheGame(newGame)

                completion(newGame)
            } else {
                failure()
            }
        }
    }

    /**
     POST /games
     Calls completion with the new game's token.
     */
    func joinGame(joinToken: String, playerName: String, avatarImageView: UIImageView, completion: Player -> Void, failure: () -> Void) {
        if token != nil {
            NSLog("Already connected to game \(joinToken), but trying to join a new game.")
        }
        
        // TODO: Resize and CROP
        let imageData = UIImagePNGRepresentation(avatarImageView.image!)
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) // encode the image
        
        NSLog("Joining game \(joinToken)")
        sendRequest(MafiaClient.BASE_URL + "/games/\(joinToken)/players", method: "POST", data: ["player": ["name": playerName, "avatar_file_name": "avatar.png", "avatar_file_data": base64String]]) {
            (data, response, error) -> Void in
            let statusCode = (response as! NSHTTPURLResponse).statusCode

            if statusCode < 400 {
                let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as! NSDictionary

                self.token = joinToken
                
                let newPlayer = Player(fromResponse: responseDictionary)
                self.player = newPlayer
                completion(newPlayer)
            } else {
                failure()
            }
        }
    }
    
    /**
     GET /games/:token
     Calls completion with the new game's token.
     */
    func pollGameStatus(completion completion: Game -> Void, failure: () -> Void) {
        if let token = token {
            sendRequest(MafiaClient.BASE_URL + "/games/\(token)", method: "GET", data: nil) {
                (data, response, error) -> Void in
                let statusCode = (response as! NSHTTPURLResponse).statusCode

                if statusCode < 400 {
                    let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data!, options:[]) as! NSDictionary

                    let newGame = Game(fromResponse: responseDictionary)
                    self.cacheGame(newGame)
                    
                    completion(newGame)
                } else {
                    failure()
                }
            }
        }
    }

    /**
     PATCH /games/:token
     Calls completion with the new game's token.
     */
    func startGame(completion completion: Game -> Void, failure: () -> Void) {
        if let token = token {
            sendRequest(MafiaClient.BASE_URL + "/games/\(token)/start", method: "POST", data: nil) {
                (data, response, error) -> Void in
                let statusCode = (response as! NSHTTPURLResponse).statusCode

                if statusCode < 400 {
                    let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data!, options:[]) as! NSDictionary
                    
                    let newGame = Game(fromResponse: responseDictionary)
                    self.cacheGame(newGame)
                    completion(newGame)
                } else {
                    failure()
                }
            }
        }
    }

    /**
     POST /games/:token/events
     Calls completion with the new game's token.
     */
    func addGameEvent(eventName: EventType, targetPlayerId: Int, completion: Game -> Void, failure: () -> Void) {
        if let token = token {
            
            let eventData = ["event": ["name": eventName.rawValue, "source_player_id": MafiaClient.instance.player!.id, "target_player_id": targetPlayerId]]
            
            sendRequest(MafiaClient.BASE_URL + "/games/\(token)/events", method: "POST", data: eventData) {
                (data, response, error) -> Void in
                let statusCode = (response as! NSHTTPURLResponse).statusCode

                if statusCode < 400 {
                    let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data!, options:[]) as! NSDictionary
                    completion(Game(fromResponse: responseDictionary))
                } else {
                    failure()
                }
            }
        }
    }
    
    /**
     DELETE /games/:token/players/:player_id
     Calls completion with removed player's id.
     */
    func deletePlayer(playerId: Int, completion: Game -> Void, failure: () -> Void){
        if let token = token {
            
            sendRequest(MafiaClient.BASE_URL + "/games/\(token)/players/\(playerId)", method: "DELETE", data: nil) {
                (data, response, error) -> Void in
                
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                
                if statusCode < 400 {
                    let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data!, options:[]) as! NSDictionary
                    completion(Game(fromResponse: responseDictionary))
                    let newGame = Game(fromResponse: responseDictionary)
                    self.cacheGame(newGame)
                    completion(newGame)
                } else {
                    failure()
                }
            }
        }
    }

    
    private func sendRequest(
        url: String, method: String, data: NSDictionary?, isAddingImage: Bool = false, requestCompletion: (NSData?, NSURLResponse?, NSError?) -> Void) {

        if let url = NSURL(string: url) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method
            if isAddingImage {
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                do {
                    request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions(rawValue: 0))
                } catch {
                    print ("error in serializing data")
                }
                
            } else {
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                if let data = data {
                    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(data, options: [])
                }
            }
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request, completionHandler: requestCompletion)
            task.resume()
        }
    }
    
    class func randomCivilianImage() -> String {
        let array = ["boy1", "boy2", "girl1", "girl2"]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        return array[randomIndex]
    }
    
    private func cacheGame(newGame: Game) -> Void {
        game = newGame
        if let cachedPlayer = player {
            for newPlayer in newGame.players {
                if cachedPlayer.id == newPlayer.id {
                    player = newPlayer
                    break
                }
            }
        }
    }
}
