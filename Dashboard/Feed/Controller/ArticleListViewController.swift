//
//  ArticleListViewController.swift
//  Dashboard
//
//  Created by IPH Technologies Pvt. Ltd. on 08/06/23.
//

import UIKit
import Hero
class ArticleListViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var articleListCollectionView: UICollectionView!
    
    // MARK: Variables
    var blogList = [BlogDetailModel]()
    let dateFormatter = DateFormatter()
    var estimatedReadingTime: Int?
    let deviceType = UIDevice().name

    override func viewDidLoad() {
        super.viewDidLoad()
        articleListCollectionView.dataSource = self
        articleListCollectionView.delegate = self
        let anonymousFunction = {(fetchedBlogDetail: [BlogDetailModel]) in
            DispatchQueue.main.async {
                self.blogList = fetchedBlogDetail
                self.articleListCollectionView.reloadData()
            }
        }
        APICall.shared.fetchDataFromApi(onCompletion: anonymousFunction)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //for transition animation
        enableHero()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //for transition animation
        disableHero()
    }
    
    func dateFormat(dateFetched: String) -> String{
        var tempStr = " "
        for chr in dateFetched{
            if chr != " "{
                tempStr = "\(tempStr)\(chr)"
            }
            else{
                break
            }
        }
        return tempStr
    }
    
    func wordCount(str: String) -> Int{
        //.components function returns an array
        let components = str.components(separatedBy: .whitespacesAndNewlines)
        //removes empty strings from components array.
        let words = components.filter { !$0.isEmpty }
        return words.count
    }
    
    func timeToReadBlog(boldText: String, normalText: String, label: UILabel){
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .bold)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        let normalString = NSMutableAttributedString(string:normalText)
        attributedString.append(normalString)
        DispatchQueue.main.async {
            label.attributedText = attributedString
        }
    }
    //for formatting the blog image url fetched from the API
    func stringFormatter(blogRelatedUrl: String) -> String{
        let start = blogRelatedUrl.index(blogRelatedUrl.startIndex, offsetBy: 8)
        let end = blogRelatedUrl.index(blogRelatedUrl.startIndex, offsetBy: blogRelatedUrl.count-3)
        let range = start...end
        let newBlogRelatedURLFetched = String(blogRelatedUrl[range])
        print(newBlogRelatedURLFetched)
        return newBlogRelatedURLFetched
    }
}

extension ArticleListViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blogList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = articleListCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ArticleListCollectionViewCell
        cell.titleBlogLabel.text = (blogList[indexPath.row].blogTitle)?.capitalized
        if deviceType.contains("iPad") {
            cell.titleBlogLabel.font = UIFont.boldSystemFont(ofSize: 38)
            cell.dateOfPublishLabel.font = UIFont.boldSystemFont(ofSize: 17)
            cell.estimatedTimeToReadBlogLabel.font = UIFont.boldSystemFont(ofSize: 17)
        }
        cell.dateOfPublishLabel.text = dateFormat(dateFetched: blogList[indexPath.row].blogDate!)
        let headingWordCount = wordCount(str: blogList[indexPath.row].blogTitle!)
        let contentWordCount = wordCount(str: blogList[indexPath.row].blogContent!)
        let time = Double(headingWordCount + contentWordCount)/200.0
        //multiplied by 100 and then divided the result by 100 to get number till 2 dp
        estimatedReadingTime = Int(ceil(Double(round(time * 100) / 100)*60.0))
        cell.estimatedTimeToReadBlogLabel.text = "\(estimatedReadingTime!) sec for reading"
        timeToReadBlog(boldText: "\(estimatedReadingTime!) sec", normalText: " for reading", label: cell.estimatedTimeToReadBlogLabel)
        //print("\(blogList[indexPath.row].blogFeaturedImgURL)")
        let blogImageUrlFetched = "\(blogList[indexPath.row].blogFeaturedImgURL)"
        if let url = URL(string: "\(stringFormatter(blogRelatedUrl: blogImageUrlFetched))"){
            cell.blogImageView?.loadImage(from: url)
        }
        cell.heroID = nil
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("selected section \(indexPath.section) and row \(indexPath.row)")
        if let vc = storyboard?.instantiateViewController(identifier: "ArticleDetailViewController") as? ArticleDetailViewController {
            let cell = articleListCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ArticleListCollectionViewCell
            let blogDetailsFetched = blogList[indexPath.row]
            let blogImgURLFetched = "\(blogList[indexPath.row].blogFeaturedImgURL)"
            if let url = URL(string: "\(stringFormatter(blogRelatedUrl: blogImgURLFetched))"){
                vc.url = url
                vc.shareBlogUrl = URL(string: "\(String(describing: blogList[indexPath.row].blogURL!))")
         }
            vc.titleOfBlog = blogDetailsFetched.blogTitle
            vc.contentBlog = blogDetailsFetched.blogContent
            //print(blogDetailsFetched.blogContent)
            vc.date = dateFormat(dateFetched: blogDetailsFetched.blogDate!)
            cell.heroID = "animTransition"
            showHero(vc)
        }
    }
}

extension ArticleListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.size.width-30, height:collectionView.frame.size.width-80)//300
    }
}
