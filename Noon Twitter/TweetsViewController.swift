//
//  TweetsViewController.swift
//  Noon Twitter
//
//  Created by Dhiraj Jadhao on 09/11/16.
//  Copyright © 2016 Dhiraj Jadhao. All rights reserved.
//

import UIKit
import SafariServices

class TweetsViewController: UIViewController {

    //MARK: Constants

    let cellIdentifier = "cell"
    let estimatedRowHeight:CGFloat = 100
    let appTintColor = UIColor(colorLiteralRed: 0, green: 153.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    let offlineStatusTitle = "The Internet connection appears to be offline"
    let offlineStatusMessage = "Connect to internet and try again"
    let welcomeStatusTitle = "Welcome to Noon twitter demo"
    let welcomeStatusMessage = "What do you want to search today"
    let emptyResultTitle = "Twitter couldn't find anything for your search"
    let emptyResultMessage = "Try searching something else"
    let nothingToLoadTitle = "We are caught up"
    let nothingToLoadMessage = "There are no more tweets to load!"
    
    
    
    
    
    // MARK: Properties
    
    let tweetViewModel = TweetViewModel()
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var refreshControl = UIRefreshControl()
    var bottomActivity = UIActivityIndicatorView()
    var newTweetButton = UIButton()
    var isPulledRefrsed = Bool()
    
    
    
    
    
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
    



    //MARK: UI Methods
    
    func setupUI() -> Void {
        
        
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        newTweetButton = UIButton(frame: CGRect(x: 0, y: -50, width: 110, height: 30))
        newTweetButton.backgroundColor = appTintColor
        newTweetButton.layer.cornerRadius = 14
        newTweetButton.layer.masksToBounds = true
        newTweetButton.center.x = self.view.frame.width/2.0
        newTweetButton.titleLabel?.textAlignment = NSTextAlignment.center
        newTweetButton.setTitle("↑ New Tweets", for: UIControlState.normal)
        newTweetButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        newTweetButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.5)
        newTweetButton.addTarget(self, action: #selector(newTweetsButtonTapped), for: UIControlEvents.touchDown)
        
        self.view.addSubview(newTweetButton)
        
        bottomActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        bottomActivity.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        

        let button = UIButton(frame: CGRect(x: 0, y: 7, width: 70, height: 28))
            button.titleLabel?.text = "Test Button"
        button.center.x = view.frame.width/2
        button.setImage(#imageLiteral(resourceName: "twitter-logo-blue"), for: UIControlState.normal)
        button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        button.addTarget(self, action: #selector(scrollToTop), for: UIControlEvents.touchDown)
        self.navigationController?.navigationBar.addSubview(button)
        
        updateTableStatusWith(title: welcomeStatusTitle, message: welcomeStatusMessage, onHeader: true)
    }
    
    
    
    
    
    func showNewTweetsLabel() -> Void {
        
        
        let beforeRowCount = tableView.numberOfRows(inSection: 0)
        
        let beforeVisibleFirstCellIndexPath = tableView.indexPath(for: tableView.visibleCells.first!)
        
        tableView.reloadData()
        
        let afterRowCount = tweetViewModel.sharedAppDelegate.tweets.count
        
        let newlyAddedRowCount = afterRowCount-beforeRowCount
        
        let updatedIndexPathForBeforeCell = NSIndexPath(row: (beforeVisibleFirstCellIndexPath?.row)!+newlyAddedRowCount, section: 0)
        
        tableView.scrollToRow(at: updatedIndexPathForBeforeCell as IndexPath, at: UITableViewScrollPosition.top, animated: false)
        
        
     
        if !isNewTweetsVisible() && !tableView.isDragging && !searchBar.isFirstResponder{
 
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.newTweetButton.frame.origin.y = 50
                
                }, completion: nil)
        }

    }
    
    
    
    
    func hideNewTweetsButton() -> Void {
        
        UIView.animate(withDuration: 1.0, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.newTweetButton.frame.origin.y = -50
            
            }, completion: nil)
    }
    
    
    
