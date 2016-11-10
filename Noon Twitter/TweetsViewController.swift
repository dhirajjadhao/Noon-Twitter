//
//  TweetsViewController.swift
//  Noon Twitter
//
//  Created by Dhiraj Jadhao on 09/11/16.
//  Copyright © 2016 Dhiraj Jadhao. All rights reserved.
//

import UIKit
import PMAlertController
import SafariServices

class TweetsViewController: UIViewController {

    //MARK: Constants

    let cellIdentifier = "cell"
    let estimatedRowHeight:CGFloat = 100
    let appTintColor = UIColor(colorLiteralRed: 0, green: 153.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    
    // MARK: Properties
    
    let tweetViewModel = TweetViewModel()
    
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var refreshControl = UIRefreshControl()
    var bottomActivity = UIActivityIndicatorView()
    var newTweetLabel = UILabel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tweetViewModel.delegate = self
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: UI Methods
    
    func setupUI() -> Void {
        
        
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        newTweetLabel = UILabel(frame: CGRect(x: 0, y: -50, width: 110, height: 30))
        newTweetLabel.backgroundColor = appTintColor
        newTweetLabel.layer.cornerRadius = 14
        newTweetLabel.layer.masksToBounds = true
        newTweetLabel.center.x = self.view.frame.width/2.0
        newTweetLabel.textAlignment = NSTextAlignment.center
        newTweetLabel.text = "↑ New Tweets"
        newTweetLabel.textColor = UIColor.white
        newTweetLabel.font = UIFont.systemFont(ofSize: 12.5)
        newTweetLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newTweetsLabelTapped))
        newTweetLabel.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(newTweetLabel)
        
        bottomActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        bottomActivity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        

