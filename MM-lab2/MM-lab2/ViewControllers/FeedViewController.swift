//
//  FeedViewController.swift
//  MM-lab2
//
//  Created by Firuza on 28.02.2025.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let feedSystem = FeedSystem()
    private var popupView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSamplePosts()
        setupAddPostButton()
    }

    private func setupUI() {
        title = "NEWS"
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PostCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupAddPostButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openAddPost)
        )
    }

    @objc private func openAddPost() {
        let users = Array(Set(feedSystem.getPosts().map { $0.author })) // Убираем дубликаты
        let addPostVC = AddPostViewController(feedSystem: feedSystem, users: users) {
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(addPostVC, animated: true)
    }

    private func loadSamplePosts() {
        let user1 = UserProfile(id: "1", username: "azamat", bio: "Ios best of the best tool чтобы зарабатывать миллионы", profileImageURL: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_ihrIlpWf0sNKe2gHjsr7rjacBhnRlxwTdg&s"))
        let user2 = UserProfile(id: "2", username: "begimai", bio: "ничго интересного: я и моя жизнь", profileImageURL: URL(string: "https://i.pinimg.com/736x/22/37/37/2237378e3ca714e1073b709207878c88.jpg"))
        let user3 = UserProfile(id: "3", username: "dameliya", bio: "модель", profileImageURL: URL(string: "https://whitefox-agency.ru/files/whitefoxagencyru/reg_images/2609-m_.jpg"))

        let post1 = Post(id: UUID(), author: user1, hashtags: ["internship", "ios"], content: "loveEat!")
        let post2 = Post(id: UUID(), author: user2, hashtags: ["blog", "travel"], content: "New york luche vseh")
        let post3 = Post(id: UUID(), author: user3, hashtags: ["cooking", "carrot"], content: "kithen chiken")

        feedSystem.addPost(post1)
        feedSystem.addPost(post2)
        feedSystem.addPost(post3)

        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedSystem.getPosts().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        let post = feedSystem.getPosts()[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        let hashtags = post.hashtags.isEmpty ? "" : " #" + post.hashtags.joined(separator: " #")
        cell.textLabel?.text = "@\(post.author.username): \(post.content)\(hashtags)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = feedSystem.getPosts()[indexPath.row]
        showPostPopup(post: post)
    }

    private func showPostPopup(post: Post) {
        popupView?.removeFromSuperview()

        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 15
        popupView.layer.shadowOpacity = 0.3
        popupView.layer.shadowRadius = 10
        popupView.translatesAutoresizingMaskIntoConstraints = false

        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 30
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        if let url = post.author.profileImageURL {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        profileImageView.image = image
                    }
                }
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }

        let label = UILabel()
        label.text = "@\(post.author.username)\n\n\(post.content)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Закрыть", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [profileImageView, label, closeButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        popupView.addSubview(stackView)
        view.addSubview(popupView)

        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            popupView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 300), // Начальное положение (за экраном)
            popupView.heightAnchor.constraint(equalToConstant: 300),

            stackView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -10),

            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
        ])

        self.popupView = popupView

        // Анимация появления снизу
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            popupView.transform = CGAffineTransform(translationX: 0, y: -320)
        }
    }

    @objc private func dismissPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popupView?.transform = .identity
        }) { _ in
            self.popupView?.removeFromSuperview()
        }
    }
}
