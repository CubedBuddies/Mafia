//
//  MafiaClient.swift
//  Mafia
//
//  Created by Charles Yeh on 3/3/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class MafiaClient: NSObject {
    let BASE_URL = "https://mafia-backend.herokuapp.com"

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

    // TODO: handle errors
    // TODO: get rid of force casts

    /**
      POST /games
      Calls completion with the new game's token.
     */
    func createGame(completion completion: Game -> Void, failure: () -> Void) {
        if token != nil {
            NSLog("Already connected to game \(token), but trying to create a new game.")
        }

        sendRequest(BASE_URL + "/games", method: "POST", data: nil) {
            (data, response, error) -> Void in
            let statusCode = (response as! NSHTTPURLResponse).statusCode

            if statusCode < 400 {
                let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as! NSDictionary

                let newGame = Game(fromResponse: responseDictionary)
                self.game = newGame

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
    func joinGame(joinToken: String, playerName: String, avatarType: String, completion: Player -> Void, failure: () -> Void) {
        if token != nil {
            NSLog("Already connected to game \(joinToken), but trying to join a new game.")
        }

        sendRequest(BASE_URL + "/games/\(joinToken)/players", method: "POST", data: ["player": ["name": playerName, "avatar_type": avatarType]]) {
            (data, response, error) -> Void in
            let statusCode = (response as! NSHTTPURLResponse).statusCode

            if statusCode < 400 {
                let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as! NSDictionary

                self.token = joinToken
                
                let player = Player(fromResponse: responseDictionary)
                MafiaClient.instance.player = player
                completion(player)
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
            sendRequest(BASE_URL + "/games/\(token)", method: "GET", data: nil) {
                (data, response, error) -> Void in
                let statusCode = (response as! NSHTTPURLResponse).statusCode

                if statusCode < 400 {
                    let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data!, options:[]) as! NSDictionary

                    let newGame = Game(fromResponse: responseDictionary)
                    self.game = newGame
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
            sendRequest(BASE_URL + "/games/\(token)/start", method: "POST", data: nil) {
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
     POST /games/:token/events
     Calls completion with the new game's token.
     */
    func addGameEvent(eventName: EventType, targetPlayerId: Int, completion: Game -> Void, failure: () -> Void) {
        if let token = token {
            // TODO: get player id
            let eventData = ["event": ["name": eventName.rawValue, "source_player_id": MafiaClient.instance.player!.id, "target_player_id": targetPlayerId]]
            sendRequest(BASE_URL + "/games/\(token)/events", method: "POST", data: eventData) {
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

    private func sendRequest(
        url: String, method: String, data: NSDictionary?,
        requestCompletion: (NSData?, NSURLResponse?, NSError?) -> Void) {

        if let url = NSURL(string: url) {
            NSLog("Sending request to \(url)")

            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            if let data = data {
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(data, options: [])
            }

            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request, completionHandler: requestCompletion)
            task.resume()
        }
    }
    
    class func randomAvatarType() -> String {
        let array = ["boy1", "boy2", "girl1", "girl2"]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        return array[randomIndex]
    }
}
