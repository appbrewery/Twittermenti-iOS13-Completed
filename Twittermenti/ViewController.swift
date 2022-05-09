//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import Swifter
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
        
    let sentimentClassfier = try! TweetSentimentClassifier(configuration: MLModelConfiguration())
    
    let swifter = Swifter(consumerKey: "_your_key_here", consumerSecret: "_your_secret_here_")

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
    
        fetchTweets()
        
    }
    
    func fetchTweets() {
        
        if let searchText = textField.text {
            
            swifter?.searchTweet(using: searchText, lang: "en", count: tweetCount, success: { (results, searchMetadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<tweetCount {
                if let tweet = results[i]["text"].string{
                    
                    let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                    tweets.append(tweetForClassification)
                }
                }
                
                self.makePredictions(with: tweets)
            
            }, failure: { error in
                print("There was an error with the TWITTER API Request,\(error)")
            })
        }

        
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        
        do {
            
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions {
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            
            updateUI(with: sentimentScore)
            
        } catch {
            print("There was an error with making a prediction, \(error)")
        }
        
    }
    
    func updateUI(with sentimentScore: Int) {
        
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
    
}


