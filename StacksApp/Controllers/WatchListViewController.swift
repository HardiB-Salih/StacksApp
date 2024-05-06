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
    static var maxChangeWidth: CGFloat = 0
    // Model Object
    private var watchListMap: [String: [CandleStick]] = [:]
    
    // ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    private var observer: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
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
        setUpObserver()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: Private
    
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchlist, object: nil, queue: .main, using: { [weak self] _ in
            self?.viewModels.removeAll()
            self?.setUpWatchListData()
            
        })
    }
    
    private func setUpWatchListData(){
        let symbols = PersistenceManager.shared.watchlist
        let group = DispatchGroup()
        
        for symbol in symbols where watchListMap[symbol] == nil {
            group.enter()
            ApiCaller.shared.marketData(for: symbol) { [weak self]  result in
                defer { group.leave() }
                switch result {
                case .success(let data):
                    let candleSticks = data.candleStick
                    self?.watchListMap[symbol] = candleSticks
                    //                    print(candleSticks)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
            
        }
        
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchListMap {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: .persentage(from: changePercentage),
                    chartViewModel: .init(
                        data: candleSticks.reversed().map{ $0.close },
                        showLegend: false,
                        showAxis: false, 
                        fillColor: changePercentage < 0 ? .systemRed : .systemGreen)
                ))
        }
        //        print("View Models: \(viewModels)")
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        //        let priorDate = Date().addingTimeInterval(-((3600 * 24) * 2))
        let priorDateComponents = DateComponents(year: 2022, month: 2)
        let priorDate = Calendar.current.date(from: priorDateComponents)!
        
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  Calendar.current.isDate($0.date, inSameDayAs: priorDate)
              })?.close
        else { return 0.0 }
        
        //        print("Symbol: \(symbol) | Current: \(latestClose) | Prior: \(priorClose)")
        let deff = 1 - (priorClose / latestClose)
        //        print("Symbol: \(symbol) | \(deff)")
        return deff
    }
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return "" }
        return .formatted(number: closingPrice)
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
    
        let lable = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: titleView.width - 20, 
            height: titleView.height))
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
        let vc = StockDetailViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description)
        let navVc = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVc, animated: true)
    }
    
    
}

extension WatchListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else { return UITableViewCell()}
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            //Update Percistance
            PersistenceManager.shared.removeWatchList(sybol: viewModels[indexPath.row].symbol)
            // Update View Model
            viewModels.remove(at: indexPath.row)
            //Update Row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModels[indexPath.row]
        let vc = StockDetailViewController(
            symbol: item.symbol,
            companyName: item.companyName,
            candleStickData: watchListMap[item.symbol] ?? [])
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdateMaxWidth() {
        // Optimize: Only refresh roes prior to the current row that changes the max width.
        tableView.reloadData()
    }
    
    
}
