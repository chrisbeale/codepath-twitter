//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Chris Beale on 5/1/15.
//  Copyright (c) 2015 Chris Beale. All rights reserved.
//

import UIKit

protocol ComposeViewControllerDelegate : class
{
    func composeViewController(viewController: ComposeViewController, tweetSent tweet: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate{

    var tweet: Tweet?
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetText: UITextView!
    @IBOutlet weak var characterLabel: UILabel!
    
    weak var delegate: ComposeViewControllerDelegate?
    
    let maxCharacters = 140
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let user = User.currentUser {
            profileImageView.setImageWithURL(NSURL(string: user.profileImageUrl!))
            nameLabel.text = user.name
            screenNameLabel.text = user.screenName
        }
        
        characterLabel.text = "\(maxCharacters)"
        tweetText.becomeFirstResponder()
        tweetText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        characterLabel.text = "\(maxCharacters - count(tweetText.text))"
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return count(textView.text) - range.length + count(text) <= maxCharacters
        
    }

    @IBAction func OnTweet(sender: AnyObject) {

        if let tweet = tweet {
            TwitterClient.sharedInstance.reply(tweet, status: tweetText.text, completion: { (tweet, error) -> () in
                if let tweet = tweet {
                    self.delegate?.composeViewController(self, tweetSent: tweet)
                }
            })
        } else {
            TwitterClient.sharedInstance.tweet(tweetText.text, completion: { (tweet, error) -> () in
                if let tweet = tweet {
                    self.delegate?.composeViewController(self, tweetSent: tweet)
                }
            })
        }
        tweetText.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
