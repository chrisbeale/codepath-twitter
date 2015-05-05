//
//  TweetViewController.swift
//  Twitter
//
//  Created by Chris Beale on 4/30/15.
//  Copyright (c) 2015 Chris Beale. All rights reserved.
//

import UIKit

protocol TweetViewControllerDelegate :  class {
    func tweetViewController(vc: TweetViewController, tweetChanged tweet: Tweet)
}


class TweetViewController: UIViewController, ComposeViewControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var friendlyNameLabel: UILabel!
    @IBOutlet weak var twitterNameLabel: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    
    @IBOutlet weak var favoriteControl: UIButton!
    @IBOutlet weak var retweetControl: UIButton!
    @IBOutlet weak var replyControl: UIButton!
    
    weak var delegate: TweetViewControllerDelegate?
    
    var tweet: Tweet? {
        didSet {
            if let tweet = tweet {
                if let user = tweet.user {
                    profileImageView?.setImageWithURL(NSURL(string: user.profileImageUrl!))
                    friendlyNameLabel?.text = user.name
                    twitterNameLabel?.text = "@\(user.screenName!)"
                    tweetText?.text = tweet.text
                    favCountLabel?.text = "\(tweet.favCount!)"
                    retweetCountLabel?.text = "\(tweet.retweetCount!)"
                    favoriteControl?.selected = tweet.favorited!
                }
            }
        }
    }

    @IBAction func onRetweet(sender: AnyObject) {
        retweetControl.selected = !retweetControl.selected
        
        if retweetControl.selected {
            TwitterClient.sharedInstance.retweet(tweet!) {
                (tweet, error) -> () in
                if let tweet = tweet {
                    self.tweet = tweet
                    self.delegate?.tweetViewController(self, tweetChanged: self.tweet!)
                } else {
                    self.retweetControl.selected = !self.retweetControl.selected
                }
            } 
        } else {
            if let id = tweet?.retweetId {
                TwitterClient.sharedInstance.unRetweet(tweet!) {
                    (tweet, error) -> () in
                    if let tweet = tweet {
                        self.tweet = tweet
                        self.delegate?.tweetViewController(self, tweetChanged: self.tweet!)
                    } else {
                        self.retweetControl.selected = !self.retweetControl.selected
                    }
                }
            } else {
                retweetControl.selected = !self.retweetControl.selected
            }
        }
    }

    @IBAction func onFavorite(sender: AnyObject) {
        
        favoriteControl.selected = !favoriteControl.selected
        if let id = tweet?.id {
        
            if favoriteControl.selected {
                TwitterClient.sharedInstance.favorite(tweet!) {
                    (tweet: Tweet?, error: NSError?) in
                    if let tweet = tweet {
                        self.tweet = tweet
                        self.delegate?.tweetViewController(self, tweetChanged: tweet)
                    } else {
                        self.favoriteControl.selected = !self.favoriteControl.selected
                    }
                }
            } else {
                TwitterClient.sharedInstance.unFavorite(tweet!) {
                    (tweet: Tweet?, error: NSError?) in
                    if let tweet = tweet {
                        self.tweet = tweet
                        self.delegate?.tweetViewController(self, tweetChanged: tweet)
                    } else {
                        self.favoriteControl.selected = !self.favoriteControl.selected
                    }
                }
            }
        }
    }   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tweet = tweet {
            if let user = tweet.user {
                profileImageView?.setImageWithURL(NSURL(string: user.profileImageUrl!))
                friendlyNameLabel?.text = user.name
                twitterNameLabel?.text = "@\(user.screenName!)"
                tweetText?.text = tweet.text
                 favCountLabel?.text = "\(tweet.favCount!)"
                retweetCountLabel.text = "\(tweet.retweetCount!)"
                favoriteControl?.selected = tweet.favorited!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func composeViewController(viewController: ComposeViewController, tweetSent tweet: Tweet) {
        delegate?.tweetViewController(self, tweetChanged: tweet)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var nav = segue.destinationViewController as! UINavigationController
        var vc = nav.topViewController as! ComposeViewController
        vc.delegate = self;
        //vc.tweet = tweet
    }
    

}
