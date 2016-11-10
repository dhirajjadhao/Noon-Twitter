//
//  Tweet.swift
//  Noon Twitter
//
//  Created by Dhiraj Jadhao on 09/11/16.
//  Copyright © 2016 Dhiraj Jadhao. All rights reserved.
//

import Foundation
import ObjectMapper
import AlamofireObjectMapper


class Tweet: Mappable {
 
    
    //MARK: Properties
    
    var name: String = ""
    var handle: String = ""
    var createdAt:String = ""
    var body: String = ""
    var profileImageURL: String = ""
    var retweetCount:Int = 0
    var likeCount:Int = 0
    
    
    
    
    //MARK: Initialization
    
    init(name: String, handle: String, createdAt: String, body: String, profileImageURL: String, retweetCount: Int,likeCount: Int) {
        
        self.name = name
        self.handle = handle
        self.createdAt = createdAt
        self.body = body
        self.profileImageURL = profileImageURL
        self.retweetCount = retweetCount
        self.likeCount = likeCount
    }
    
    
    
    //MARK: Mapping
    
    public required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        name <- map["user.name"]
        handle <- map["user.screen_name"]
        createdAt <- map["created_at"]
        body <- map["text"]
        profileImageURL <- map["user.profile_image_url_https"]
        retweetCount <- map["retweet_count"]
        likeCount <- map["favorite_count"]
        
    }

    
}
