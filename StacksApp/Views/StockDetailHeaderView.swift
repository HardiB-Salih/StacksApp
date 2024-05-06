//
//  StockDetailHeaderView.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/6/24.
//

import UIKit

class StockDetailHeaderView: UIView {
    
    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
    
    // Chart View
    private let chartView = StockChartView()
    
    // Collection View
    private let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifire)
        collection.backgroundColor = .secondarySystemBackground
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        chartView.isUserInteractionEnabled = false
        clipsToBounds = true
        addSubview(chartView)
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame =  CGRect( x: 0, y: 0, width: width, height: height - 100)
        collectionView.frame = CGRect( x: 0, y: height - 100, width: width, height: 100)
    }
    
    func configure(
        chartViewModel: StockChartView.ViewModel,
        metricViewModels: [MetricCollectionViewCell.ViewModel])
    {
        //Update Chart
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
        chartView.configure(with: chartViewModel)
    }
}

extension StockDetailHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MetricCollectionViewCell.identifire,
            for: indexPath)
                as? MetricCollectionViewCell else { return UICollectionViewCell() }
        
        let metricViewModel = metricViewModels[indexPath.row]
        cell.configure(with: metricViewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    }
    
    
}
