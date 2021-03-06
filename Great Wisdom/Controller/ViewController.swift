//
//  ViewController.swift
//  Great Wisdom
//
//  Created by ACS on 16.02.2021.
//

import SideMenu
import UIKit
import Firebase

class ViewController: UIViewController, SideMenuControllerDelegate {
    @IBOutlet var quoteText: UILabel!
    @IBOutlet var authorText: UILabel!
    @IBOutlet weak var nextButton: UIImageView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var randomButton: UIImageView!
    
    private var sideMenu: CustomSideMenuNavigationController?
    private let aboutViewController = AboutViewController()
    
    let db = Firestore.firestore()
    var quotes: [QuoteModel] = []
    var quoteOrder = 0
    
    
    private func addChildControllers() {
        addChild(aboutViewController)
        view.addSubview(aboutViewController.view)
        aboutViewController.view.frame = view.bounds
        aboutViewController.didMove(toParent: self)
        aboutViewController.view.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        nextButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextQuote)))
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backQuote)))
        randomButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.randomQuote)))
        
        let menuController = SideMenuController()
        menuController.delegate = self
        sideMenu = CustomSideMenuNavigationController(rootViewController: menuController)
        
        addChildControllers()
        
        loadQuotes()
    }
    
    @objc func nextQuote() {
        if quoteOrder == quotes.count-1 {
            quoteOrder = 0
        }else{
            quoteOrder += 1
        }
        changeQuote()
    }
    
    @objc func backQuote() {
        if quoteOrder == 0 {
            quoteOrder = quotes.count-1
        }else{
            quoteOrder -= 1
        }
        changeQuote()
    }
    
    @objc func randomQuote() {
        quoteOrder = Int.random(in: 0..<quotes.count)
        changeQuote()
    }
    
    func didSelectMenuItem(named: String) {
        sideMenu?.dismiss(animated: true, completion: {
            if named == kString_home.localize() {
                self.aboutViewController.view.isHidden = true
                self.title = named
            }else if named == kString_about.localize() {
                self.aboutViewController.view.isHidden = false
                self.title = named
            }else if named == kString_moreApps.localize() {
                self.performSegue(withIdentifier: kIdentifier_segue_toMoreApps, sender: self)
            }else {
                print("buldun")
                self.title = named
            }
        })
    }
    
    @IBAction func didTapMenuButton() {
        present(sideMenu!, animated: true)
    }
    
    func loadQuotes() {
        print(Locale.current.languageCode! as String)
        let collection = db.collection("quotes")
        
        collection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let authorInfo = data["author"] as? String {
                        if let quoteInfo = data[Locale.current.languageCode! as String] as? String {
                            let model = QuoteModel(quote: quoteInfo, author: authorInfo)
                            self.quotes.append(model)
                        }
                    }
                }
                self.changeQuote()
            }
        }
        
    }
    
    func changeQuote() {
        quoteText.text = quotes[quoteOrder].quote
        authorText.text = quotes[quoteOrder].author
    }
    
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: kIdentifier_segue_toSearch, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kIdentifier_segue_toSearch {
            let destinationVC = segue.destination as! SearchViewController
            destinationVC.mainData = quotes
        }
    }
}
