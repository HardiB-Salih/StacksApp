//
//  NewsHeaderView.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/5/24.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTabButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {
    static let identifier = "NewsHeaderView"
    static let preferredHeight : CGFloat = 70
    weak var delegate: NewsHeaderViewDelegate?
    
    struct ViewModal {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    private let lable: UILabel = {
        let lable = UILabel()
        lable.font = .boldSystemFont(ofSize: 28)
        return lable
    }()
    
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

    //MARK: -INIT
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(lable)
        contentView.addSubview(button)

        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lable.sizeToFit()
        button.sizeToFit()
        
        lable.frame = CGRect(x: 14, y: 0, width: contentView.width - 28, height: contentView.height)
        
        button.frame = CGRect(
            x: contentView.width - button.width - 14,
            y: (contentView.height - button.height) / 2,
            width: button.width + 8,
            height: button.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lable.text = nil
    }
    
    @objc private func didTapButton() {
        delegate?.newsHeaderViewDidTabButton(self)
    }
    
    //MARK: -Public
    public func configure(with viewModel: ViewModal) {
        lable.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
}
