//
//  ViewController.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/4/24.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController, FloatingPanelControllerDelegate {
    private var searchTimer: Timer?
    private var panel: FloatingPanelController?
    
    // Model Object
    private var watchListMap: [String: [CandleStick]] = [:]
    
    // ViewModels
    private var viewModels: [String] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        setUpWatchListData()
        setUpFloatingPanel()
        setUpTitleView()

    }
    
    // MARK: Private
    
    private func setUpWatchListData(){
        let symbols = PersistenceManager.shared.watchlist
        let group = DispatchGroup()
        
        for symbol in symbols {
            group.enter()
            ApiCaller.shared.marketData(for: symbol) { [weak self]  result in
                defer { group.leave() }
                switch result {
                case .success(let data):
                    let candleSticks = data.candleStick
                    self?.watchListMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.tableView.reloadData()
//            print(watchListMap)
        }
        
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }
    
    
    
    private func setUpChiled() {
        let vc = PanelViewController()
        addChild(vc)
        
        view.addSubview(vc.view)
        vc.view.frame = CGRect(x: 0, y: view.height/2, width: view.width, height: view.height)
        
        vc.didMove(toParent: self)
    }
    private func setUpTitleView() {
        let titleView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: navigationController?.navigationBar.height ?? 100))
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: titleView.width - 20, height: titleView.height))
        lable.text = "Stocks"
        lable.font = .systemFont(ofSize: 35, weight: .semibold)
        titleView.addSubview(lable)
        
        navigationItem.titleView = titleView
    }
    
    private func setUpSearchController() {
        let resultVC = SearchResultViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        // Invalidate the previous timer to avoid multiple API calls.
        searchTimer?.invalidate()

        // Schedule a new timer to execute the search after a delay (e.g., 0.3 seconds).
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            // Call API to search
            ApiCaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        }
    }
}

extension WatchListViewController: SearchResultViewControllerDelegate {
    func searchResultViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        // Present Stock detail for given selection
        let vc = StockDetailViewController()
        let navVc = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVc, animated: true)
    }
    
    
}

extension WatchListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchListMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // show detail view
    }
}
