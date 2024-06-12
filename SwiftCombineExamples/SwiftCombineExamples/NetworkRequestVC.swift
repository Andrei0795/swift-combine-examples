//
//  NetworkRequestVC.swift
//  SwiftCombineExamples
//
//  Created by Andrei Ionescu on 12.06.2024.
//

import UIKit
import Combine

struct API {
    static func fetchData(url: URL) -> AnyPublisher<Data, URLError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}

struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPosts() -> AnyPublisher<[Post], Error> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class NetworkRequestVC: UIViewController {
    
    @IBOutlet var postsTextView: UITextView!
    @IBOutlet var descriptionLabel: UILabel!

    private var cancellables = Set<AnyCancellable>()
    private var posts = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = "The two labels below will load new text after 3 seconds based on a network request done using Combine!"
        postsTextView.isEditable = false
        postsTextView.sizeToFit()
        postsTextView.isScrollEnabled = true
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.fetchPosts()
        }
    }
    
    private func fetchPosts() {
         NetworkManager.shared.fetchPosts()
             .sink(receiveCompletion: { completion in
                 switch completion {
                 case .finished:
                     print("Finished fetching posts.")
                 case .failure(let error):
                     print("Failed to fetch posts: \(error)")
                 }
             }, receiveValue: { [weak self] posts in
                 self?.posts = posts
                 self?.updatePosts()
             })
             .store(in: &cancellables)
     }
    
    private func updatePosts() {
        guard posts.count > 0 else {
            postsTextView.text = "No posts to fetch"
            return
        }
        postsTextView.text = ""
        
        //Just the first 3 (0, 1, 2) is enough
        for index in 0..<3 {
            postsTextView.text += (String(format: "Title: %@ \n Body: %@\n\n", posts[index].title, posts[index].body))
        }
    }
}
