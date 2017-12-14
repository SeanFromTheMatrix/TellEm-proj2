//
//  TwoPageTVC.swift
//  TellemApp
//
//  Created by Sean Bukich on 10/13/17.
//  Copyright © 2017 Sean Bukich. All rights reserved.
//

import UIKit

class TwoPageTVC: UITableViewController {
    
    var newsCategories : [Article] = []
//
    let item1 = ["techcrunch"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in item1 {
            getNewsAPI(newsFile: i)
            
            tableView.register(UINib.init(nibName: "NewsContentTableViewCell", bundle: nil), forCellReuseIdentifier: "newsArticle") 
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsCategories.count
    }
    
    func getNewsAPI(newsFile: String) {
        let myUrlString = "https://newsapi.org/v1/articles?source=\(newsFile)&sortBy=top&apiKey=63fea65d5bfd4f269b61455de1abd6f2"
        
        let myURL = URL(string: myUrlString)
        let task = URLSession.shared.dataTask(with: myURL!) {
            (data, response, error) in
            if let err = error {
                print(err, "Here is the error.")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : Any] {
                    if let articles = json["articles"] as? [[String: String]] {
                        for article in articles {
                            if let title = article["title"],
                                let imageURL = article["urlToImage"], let articleURL = article["url"] {
                                print(articleURL, #line, "<<<<<<<<")
                                self.newsCategories.append(Article(title: title, imageURL: imageURL, url: articleURL))
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
    }
    
    func getImages() {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsArticle", for: indexPath) as? NewsContentTableViewCell
        cell?.articleTitle.text = newsCategories[indexPath.row].title
        cell?.articleImage.downloadImageFrom1(link: newsCategories[indexPath.row].imageURL)
        cell?.articleTitle.numberOfLines = 0
        return cell!
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
    func downloadImageFrom1(link: String)  {
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

