//
//  PasstrhoughCurrentValueSubjectsVC.swift
//  SwiftCombineExamples
//
//  Created by Andrei Ionescu on 12.06.2024.
//

import UIKit
import Combine

class PasstrhoughCurrentValueSubjectsVC: UIViewController {
    @IBOutlet var passthroughLabel: UILabel!
    @IBOutlet var currentValueLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showNextScreenVC" {
            let destinationVC = segue.destination as! NextScreenVC
            destinationVC.title = "NextScreenVC"
            setupNextScreenBindings(vc: destinationVC)
        }
    }
    
    private func setupNextScreenBindings(vc: NextScreenVC) {
        vc.tappedButtonSubject.receive(on: DispatchQueue.main).sink { [unowned self] newValue in
            passthroughLabel.text = newValue
            passthroughLabel.textColor = .magenta
        }.store(in: &cancellables)
        
        vc.changedTextSubject.receive(on: DispatchQueue.main).dropFirst().sink { [unowned self] newString in
            currentValueLabel.text = newString
            currentValueLabel.textColor = .magenta
        }.store(in: &cancellables)
    }
}


class NextScreenVC: UIViewController, UITextFieldDelegate {
    @IBOutlet var tapMeButton: UIButton!
    @IBOutlet var textField: UITextField!
    
    var tappedButtonSubject = PassthroughSubject<String, Never>()
    var changedTextSubject = CurrentValueSubject<String, Never>("")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        tapMeButton.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = textField.text ?? ""
        let newText = textFieldText + string
        changedTextSubject.send(newText)
        return true
    }
    
    @objc private func tappedButton() {
        tappedButtonSubject.send("Text was changed from the other screen! :)")
    }
}
