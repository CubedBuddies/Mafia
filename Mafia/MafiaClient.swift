//
//  MafiaClient.swift
//  Mafia
//
//  Created by Charles Yeh on 3/3/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class MafiaClient: NSObject {
    let BASE_URL = "http://eactiv.com/mafia"
    
    var token: String?
    var player: Player?
    
    static var instance = MafiaClient()
    
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
        
        sendRequest(BASE_URL + "/games", method: "POST") {
            (data, response, error) -> Void in
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    
                    let newGame = Game(fromResponse: responseDictionary)
                    self.token = newGame.token
                    completion(newGame)
            }
        }
    }
    
    /**
     POST /games
     Calls completion with the new game's token.
     */
    func joinGame(joinToken: String, completion: Player -> Void) {
        if token != nil {
            NSLog("Already connected to game \(token), but trying to join a new game.")
        }
        
        sendRequest(BASE_URL + "/games/\(token)/users", method: "POST") {
            (data, response, error) -> Void in
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    
                    self.token = joinToken
                    completion(Player(fromResponse: responseDictionary))
            }
        }
    }
    
    
    /**
     GET /games/:token
     Calls completion with the new game's token.
     */
    func pollGameStatus(completion: Game -> Void) {
        if let token = token {
            sendRequest(BASE_URL + "/games/\(token)", method: "GET") {
                (data, response, error) -> Void in
                
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as? NSDictionary {
                        completion(Game(fromResponse: responseDictionary))
                }
            }
        }

    }
    
    /**
     PATCH /games/:token
     Calls completion with the new game's token.
     */
    func changeGameStatus(newStatus: String, completion: Game -> Void) {
        if let token = token {
            sendRequest(BASE_URL + "/games/\(token)", method: "PATCH") {
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
            sendRequest(BASE_URL + "/games/\(token)/events", method: "GET") {
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
            sendRequest(BASE_URL + "/games/\(token)/events", method: "POST") {
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
        url: String, method: String,
        requestCompletion: (NSData?, NSURLResponse?, NSError?) -> Void) {
        
        if let url = NSURL(string: url) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method
            
            let session = NSURLSession()
            session.dataTaskWithRequest(request, completionHandler: requestCompletion)
        }
    }
}
