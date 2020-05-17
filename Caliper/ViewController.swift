//
//  ViewController.swift
//  Caliper
//
//  Created by Kyle on 2020/5/6.
//  Copyright © 2020 kyle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellow
        title = "Caliper"
        
        let button = UIButton.init()
        button.setTitle("button", for: UIControl.State.normal)
        button.backgroundColor = .red
        view.addSubview(button)
        button.clp.makeConstraint { (make) in
            make.left.equalTo(100)
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.centerY.equalTo(100)
        }
    }

}

