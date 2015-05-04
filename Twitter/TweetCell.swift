//
//  TweetCell.swift
//  Twitter
//
//  Created by Chris Beale on 4/30/15.
//  Copyright (c) 2015 Chris Beale. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var friendlyNameLabel: UILabel!
    @IBOutlet weak var twitterNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var replyButton: UIImageView!
    @IBOutlet weak var retweetButton: UIImageView!
    @IBOutlet weak var favouriteButton: UIImageView!
    
    var tweet: Tweet? {
        didSet {
            if let tweet = tweet {
                if let user = tweet.user {
                    profileImageView.setImageWithURL(NSURL(string: user.profileImageUrl!))
                    friendlyNameLabel.text = user.name
                    twitterNameLabel.text = "@\(user.screenName!)"
                    createdAtLabel.text = getCreatedAtString(tweet.createdAt!)
                    tweetText.text = tweet.text
                }
            }
        }
    }
    
    private func getCreatedAtString(date: NSDate) -> (String) {
        var createdAtString = ""
        let interval = date.timeIntervalSinceNow
        
        let ti = Int(interval) * -1
        let sec = ti % 60
        let min = (ti / 60) % 60
        let hours = (ti / 3600)
        
        if hours > 0 {
            createdAtString = "\(hours)h"
        } else if min > 0 {
            createdAtString = "\(min)m"
        } else {
            createdAtString = "\(sec)s"
        }
        return createdAtString
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
