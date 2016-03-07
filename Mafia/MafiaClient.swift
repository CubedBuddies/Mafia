//
//  MafiaClient.swift
//  Mafia
//
//  Created by Charles Yeh on 3/3/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit
import SwiftHTTP

class MafiaClient: NSObject {
    let BASE_URL = "https://mafia-backend.herokuapp.com"
    
    var token: String?
    var player: Player?
    
    static var instance = MafiaClient()
    
    /**
      POST /games
      Calls completion with the new game
     */
    func createGame() {
        if token != nil {
            NSLog("Already connected to game \(token), but trying to create a new game.")
        }
        
        do {
            let opt = try HTTP.POST(BASE_URL + "/games")
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    // TODO: (ricksong) Notify application of error)
                    return
                }
                
//                let resp = JSONDecoder(response.data)
                
//                print("opt finished: \(response.description)")
//                print("data is: \(response.data)")
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    /**
     POST /games/:token/users
     Calls completion with the new player
     */
    func joinGame(joinToken: String, completion: Player -> Void) {
        if token != nil {
            NSLog("Already connected to game \(token), but trying to join a new game.")
        }
        
//        sendRequest(BASE_URL + "/games/\(token)/users", method: "POST") {
//            (data, response, error) -> Void in
//            
//            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
//                data!, options:[]) as? NSDictionary {
//                    
//                    self.token = joinToken
//                    completion(Player(fromResponse: responseDictionary))
//            }
//        }
    }
    
    
    /**
     GET /games/:token
     Calls completion with the updated game
     */
    func pollGameStatus(completion: Game -> Void) {
//        if let token = token {
//            sendRequest(BASE_URL + "/games/\(token)", method: "GET") {
//                (data, response, error) -> Void in
//                
//                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
//                    data!, options:[]) as? NSDictionary {
//                        completion(Game(fromResponse: responseDictionary))
//                }
//            }
//        }

    }
    
    /**
     POST /games/:token/users
     Calls completion with the updated game
     */
    func startGame(joinToken: String, completion: Game -> Void) {
//        sendRequest(BASE_URL + "/games/\(token)/start", method: "POST") {
//            (data, response, error) -> Void in
//            
//            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
//                data!, options:[]) as? NSDictionary {
//                    self.token = joinToken
//                    completion(Game(fromResponse: responseDictionary))
//            }
//        }
    }
    
    /**
     POST /games/:token/events
     Calls completion with the new game's token.
     */
    func addGameEvent(completion: Event -> Void) {
//        if let token = token {
//            sendRequest(BASE_URL + "/games/\(token)/events", method: "POST") {
//                (data, response, error) -> Void in
//                // TODO: return whether joining succeeded
//                
//                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
//                    data!, options:[]) as? NSDictionary {
//                        completion(Event(fromResponse: responseDictionary))
//                }
//            }
//        }
    }
}
