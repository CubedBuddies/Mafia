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
    
    // TODO: handle errors
    // TODO: get rid of force casts
    
    /**
      POST /games
      Calls completion with the new game's token.
     */
    func createGame(completion: Game -> Void) {
        sendRequest(BASE_URL + "/games", method: "POST") {
            (data, response, error) -> Void in
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    completion(Game(fromResponse: responseDictionary))
            }
        }
    }
    
    /**
     POST /games
     Calls completion with the new game's token.
     */
    func joinGame(token: String, completion: Player -> Void) {
        sendRequest(BASE_URL + "/games/\(token)/users", method: "POST") {
            (data, response, error) -> Void in
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    completion(Player(fromResponse: responseDictionary))
            }
        }
    }
    
    /**
     GET /games/:token
     Calls completion with the new game's token.
     */
    func pollGameStatus(token: String, completion: Game -> Void) {
        sendRequest(BASE_URL + "/games/\(token)", method: "GET") {
            (data, response, error) -> Void in
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    completion(Game(fromResponse: responseDictionary))
            }
        }

    }
    
    /**
     PATCH /games/:token
     Calls completion with the new game's token.
     */
    func changeGameStatus(token: String, newStatus: String, completion: Game -> Void) {
        sendRequest(BASE_URL + "/games/\(token)", method: "PATCH") {
            (data, response, error) -> Void in
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    completion(Game(fromResponse: responseDictionary))
            }
        }

    }
    
    /**
     GET /games/:token/events
     Calls completion with the new game's token.
     */
    func getGameEvents(token: String, completion :[Event] -> Void) {
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
    
    /**
     POST /games/:token/events
     Calls completion with the new game's token.
     */
    func addGameEvent(token: String, completion: Event -> Void) {
        sendRequest(BASE_URL + "/games/\(token)/events", method: "POST") {
            (data, response, error) -> Void in
            // TODO: return whether joining succeeded
            
            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                data!, options:[]) as? NSDictionary {
                    completion(Event(fromResponse: responseDictionary))
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
