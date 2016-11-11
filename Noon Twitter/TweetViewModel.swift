//
//  TweetViewModel.swift
//  Noon Twitter
//
//  Created by Dhiraj Jadhao on 09/11/16.
//  Copyright © 2016 Dhiraj Jadhao. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import ObjectMapper


//MARK: Enum Declaration

enum fetchError: String {
    case NoRefreshTweetsURL = "Refresh URL Not available"
    case NoNextTweetsURL = "Next Result URL Not available"
}



enum refreshStatus: String {
    case off = "Off"
    case twoSec = "2 Seconds"
    case fiveSec = "5 Seconds"
    case thirtySec = "30 Seconds"
    case oneMin = "1 Minute"
}



protocol TweetViewModelDelegate {
    
    func newTweetsAvailable(available:Bool) -> Void
    func didFinishSearchingWithError(error:AnyObject?) -> Void
    func didFinishFetchingNextTweetsWithError(error:AnyObject?) -> Void
}


class TweetViewModel: NSObject {
  
    
    //MARK: Constants
    
    let baseURL = "https://api.twitter.com/1.1"
    let tweetCountPerPage = 20
    let twitterBearerToken = "AAAAAAAAAAAAAAAAAAAAAB12xwAAAAAA1rKfX7wszEa5%2F1HsUH0UqT8A3NI%3DEsfROSafMTG23Pxf3BzlY02zijN286fG4UZODIL819ATDojTQv"
    let createdOnDateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    

    
    
    //MARK: Properties
    
    var delegate: TweetViewModelDelegate?
    let sharedAppDelegate = UIApplication.shared.delegate as! AppDelegate
    var tweetsNextResultURL: String?
    var tweetsRefreshURL: String?
    var currentRefreshStatus = refreshStatus.fiveSec
    var autoRefreshTimer = Timer()
    private var tweet:Tweet?
    
    var nameText: String? {
        return tweet?.name
    }
    
    
    var handleText: String? {
        return tweet?.handle
    }
    
    
    var createdAtText:String? {
        return convertDateToShortString(date: (tweet?.createdAt)!)
    }
    
    
    var bodyText: String? {
        return tweet?.body
    }
    
    
    var profileImageURL: String? {
        return tweet?.profileImageURL == "" ? nil: tweet?.profileImageURL
    }
    
    
    var retweetCountText:String? {
        return "\(tweet!.retweetCount)"
    }
    
    
    var likeCountText:String? {
        return "\(tweet!.likeCount)"
    }
    
    override init() {}
    
    init(tweet:Tweet?) {
        self.tweet = tweet
    }
    

    
    
    //MARK: Helper Methods
    
    func convertDateToShortString(date:String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = createdOnDateFormat
        
        let date1 = formatter.date(from: date)
        
        
        var timeLeft = String()
        let today = NSDate()
        
        var seconds = today.timeIntervalSince(date1!)
        
        let days = floor(seconds/(3600*24))
        if days>0 {
            seconds -= days*3600*24
        }
        
        let hours = floor(seconds/3600)
        if hours>0 {
            seconds -= hours*3600
        }
        
        let minutes = floor(seconds/60)
        if minutes>0 {
            seconds -= minutes*60
        }
        
        if days>0 {

            timeLeft = "\(Int(days))d"
            
        }else if hours>0{

            timeLeft = "\(Int(hours))h"
            
        }else if minutes>0{

            timeLeft = "\(Int(minutes))m"

        }else if seconds>0{

            timeLeft = "\(Int(seconds))s"
 
        }

        return timeLeft
    
    }

    
    
    //MARK: Data Refresh Methods