    func isNewTweetsVisible() -> Bool {
        
        if newTweetButton.frame.origin.y == 50 {
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
    
    
    
    
    func updateTableStatusWith(title:String, message:String, onHeader: Bool) -> Void{
        
        let statusView = UIView(frame: CGRect(x: 0, y: 0, width: searchBar.bounds.width - 15, height: 50))
        statusView.center.x = searchBar.bounds.width/2.0
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: statusView.frame.width, height: 25))
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.adjustsFontSizeToFitWidth = true
        
        let subTitleLabel = UILabel(frame: CGRect(x: 0, y: 22, width: statusView.frame.width, height: 20))
        subTitleLabel.text = message
        subTitleLabel.font = UIFont.systemFont(ofSize: 14)
        subTitleLabel.textAlignment = NSTextAlignment.center
        subTitleLabel.adjustsFontSizeToFitWidth = true
        subTitleLabel.textColor = UIColor.lightGray
        
        
        statusView.addSubview(titleLabel)
        statusView.addSubview(subTitleLabel)
        
        onHeader ? (tableView.tableHeaderView = statusView):(tableView.tableFooterView = statusView)
    }
    
    
    
    
    func hideTableHeaderStatusMessage() -> Void {
        tableView.tableHeaderView = nil
    }
    
    func hideTableFooterStatusMessage() -> Void {
        tableView.tableFooterView = nil
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
        isPulledRefrsed = true
        tweetViewModel.fetchNewTweetsForCurrentQuery()
    }
    
    
    
    func newTweetsButtonTapped() -> Void {
        
        scrollToTop()
        hideNewTweetsButton()
    }
    
    
    
    func scrollToTop() -> Void {
        if tableView.numberOfRows(inSection: 0) > 0{
            tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    
    
}


extension TweetsViewController: UISearchBarDelegate{
    

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        
    }
    
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = false
        hideNewTweetsButton()
        searchBar.resignFirstResponder()
        
        if searchBar.text != "" {
            tweetViewModel.sharedAppDelegate.tweets.removeAll()
            tableView.reloadData()
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
            refreshControl.beginRefreshing()
            tweetViewModel.searchTwitterFor(query: searchBar.text!)
        }
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
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
    
    

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if isNewTweetsVisible(){
            hideNewTweetsButton()
        }
    }
    
    
}


extension TweetsViewController: TweetViewModelDelegate{
    
    func didFinishSearchingWithError(error: AnyObject?) {
        
        if error?.code == NSURLErrorNotConnectedToInternet{
            updateTableStatusWith(title: offlineStatusTitle, message: offlineStatusMessage, onHeader: true)
            
        }else if error as? fetchError == fetchError.NoNextTweetsURL{
            hideBottomRefresh()
            updateTableStatusWith(title: nothingToLoadTitle, message: nothingToLoadMessage, onHeader: false)
            
        }
        else{
            refreshControl.endRefreshing()
            hideBottomRefresh()
            hideTableHeaderStatusMessage()
            hideTableFooterStatusMessage()
            self.tableView.reloadData()
            if tweetViewModel.sharedAppDelegate.tweets.count == 0{
                updateTableStatusWith(title: emptyResultTitle, message: emptyResultMessage, onHeader: true)
            }
        }
        
    }
    
    
    
    func didFinishFetchingNextTweetsWithError(error: AnyObject?) {
        
        if error?.code == NSURLErrorNotConnectedToInternet{
            updateTableStatusWith(title: offlineStatusTitle, message: offlineStatusMessage, onHeader: true)
            
        }else if error as? fetchError == fetchError.NoNextTweetsURL{
            hideBottomRefresh()
            updateTableStatusWith(title: nothingToLoadTitle, message: nothingToLoadMessage, onHeader: false)
            
        }else{
            refreshControl.endRefreshing()
            hideBottomRefresh()
            hideTableHeaderStatusMessage()
            hideTableFooterStatusMessage()
            self.tableView.reloadData()
            
            if tweetViewModel.sharedAppDelegate.tweets.count == 0{
                updateTableStatusWith(title: emptyResultTitle, message: emptyResultMessage, onHeader: true)
            }
        }
        
    }
    
    
    
    func newTweetsAvailable(available: Bool) {
        
        if available && !isPulledRefrsed{
            print("New Tweets Available")
            showNewTweetsLabel()
        }else{
            isPulledRefrsed = false
            tableView.reloadData()
        }
        refreshControl.endRefreshing()
        
    }
    
}
