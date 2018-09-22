//
//  ViewController.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/15/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLBuilder {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ViewController.refresh))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc func refresh() {
        let cacher = ImageCacher()
        if let url = URL(string: textField.text ?? "") {
            cacher.get(from: url) { (image) in
                print(image)
            }
        }
    }
}