    func enableAutoRefresh() -> Void {

       if refreshStatusToTimeInterval(status: currentRefreshStatus) > 0{
            disableAutoRefresh()
            autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: refreshStatusToTimeInterval(status: currentRefreshStatus), repeats: true, block: { (Timer) in
                self.fetchNewTweetsForCurrentQuery()
            })
        }else{
            disableAutoRefresh()
        }
        
    }
    
    
    
    func disableAutoRefresh() -> Void {
        
        autoRefreshTimer.invalidate()
    }
    
    
    
    func refreshStatusToTimeInterval(status: refreshStatus) -> TimeInterval {
        
        switch status {
        case refreshStatus.off:
            return 0
        case refreshStatus.twoSec:
            return 2
        case refreshStatus.fiveSec:
            return 5
        case refreshStatus.thirtySec:
            return 30
        case refreshStatus.oneMin:
            return 60
        }
        
    }
    
    
    
    
    //MARK: Networking
    
    func searchTwitterFor(query:String) -> Void {
        
        let requestURL = "\(baseURL)/search/tweets.json"
        
        let headers = [
            "Authorization": "Bearer \(twitterBearerToken)",
            "Accept": "application/json"
        ]
        
        let parameters:[String : Any] = [
            "q":query,
            "count":tweetCountPerPage
        ]
        
        Alamofire.request(requestURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                    case .success(_):
                        
                        self.clearAllPreviousQueryData()
                        
                        let responseObject = response.result.value as! NSDictionary
                        let searchMetadata = responseObject["search_metadata"] as! NSDictionary
                        
                        self.tweetsRefreshURL = searchMetadata.object(forKey: "refresh_url") as? String
                        self.tweetsNextResultURL = searchMetadata.object(forKey: "next_results") as? String
                        
                        self.addSearchedTweets(result: responseObject["statuses"] as! NSArray)
                        self.enableAutoRefresh()
                    
                    case .failure(let error):
                        
                        print(error)
                    
                        self.didFinishSearchingWithError(error: error as AnyObject?)
                    
            }
        }
    }
    
    
    
    
    
    func fetchNextTweetsForCurrentQuery() -> Void {
        
        if tweetsNextResultURL != nil {
            
            let requestURL = "\(baseURL)/search/tweets.json\(tweetsNextResultURL!)"
            
            let headers = [
                "Authorization": "Bearer \(twitterBearerToken)",
                "Accept": "application/json"
            ]
            
            
            Alamofire.request(requestURL, method: .get, parameters: nil, headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                        
                    case .success(_):
                        
                        let responseObject = response.result.value as! NSDictionary
                        
                        
                        let searchMetadata = responseObject["search_metadata"] as! NSDictionary
                        
                        //self.tweetsRefreshURL = searchMetadata.object(forKey: "refresh_url") as? String
                        self.tweetsNextResultURL = searchMetadata.object(forKey: "next_results") as? String
                        
                        self.addSearchedTweets(result: responseObject["statuses"] as! NSArray)
                        
                    case .failure(let error):
                        
                        print(error)
                        
                        self.didFinishFetchingNextTweetsWithError(error: error as AnyObject?)
                        
                    }
            }
            
        }else{
            
            self.didFinishSearchingWithError(error: fetchError.NoNextTweetsURL as AnyObject?)
        }

        
    }
    
    
    
    
    
    func fetchNewTweetsForCurrentQuery() -> Void {
        
        
        if tweetsRefreshURL != nil {
            
            let requestURL = "\(baseURL)/search/tweets.json\(tweetsRefreshURL!)"
            
            let headers = [
                "Authorization": "Bearer \(twitterBearerToken)",
                "Accept": "application/json"
            ]
            
            
            Alamofire.request(requestURL, method: .get, parameters: nil, headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                        
                    case .success(_):
                        
                        let responseObject = response.result.value as! NSDictionary
                        
                        
                        
                        let searchMetadata = responseObject["search_metadata"] as! NSDictionary
                        
                        self.tweetsRefreshURL = searchMetadata.object(forKey: "refresh_url") as? String
                        //self.tweetsNextResultURL = searchMetadata.object(forKey: "next_results") as? String
                        
                        self.updateTweetsWithNew(result: responseObject["statuses"] as! NSArray)
                        
                        
                    case .failure(let error):
                        
                        print(error)
                        
                        self.didFinishSearchingWithError(error: error as AnyObject?)
                        
                    }
            }
            
        }else{
            
            self.didFinishSearchingWithError(error: fetchError.NoRefreshTweetsURL as AnyObject?)
        }
        

        
    }
    
    
    
    
    
    //MARK: Data Handling Method
    
    func updateTweetsWithNew(result: NSArray)-> Void {
        
        var newTweets = [TweetViewModel]()
        
        for i in 0 ..< result.count{
            
            let tweet = Mapper<Tweet>().map(JSON: result[i] as! [String : Any])
            newTweets.append(TweetViewModel.init(tweet: tweet))
            
        }
        
        if newTweets.count > 0 {
         
            sharedAppDelegate.tweets = newTweets+sharedAppDelegate.tweets
            self.newTweetsAvailable(available: true)
            
        }else{
            self.newTweetsAvailable(available: false)
        }
  
    }
    
    
    
    func addSearchedTweets(result: NSArray) -> Void {
        
        for i in 0 ..< result.count{
            
            let tweet = Mapper<Tweet>().map(JSON: result[i] as! [String : Any])
            sharedAppDelegate.tweets.append(TweetViewModel.init(tweet: tweet))
            
        }
        
        if tweetsNextResultURL == nil {
           self.didFinishSearchingWithError(error: nil)
        }else{
            self.didFinishFetchingNextTweetsWithError(error: nil)
        }
        
    }
    
    
    
    
    func clearAllPreviousQueryData() -> Void{
        
        sharedAppDelegate.tweets.removeAll()
        tweetsNextResultURL = nil
        tweetsRefreshURL = nil
    }
    
    
    
    
    //MARK: Delegate Methods
    
    func didFinishSearchingWithError(error:AnyObject?) -> Void {
        delegate?.didFinishSearchingWithError(error: error)
    }
    
    
    
    func newTweetsAvailable(available:Bool) -> Void{
        delegate?.newTweetsAvailable(available: available)
    }
    
    
    
    func didFinishFetchingNextTweetsWithError(error:AnyObject?) -> Void{
        delegate?.didFinishFetchingNextTweetsWithError(error: error)
    }
    
    
}
