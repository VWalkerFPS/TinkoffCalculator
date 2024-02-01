//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Dmitrii on 31.01.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonTitle = sender.currentTitle else { return }
        print(buttonTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("APP LAUNCHED")
        
    }
}

