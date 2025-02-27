//
//  AddPostViewController.swift
//  MM-lab2
//
//  Created by Firuza on 28.02.2025.
//

import UIKit

class AddPostViewController: UIViewController {
    private let feedSystem: FeedSystem
    private let users: [UserProfile]
    private let completion: () -> Void
    
    private let userPicker = UIPickerView()
    private let contentTextView = UITextView()
    private let hashtagsTextField = UITextField()
    private var selectedUser: UserProfile?
    
    init(feedSystem: FeedSystem, users: [UserProfile], completion: @escaping () -> Void) {
        self.feedSystem = feedSystem
        self.users = users
        self.completion = completion
        self.selectedUser = users.first 
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Add Post"

        userPicker.dataSource = self
        userPicker.delegate = self

        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        contentTextView.layer.cornerRadius = 5
        contentTextView.translatesAutoresizingMaskIntoConstraints = false

        hashtagsTextField.placeholder = "Enter hashtags (comma separated)"
        hashtagsTextField.borderStyle = .roundedRect
        hashtagsTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Post", for: .normal)
        submitButton.addTarget(self, action: #selector(postNew), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [userPicker, contentTextView, hashtagsTextField, submitButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc private func postNew() {
        guard let user = selectedUser, let text = contentTextView.text, !text.isEmpty else { return }
        let hashtags = hashtagsTextField.text?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        
        let newPost = Post(id: UUID(), author: user, hashtags: hashtags, content: text)
        feedSystem.addPost(newPost)
        completion()
        navigationController?.popViewController(animated: true)
    }
}

extension AddPostViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return users.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return users[row].username
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUser = users[row]
    }
}
