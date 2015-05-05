//
//  TwitterClient.swift
//  Twitter
//
//  Created by Chris Beale on 4/28/15.
//  Copyright (c) 2015 Chris Beale. All rights reserved.
//

import UIKit

let twitterConsumerKey = "SxeXMXaxJiGsWNcXHO0KWfJgE"
let twitterConsumerSecret = "MGk4NWkdMjtyGBHulBQyEZXUdeCI2GZnmsqB8Rny394u8ztk8y"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
            
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            println("success")
            var authUrl = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authUrl!)
            
            }) { (error: NSError!) -> Void in
                println("Failed to get Request Token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
            println("Tweets \(tweets)")
            
            for tweet in tweets {
                println("Tweet \(tweet.text) created: \(tweet.createdAt)")
            }
            
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("Error with operation \(operation)")
                completion(tweets: nil, error: error)
        })
    }
    
    func favorite(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        
        POST("/1.1/favorites/create.json", parameters: ["id": tweet.id!], success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                 var tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("Error with operation \(operation)")
                completion(tweet: nil, error: error)
        })
    }
    
    func unFavorite(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        
        POST("/1.1/favorites/destroy.json", parameters: ["id": tweet.id!], success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            var tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("Error with operation \(operation)")
                completion(tweet: nil, error: error)
        })
    }
    
    func retweet(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("/1.1/statuses/retweet/\(tweet.id!).json", parameters: ["id": tweet.id!], success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            var retweet = response as! NSDictionary
            var tweet = Tweet(dictionary: retweet["retweeted_status"] as! NSDictionary)
            tweet.retweetId = response["id"] as? Int
            
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("Error with operation \(operation)")
                completion(tweet: nil, error: error)
        })
    }
    
    func unRetweet(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        if let id = tweet.retweetId {
            POST("/1.1/statuses/destroy/\(tweet.retweetId!).json", parameters: ["id": tweet.id!], success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var retweet = response as! NSDictionary
                var tweet = Tweet(dictionary: retweet["retweeted_status"] as! NSDictionary)
                completion(tweet: tweet, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    println("Error with operation \(operation)")
                    completion(tweet: nil, error: error)
            })
        }
    }
    
    func reply(tweet: Tweet, status: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = ["in_reply_to_status_id": tweet.id!, "status": status]
        sendTweet(params, completion: completion)
    }
    
    func tweet(status: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        sendTweet(["status": status], completion: completion)
    }
    
    private func sendTweet(params: NSDictionary, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("/1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            var tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("Error with operation \(operation)")
                completion(tweet: nil, error: error)
        })
    }
    
    func openUrl(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query) , success: { (accessToken: BDBOAuth1Credential!) -> Void in
            println("Got Access Token")
            self.requestSerializer.saveAccessToken(accessToken)
            
            self.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                
                var user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                println("User: \(user.name)")
                 self.loginCompletion?(user: user, error: nil)
                
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    println("Error getting Current User")
                    self.loginCompletion?(user: nil, error: error)
            })
            

            }) { (error: NSError!) -> Void in
                println("Error fetching Access Token")
                self.loginCompletion?(user: nil, error: error)
        }
        
    }
   
}
