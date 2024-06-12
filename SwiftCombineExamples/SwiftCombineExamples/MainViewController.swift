//
//  MainViewController.swift
//  SwiftCombineExamples
//
//  Created by Andrei Ionescu on 12.06.2024.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet var justButton: UIButton!
    @IBOutlet var networkButton: UIButton!
    @IBOutlet var passthroughButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showNetworkRequest" {
            let destinationVC = segue.destination as! NetworkRequestVC
            destinationVC.title = "NetworkRequestVC"
        } else if segue.identifier == "showJustEmptyFailFuture" {
            let destinationVC = segue.destination as! JustEmptyFailFutureVC
            destinationVC.title = "JustEmptyFailFutureVC"
        } else if segue.identifier == "showPasstrhoughCurrentValueSubjectsVC" {
            let destinationVC = segue.destination as! PasstrhoughCurrentValueSubjectsVC
            destinationVC.title = "PasstrhoughCurrentValueSubjectsVC"
        }
    }

}

