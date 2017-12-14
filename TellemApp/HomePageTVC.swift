//
//  HomePageTVC.swift
//  TellemApp
//
//  Created by Sean Bukich on 10/11/17.
//  Copyright © 2017 Sean Bukich. All rights reserved.
//

import UIKit

class HomePageTVC: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyWords = searchBar.text
        searchKeyword = (keyWords?.replacingOccurrences(of: " ", with: "+")) ?? "fake+news"
        self.getNewsAPI()
        self.view.endEditing(true)
    }
    
    @IBAction func searchButton(_ sender: Any) {

        searchArticleFilter()
        tableView.reloadData()
        searchAlert()
    }
    
    var phrase = ""

    func searchAlert() {
        let alert = UIAlertController(title: "Filter", message: "What are you looking for?", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Enter keyword"

        }

        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.phrase = (textField?.text!)!
            self.searchArticleFilter()
        }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    var filteredArticles : [Article] = []
    let item0 = ["engadget"]

    func searchArticleFilter() {
        filteredArticles = newsCategories.filter({$0.title.uppercased().contains(phrase.uppercased())})
        print(filteredArticles)
        tableView.reloadData()
    }
    var newsCategories : [Article] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getNewsAPI()
        searchBar.delegate = self
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

//        for i in item0 {
//            getNewsAPI(newsFile: i)
//
            tableView.register(UINib.init(nibName: "NewsContentTableViewCell", bundle: nil), forCellReuseIdentifier: "newsArticle") as? NewsContentTableViewCell
//        }
        if ConnectionCheck.isConnectedToNetwork() == true {
            print("Network Reachable")
        } else {
            print("Network Unreachable")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredArticles.isEmpty {
            return newsCategories.count
        } else {
            return filteredArticles.count
        }
       // return newsCategories.count
    }
    var searchKeyword: String = "fake+news"
    
    func getNewsAPI() {
        if ConnectionCheck.isConnectedToNetwork(){
            let myUrlString: String = "http://beta.newsapi.org/v2/everything?q="
            let apiKey: String = "&apiKey=63fea65d5bfd4f269b61455de1abd6f2"
            let search: String = myUrlString + searchKeyword + apiKey
            
            guard let myURL = URL(string: search) else{
                print("BigErrOrBoi")
                return
            }
            let task = URLSession.shared.dataTask(with: myURL) {
                (data, response, error) in
                print(data)
                if let err = error {
                    print(err, "Here is the error.")
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : AnyObject] {
                        if let articles = json["articles"] as? [[String: AnyObject]] {
                            print(articles)
                            self.newsCategories = []
                            for article in articles {
                                if let title = article["title"],
                                    var imageURL = article["urlToImage"],
                                    let articleURL = article["url"] {
                                    print(imageURL)
                                    print(articleURL, #line, "<<<<<<<<")
                                    if imageURL is NSNull {
                                        imageURL = "https://upload.wikimedia.org/wikipedia/commons/e/e0/JPEG_example_JPG_RIP_050.jpg" as AnyObject
                                    }
                                    self.newsCategories.append(Article(title: title as! String, imageURL: imageURL as! String, url: articleURL as! String))
                                } else {
                                    print("Error!!")
                                }
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                } catch {
                }
            }
            task.resume()
        } else {
            let thisAlert = UIAlertController(title: "No Internet Connection", message: "Get FiOS", preferredStyle: UIAlertControllerStyle.alert)
            thisAlert.addAction(UIAlertAction(title: "I Can Try", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(thisAlert,animated: true, completion: nil)
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsArticle", for: indexPath) as? NewsContentTableViewCell
        cell?.articleTitle.text = newsCategories[indexPath.row].title
        if filteredArticles.isEmpty {
            cell?.articleImage.downloadImageFrom(link: newsCategories[indexPath.row].imageURL)
        } else {
            cell?.articleImage.downloadImageFrom(link: filteredArticles[indexPath.row].imageURL)

        }
        let row = indexPath.row
        // add target gives a target. TouchUpInside then tells compiler to call the btnPress 
        cell?.shareButton.addTarget(self, action: #selector(btnPress), for: .touchUpInside)
        cell?.shareButton.tag = row
        
        cell?.articleTitle.numberOfLines = 0
        return cell!
    }
    
    @objc func btnPress(sender: UIButton!) {
        let activityVC = UIActivityViewController(activityItems: [self.newsCategories[sender.tag].url, self.newsCategories[sender.tag].imageURL, self.newsCategories[sender.tag].title], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "nextView", sender: newsCategories[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? ArticleContentViewController {
            if let newArticle = sender as? Article {
                newVC.webURL = newArticle.url
            }
        }
    }
}
extension UIImageView {
    func downloadImageFrom(link: String)  {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
            }
            DispatchQueue.main.async {
                self.image = nil
                self.contentMode =  UIViewContentMode.scaleAspectFill
                if let data = data {
                    self.image = UIImage(data: data)
                }
            }
        }).resume()
    }
}
