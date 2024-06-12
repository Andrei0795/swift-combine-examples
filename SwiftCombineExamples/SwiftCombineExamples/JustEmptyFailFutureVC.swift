//
//  JustEmptyFailFutureVC.swift
//  SwiftCombineExamples
//
//  Created by Andrei Ionescu on 12.06.2024.
//

import UIKit
import Combine

class JustEmptyFailFutureVC: UIViewController {
    
    @IBOutlet var justButton: UIButton!
    @IBOutlet var emptyButton: UIButton!
    @IBOutlet var failButton: UIButton!
    @IBOutlet var futureButton: UIButton!
    
    @IBOutlet var resultsValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        justButton.addTarget(self, action: #selector(justAction), for: .touchUpInside)
        emptyButton.addTarget(self, action: #selector(emptyAction), for: .touchUpInside)
        failButton.addTarget(self, action: #selector(failAction), for: .touchUpInside)
        futureButton.addTarget(self, action: #selector(futureAction), for: .touchUpInside)

    }
    
    //Actions
    @objc private func justAction() {
        self.resultsValueLabel.text = "This will change in 2 seconds"

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showJust()
        }
    }
    
    @objc private func emptyAction() {
        self.resultsValueLabel.text = "This will NOT change in 1 second"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showEmpty()
        }
    }
    
    
    @objc private func failAction() {
        self.resultsValueLabel.text = "An error shown at completion(not receivevalue) will be shown. 2 seconds."

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showFail()
        }
    }
    
    @objc private func futureAction() {
        self.resultsValueLabel.text = "An async future value will be shown after 2+1 seconds."

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showFuture()
        }
    }
    
    
    //Important
    /*
     When you use Combine's convenience methods like sink or assign, they create an internal subscriber for you and return an AnyCancellable that represents the subscription. This AnyCancellable allows you to manage the lifecycle of the subscription, typically by storing it in a set or an array to keep it alive as long as needed.

     */
    
    //It is a type of publisher provided by Combine that guarantees to emit exactly one value and then complete without errors.
    private func showJust() {
        let justPublisher = Just("Hello, Combine!")
        
        //Sink generates an internal subscriber
        let subscription = justPublisher
            .sink(receiveCompletion: { completion in
                print("Just Completed with: \(completion)")
            }, receiveValue: {[unowned self] value in
                print("Received value: \(value)")
                self.resultsValueLabel.text = "Received value: \(value)"
            })
        
        subscription.cancel()
    }
    
    //Empty is a publisher that completes immediately without producing any values.
    private func showEmpty() {
        let emptyPublisher = Empty<String, Never>()

        let subscription = emptyPublisher
            .sink(receiveCompletion: { completion in
                print("Empty Completed with: \(completion)")
            }, receiveValue: { value in
                print("Received value: \(value)")
                self.resultsValueLabel.text = "This should not happen"
            })
        
        subscription.cancel()
    }
    
    
    struct MyError: Error {
        var errorCode: Int = 404
    }
    
    //Fail is a publisher that immediately terminates with an error.
    private func showFail() {
        let failPublisher = Fail<String, MyError>(error: MyError())

        let subscription = failPublisher
            .sink(receiveCompletion: { [unowned self] completion in
                print("Completed with: \(completion)")
                switch completion {
                case .finished:
                    return
                case .failure(let failure):
                    self.resultsValueLabel.text = "No value but completed with error \(failure.errorCode)"
                }
            }, receiveValue: { value in
                print("Received value: \(value)")
                self.resultsValueLabel.text = "This should not happen"
            })
        
        subscription.cancel()
    }
    
    //Future is a publisher that eventually produces a single value and then finishes, or fails.
    var subscription: AnyCancellable?
    
    private func showFuture() {
        let futurePublisher = Future<String, Never> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                promise(.success("Hello from the future!"))
            }
        }
        
        //Must be received on main
        subscription = futurePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("Completed with: \(completion)")
            }, receiveValue: { [weak self] value in
                print("Received value: \(value)")
                self?.resultsValueLabel.text = "New async future value: \(value)"
                self?.cancelSubscription()
            })
        
        //subscription must be cancelled after the promose is fulfilled
        //subscription.cancel()
    }
    
    func cancelSubscription() {
        subscription?.cancel()
    }
}
