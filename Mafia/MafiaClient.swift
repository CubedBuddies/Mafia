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
                        completion(Game(fromResponse: responseDictionary))
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
    func changeGameStatus(newStatus: String, completion: Game -> Void) {
        if let token = token {
            sendRequest(BASE_URL + "/games/\(token)", method: "PATCH", data: nil) {
                (data, response, error) -> Void in
                
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as? NSDictionary {
                        completion(Game(fromResponse: responseDictionary))
                }
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
    func addGameEvent(completion: Event -> Void) {
        if let token = token {
            sendRequest(BASE_URL + "/games/\(token)/events", method: "POST", data: nil) {
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
                print(try! NSJSONSerialization.JSONObjectWithData(try! NSJSONSerialization.dataWithJSONObject(data, options: []), options: []))
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(data, options: [])
            }
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request, completionHandler: requestCompletion)
            task.resume()
        }
    }
}
