//
//  ViewController.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/15/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLBuilder, NetworkHTTPCall {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ViewController.refresh))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc func refresh() {
//        let cacher = ImageCacher()
//        if let url = URL(string: textField.text ?? "") {
//            cacher.get(from: url) { (image) in
//                print(image)
//            }
//        }
        
        if let url = buildURL(with: "https://api.github.com",
                              pathParam: ["users"],
                              andQuery: ["since": String(describing: 0)]) {
            getAPIResponse(for: url) { [weak self] (success, response, error) in
//                var users = [User]()
//                if success, let data = response?.data, let parsedUsers = self?.getUsers(from: data) {
//                    users = self?.sort(users: parsedUsers) ?? []
//                    self?.saveLastId(from: users)
//                }
//                shouldRefresh ? self?.presenter?.show(users: users) : self?.presenter?.append(users: users)
            }
        }
        
    }
}

