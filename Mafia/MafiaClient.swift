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
    var player: Player?
    
    var _game: Game?
    var game: Game? {
        get {
            if _game == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let gameData = defaults.objectForKey("currentGameData") as? NSData
                if let gameData = gameData {
                let dictionary = try! NSJSONSerialization.JSONObjectWithData(gameData, options: []) as! NSDictionary
                _game = Game(fromResponse: dictionary)
                }
            }
            return _game
        }
        set(game) {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let game = game {
                let data = try! NSJSONSerialization.dataWithJSONObject((game.dictionary)!, options: [])
                defaults.setObject(data, forKey: "currentGameData")
                
            } else {
                defaults.setObject(nil, forKey: "currentGameData")
            }
            defaults.synchronize()
            
            _game = game
        }
    }
    
    static var instance = MafiaClient()
    static var instances: [MafiaClient]?
    
    // TODO: handle errors
    // TODO: get rid of force casts
    
    /**
      POST /games
      Calls completion with the new game's token.
     */
    func createGame(completion: Game -> Void) {
        if token != nil {
            NSLog("Already connected to game \(token), but trying to create a new game.")
        }
        
        sendRequest(BASE_URL + "/games", method: "POST", data: nil) {
            (data, response, error) -> Void in
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    
                    let newGame = Game(fromResponse: responseDictionary)
                    self.game = newGame
                    
                    completion(newGame)
            } else {
                
            }
        }
    }
    
    /**
     POST /games
     Calls completion with the new game's token.
     */
    func joinGame(joinToken: String, playerName: String, avatarType: String, completion: Player -> Void) {
        if token != nil {
            NSLog("Already connected to game \(joinToken), but trying to join a new game.")
        }
        
        sendRequest(BASE_URL + "/games/\(joinToken)/players", method: "POST", data: ["player": ["name": playerName, "avatar_type": avatarType]]) {
            (data, response, error) -> Void in
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    
                    self.token = joinToken
                    completion(Player(fromResponse: responseDictionary))
            } else {
                NSLog("Failed to join game.")
            }
        }
    }
    
    /**
     GET /games/:token
     Calls completion with the new game's token.
     */
    func pollGameStatus(completion: Game -> Void) {
        if let token = token {
            sendRequest(BASE_URL + "/games/\(token)", method: "GET", data: nil) {
                (data, response, error) -> Void in
                
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as? NSDictionary {
                        let newGame = Game(fromResponse: responseDictionary)
                        self.game = newGame
                        completion(newGame)
                }
            }
        } else {
            NSLog("Tried to poll game status without joining a game first.")
        }
    }
    
    /**
     PATCH /games/:token
     Calls completion with the new game's token.
     */
    func startGame(completion: () -> Void) {
        if let token = token {
            sendRequest(BASE_URL + "/games/\(token)/start", method: "POST", data: nil) {
                (data, response, error) -> Void in
                
                completion()
            }
        }
    }
    
    /**
     GET /games/:token/events
     Calls completion with the new game's token.
     */
    func getGameEvents(completion :[Event] -> Void) {
        if let token = token {
            sendRequest(BASE_URL + "/games/\(token)/events", method: "GET", data: nil) {
                (data, response, error) -> Void in
                
                if let eventResponses = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as? NSArray {
                        let events = eventResponses.map { (eventResponse) -> Event in
                            Event(fromResponse: eventResponse)
                        }
                        completion(events)
                }
            }
        }
    }
    
    /**
     POST /games/:token/events
     Calls completion with the new game's token.
     */
    func addGameEvent(eventName: String, targetPlayerId: Int, completion: Event -> Void) {
        if let token = token {
            // TODO: get player id
            let eventData = ["event": ["name": eventName, "source_player_id": Player.currentPlayer!.id, "target_player_id": targetPlayerId]]
            sendRequest(BASE_URL + "/games/\(token)/events", method: "POST", data: eventData) {
                (data, response, error) -> Void in
                // TODO: return whether joining succeeded
                
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as? NSDictionary {
                        completion(Event(fromResponse: responseDictionary))
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
}
