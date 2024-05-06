//
//  StockDetailViewController.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/4/24.
//

import UIKit
import SafariServices

class StockDetailViewController: UIViewController {
    //MARK: -Properties
    private let symbol : String
    private let companyName : String
    private let candleStickData : [CandleStick]
    private var stories: [NewsStory] = []
    
    private var metrics: Metrics?
    
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.sizeToFit()
        return button
    }()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    //MARK: -Init
    init(
        symbol: String,
        companyName: String,
        candleStickData: [CandleStick] = []
    ){
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -Lyfesycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = companyName
        setUpCloseButton()
        setUpTableView()// Show View
        fetchFinancialData() // Financial Data
        fetchNews() // Show Users News
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    //MARK: -Private
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action:  #selector(closeButtonTapped))
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
        tableView.backgroundColor = .secondarySystemBackground
    }
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        //Fetch candle sticks if neede
        if candleStickData.isEmpty {
            group.enter()
        }
        
        // Fetch financial metrics
        group.enter()
        ApiCaller.shared.financialMatrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            // Show Chart/Graph
            self?.renderChart()
        }
        
        
    }
    private func fetchNews() {
        ApiCaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let e):
                print(e)
            }
        }
        
    }
    private func renderChart() {
        let headerView = StockDetailHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: (view.width * 0.7) + 100))
        
        //Configure
        var viewModel = [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModel.append(.init(name: "52W High", value: "\(metrics.annualWeekHigh)"))
            viewModel.append(.init(name: "52W Low", value: "\(metrics.annualWeekLow)"))
            viewModel.append(.init(name: "52W Return", value: "\(metrics.annualWeekPriceReturnDaily)"))
            viewModel.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModel.append(.init(name: "10D Vol.", value: "\(metrics.tenDayAverageTradingVolume)"))
            viewModel.append(.init(name: "52W Low Date", value: "\(metrics.annualWeekLowDate)"))

        }
        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(chartViewModel: .init(data:
                                                   candleStickData.reversed().map { $0.close },
                                                   showLegend: true,
                                                   showAxis: true, 
                                                   fillColor: change < 0 ? .systemRed : .systemGreen),
                             metricViewModels: viewModel)
        tableView.tableHeaderView = headerView
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
    
    private func open(url : URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    private func presentFaildToOpenUrl() {
        let alert = UIAlertController(
            title: "Unable to open",
            message: "we were unable to open the article",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    
    //MARK: -OBJC
    @objc func closeButtonTapped() {
        dismiss(animated: true)
    }
    //MARK: -Public
}

//MARK: -TABLE VIEW EXTETIONS
extension StockDetailViewController: UITableViewDelegate, UITableViewDataSource {
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsTableViewCell.preferredHeight
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
    
    //MARK: -Headers
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        header.delegate = self
        header.configure(with: .init(title: symbol.uppercased(), shouldShowAddButton: !PersistenceManager.shared.watchListContain(sybol: symbol)))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
}

extension StockDetailViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTabButton(_ headerView: NewsHeaderView) {
        // Add to Watch list
        headerView.button.isHidden = true
        PersistenceManager.shared.addWatchList(
            sybol: symbol,
            companyName: companyName)
        
        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We've added \(companyName) to your watchlist.",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    
}
