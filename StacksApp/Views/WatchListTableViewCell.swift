//
//  WatchListTableViewCell.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/6/24.
//

import UIKit
protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}
class WatchListTableViewCell: UITableViewCell {
    static let identifier = "WatchListTableViewCell"
    static let preferredHeight :CGFloat = 60
    weak var delegate : WatchListTableViewCellDelegate?
    
    struct ViewModel {
        let symbol : String
        let companyName: String
        let price: String // Formatted
        let changeColor: UIColor // red or green
        let changePercentage: String // Formatted
        let chartViewModel: StockChartView.ViewModel
    }
    
    // Symbol Lable
    private let symbolLable: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 17, weight: .heavy)
        return lable
    }()
    
    // Company Lable
    private let companyLable: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 14, weight: .light)
        lable.numberOfLines = 0
        return lable
    }()
    
    //Price Lable
    private let priceLable: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .right
        lable.font = .systemFont(ofSize: 15, weight: .regular)
        return lable
    }()
    
    // Change in Price
    private let changeInPriceLable: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .right
        lable.textColor = .white
        lable.font = .systemFont(ofSize: 15, weight: .regular)
        lable.layer.masksToBounds = true
        lable.layer.cornerRadius = 6
        lable.layer.cornerCurve = .continuous
        return lable
    }()
    
    // MiniChart View
    private let miniChartView : StockChartView = {
        let chartView = StockChartView()
        chartView.isUserInteractionEnabled = false
        chartView.clipsToBounds = true
        return chartView
    }()
    
    //Num 1
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubview(symbolLable)
        addSubview(companyLable)
        addSubview(priceLable)
        addSubview(changeInPriceLable)
        addSubview(miniChartView)
        
    }
    
    // Num 2
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Num 3
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLable.sizeToFit()
        companyLable.sizeToFit()
        priceLable.sizeToFit()
        changeInPriceLable.sizeToFit()
        
        let currenntWidth = max(
            max(priceLable.width, changeInPriceLable.width),
            WatchListViewController.maxChangeWidth)
        
        if currenntWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currenntWidth
            delegate?.didUpdateMaxWidth()
        }
        
        let yStart : CGFloat = (contentView.height - symbolLable.height - companyLable.height) / 2
        symbolLable.frame = CGRect(x: separatorInset.left,
                                   y: yStart,
                                   width: symbolLable.width,
                                   height: symbolLable.height)
        
        companyLable.frame = CGRect(x: separatorInset.left,
                                    y: symbolLable.bottom,
                                    width: contentView.width / 2.4,
                                    height: companyLable.height)
        
        
        priceLable.frame = CGRect(x: contentView.width - 10 - currenntWidth,
                                  y: (contentView.height - priceLable.height - changeInPriceLable.height) / 2,
                                  width: currenntWidth,
                                  height: priceLable.height)
        
        changeInPriceLable.frame = CGRect(x: contentView.width - 10 - currenntWidth,
                                          y: priceLable.bottom,
                                          width: currenntWidth,
                                          height: changeInPriceLable.height)
        
        
        miniChartView.frame = CGRect(x: priceLable.left - (contentView.width / 3) - 5,
                                     y: priceLable.bottom,
                                     width: contentView.width / 3,
                                     height: contentView.height - 12)
        
    }
    
    // Num 4
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLable.text = nil
        companyLable.text = nil
        priceLable.text = nil
        changeInPriceLable.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLable.text = viewModel.symbol
        companyLable.text = viewModel.companyName
        priceLable.text = viewModel.price
        changeInPriceLable.text = viewModel.changePercentage
        changeInPriceLable.backgroundColor = viewModel.changeColor
        // Configur the chart
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}
