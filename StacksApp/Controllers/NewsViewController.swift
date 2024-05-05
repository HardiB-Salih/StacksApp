//
//  TopStoriesNewsViewController.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/4/24.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    enum `Type` {
        case topStories
        case company(symbol: String)
        
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    
    let tableView: UITableView = {
        let table = UITableView()
        // Register a cell
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        
        table.backgroundColor = .clear
        return table
    }()
    
    //MARK: Properties
    private var stories = [NewsStory]()
    private let type : Type
    
    
    
    // MARK: -INIT
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -LifeSycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: -Private
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func fetchNews() {
        // Using [weak self] in a closure is primarily to prevent strong reference cycles, also known as retain cycles, which can lead to memory leaks.
        ApiCaller.shared.news(for: type) { [ weak self ] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        
        
    }
    private func open(url : URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let story = stories[indexPath.row]
        cell.configure(with: NewsTableViewCell.ViewModal.init(model: story))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        header.configure(with: .init(
            title: self.type.title,
            shouldShowAddButton: false))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Open new story
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFaildToOpenUrl()
            return
        }
        open(url: url)

    }
    
    private func presentFaildToOpenUrl() {
        let alert = UIAlertController(
            title: "Unable to open",
            message: "we were unable to open the article",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismissed", style: .cancel))
        present(alert, animated: true)
    }
}
