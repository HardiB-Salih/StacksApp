//
//  MetricCollectionViewCell.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/6/24.
//

import UIKit

class MetricCollectionViewCell: UICollectionViewCell {
    static let identifire = "MetricCollectionViewCell"
    
    struct ViewModel {
        let name: String
        let value: String
    }
    
    private let nameLable :UILabel = {
        let lable = UILabel()
        return lable
    }()
    
    private let valueLable :UILabel = {
        let lable = UILabel()
        lable.textColor = .secondaryLabel
        return lable
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(nameLable)
        contentView.addSubview(valueLable)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLable.sizeToFit()
        valueLable.sizeToFit()
        
        nameLable.frame = CGRect(x: 3, y: 0, 
                                 width: nameLable.width,
                                 height: contentView.height)
        
        valueLable.frame = CGRect(x: nameLable.right + 3, y: 0,
                                 width: valueLable.width,
                                 height: contentView.height)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLable.text = nil
        valueLable.text = nil
    }
    
    
    func configure(with viewModel: ViewModel){
        nameLable.text = viewModel.name + ":"
        valueLable.text = viewModel.value
    }
    
    
}