        let button = UIButton(frame: CGRect(x: 0, y: 7, width: 70, height: 28))
            button.titleLabel?.text = "Test Button"
        button.center.x = view.frame.width/2
        button.setImage(#imageLiteral(resourceName: "twitter-logo-blue"), for: UIControlState.normal)
        button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        button.addTarget(self, action: #selector(scrollToTop), for: UIControlEvents.touchDown)
        self.navigationController?.navigationBar.addSubview(button)
        
    }
    
    
    func showNewTweetsLabel() -> Void {
        
        
        let beforeRowCount = tableView.numberOfRows(inSection: 0)
        
        let beforeVisibleFirstCellIndexPath = tableView.indexPath(for: tableView.visibleCells.first!)
        
        tableView.reloadData()
        
        let afterRowCount = tweetViewModel.sharedAppDelegate.tweets.count
        
        let newlyAddedRowCount = afterRowCount-beforeRowCount
        
        let updatedIndexPathForBeforeCell = NSIndexPath(row: (beforeVisibleFirstCellIndexPath?.row)!+newlyAddedRowCount, section: 0)
        
        tableView.scrollToRow(at: updatedIndexPathForBeforeCell as IndexPath, at: UITableViewScrollPosition.top, animated: false)
        
        
     
        if !isNewTweetsVisible() && !tableView.isDragging{
 
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.newTweetLabel.frame.origin.y = 50
                
                }, completion: nil)
        }

    }
    
    
    func hideNewTweetsLabel() -> Void {
        
        UIView.animate(withDuration: 1.0, delay: 0.8, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.newTweetLabel.frame.origin.y = -50
            
            }, completion: nil)
    }
    
    func isNewTweetsVisible() -> Bool {
        
        if newTweetLabel.frame.origin.y == 50 {
            return true
        }else{
            return false
        }
    }
    
    
    func showBottomRefresh() -> Void {
        bottomActivity.startAnimating()
        tableView.tableFooterView = bottomActivity
    }
    
    
    func hideBottomRefresh() -> Void {
        
        bottomActivity.startAnimating()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    
    //MARK: Button Actions
    
    @IBAction func settingsButtonPressed(_ sender: AnyObject) {
        
                
        let actionSheet = UIAlertController(title: "Auto Refresh", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.view.tintColor = appTintColor

        
        let offAction = UIAlertAction(title: (tweetViewModel.currentRefreshStatus == refreshStatus.off) ? "\(refreshStatus.off.rawValue) ✓":refreshStatus.off.rawValue, style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.tweetViewModel.currentRefreshStatus = refreshStatus.off
            self.tweetViewModel.disableAutoRefresh()
        }
        
        let twoSecAction = UIAlertAction(title: (tweetViewModel.currentRefreshStatus == refreshStatus.twoSec) ? "\(refreshStatus.twoSec.rawValue) ✓":refreshStatus.twoSec.rawValue, style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.tweetViewModel.currentRefreshStatus = refreshStatus.twoSec
            self.tweetViewModel.enableAutoRefresh()
        }
        
        let fiveSecAction = UIAlertAction(title: (tweetViewModel.currentRefreshStatus == refreshStatus.fiveSec) ? "\(refreshStatus.fiveSec.rawValue) ✓":refreshStatus.fiveSec.rawValue, style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.tweetViewModel.currentRefreshStatus = refreshStatus.fiveSec
            self.tweetViewModel.enableAutoRefresh()
        }
        
        let thirtySecAction = UIAlertAction(title: (tweetViewModel.currentRefreshStatus == refreshStatus.thirtySec) ? "\(refreshStatus.thirtySec.rawValue) ✓":refreshStatus.thirtySec.rawValue, style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.tweetViewModel.currentRefreshStatus = refreshStatus.thirtySec
            self.tweetViewModel.enableAutoRefresh()
        }
        
        let oneMinAction = UIAlertAction(title: (tweetViewModel.currentRefreshStatus == refreshStatus.oneMin) ? "\(refreshStatus.oneMin.rawValue) ✓":refreshStatus.oneMin.rawValue, style: UIAlertActionStyle.default) { (UIAlertAction) in
            self.tweetViewModel.currentRefreshStatus = refreshStatus.oneMin
            self.tweetViewModel.enableAutoRefresh()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        
        actionSheet.addAction(offAction)
        actionSheet.addAction(twoSecAction)
        actionSheet.addAction(fiveSecAction)
        actionSheet.addAction(thirtySecAction)
        actionSheet.addAction(oneMinAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    //MARK: Update Methods
    
    func pulledToRefresh() -> Void {
        tweetViewModel.fetchNewTweetsForCurrentQuery()
    }
    
    func newTweetsLabelTapped() -> Void {
        
        scrollToTop()
        hideNewTweetsLabel()
    }
    
    func scrollToTop() -> Void {
        if tableView.numberOfRows(inSection: 0) > 0{
            tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
}


extension TweetsViewController: UISearchBarDelegate{
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        if searchBar.text != "" {
            
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
            refreshControl.beginRefreshing()

            tweetViewModel.searchTwitterFor(query: searchBar.text!)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweetViewModel.sharedAppDelegate.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TweetCell
        
        let tweet = tweetViewModel.sharedAppDelegate.tweets[indexPath.row]
        
        let nameString = "\(tweet.nameText!) "
        let handletimeString = "@\(tweet.handleText!) ∙ \(tweet.createdAtText!)"
        let attributedString = NSMutableAttributedString(string:nameString)
        
        let attrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName : UIColor.darkGray]
        let attributedHandletimeString = NSMutableAttributedString(string:handletimeString, attributes:attrs)
        attributedString.append(attributedHandletimeString)
        
        let combinedString = attributedString

        cell.titleLabel.attributedText = combinedString
        cell.bodyLabel.text = tweet.bodyText
        cell.retweetCountLabel.text = tweet.retweetCountText!
        cell.likeCountLabel.text = tweet.likeCountText!
        

        let url = URL(string: tweet.profileImageURL!)!
        //cell.profileImageView.af_setImage(withURL: url)
        cell.profileImageView.af_setImage(
            withURL: url,
            placeholderImage: UIImage(named: "placeholder"),
            imageTransition: .crossDissolve(0.2)
        )
        
        cell.bodyLabel.handleHashtagTap { (hashtag) in
            
            let query = "#\(hashtag)"
            self.searchBar.text = query
            
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
            self.refreshControl.beginRefreshing()
            
            self.tweetViewModel.searchTwitterFor(query: query)
            self.tweetViewModel.clearAllPreviousQueryData()
            self.hideBottomRefresh()
            tableView.reloadData()
        }
        
        cell.bodyLabel.handleMentionTap { (mention) in
            
            let query = "@\(mention)"
            self.searchBar.text = query
            
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
            self.refreshControl.beginRefreshing()
            
            self.tweetViewModel.searchTwitterFor(query: query)
            self.tweetViewModel.clearAllPreviousQueryData()
            tableView.reloadData()
        }
        
        cell.bodyLabel.handleURLTap { (URL) in
            
            let svc = SFSafariViewController(url: URL, entersReaderIfAvailable: true)
            self.present(svc, animated: true, completion: nil)
        
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == (tweetViewModel.sharedAppDelegate.tweets.count-1) {
            showBottomRefresh()
            tweetViewModel.fetchNextTweetsForCurrentQuery()
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
 
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if isNewTweetsVisible(){
            hideNewTweetsLabel()
        }
    }
    
}


extension TweetsViewController: TweetViewModelDelegate{
    
    func didFinishSearchingWithError(error: AnyObject?) {
        
        refreshControl.endRefreshing()
        hideBottomRefresh()
        self.tableView.reloadData()
    }
    
    func didFinishFetchingNextTweetsWithError(error: AnyObject?) {
        
        refreshControl.endRefreshing()
        hideBottomRefresh()
        self.tableView.reloadData()
    }
    
    func newTweetsAvailable(available: Bool) {
        
        if available{
            print("New Tweets Available")
            showNewTweetsLabel()
            refreshControl.endRefreshing()
    
            
        }else{
            refreshControl.endRefreshing()
        }
        
    }
    
}
