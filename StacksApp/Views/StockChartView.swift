//
//  StockChartView.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/6/24.
//

import UIKit
import Charts
import DGCharts

class StockChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
    }
    
    private let chartView : LineChartView = {
        let lineChart = LineChartView()
        lineChart.pinchZoomEnabled = false
        lineChart.setScaleEnabled(true)
        lineChart.xAxis.enabled = false
        lineChart.drawGridBackgroundEnabled = false
        lineChart.legend.enabled = false
        lineChart.leftAxis.enabled = false
        lineChart.rightAxis.enabled = false
        return lineChart
    }()

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    /// Reset the chart view
    func reset(){
        chartView.data = nil
    }
    
    func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry()]
        for (index, value) in viewModel.data.enumerated() {
            entries.append(.init(
                x: Double(index),
                y: value))
        }
        
        chartView.rightAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend
        
        let dataSet = LineChartDataSet(entries: entries, label: "7 Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
    }
    
}
