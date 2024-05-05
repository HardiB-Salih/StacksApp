//
//  NewsTableViewCell.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/5/24.
//

import UIKit
import SDWebImage

class NewsTableViewCell: UITableViewCell {
    static let identifier = "NewsTableViewCell"
    static let preferredHeight :CGFloat = 140
    
    struct ViewModal {
        let sourse: String
        let headline: String
        let date: String
        let imageUrl: URL?
        
        init(model: NewsStory) {
            self.sourse = model.source
            self.headline = model.headline
            self.date = .string(from: model.datetime)
            self.imageUrl = URL(string: model.image )
        }
    }
    
    //Sourse
    private let sourceLable: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 14, weight: .medium)
        return lable
    }()
    
    // Date
    private let dateLable: UILabel = {
        let lable = UILabel()
        lable.textColor = .secondaryLabel
        lable.font = .systemFont(ofSize: 14, weight: .light)
        return lable
    }()
    
    // Haedline
    private let headlineLable: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 20, weight: .medium)
        lable.numberOfLines = 0
        return lable
    }()
    
    private let storyImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .tertiarySystemBackground
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 6
        image.layer.cornerCurve = .continuous
        image.layer.masksToBounds = true
        return image
    }()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        addSubview(sourceLable)
        addSubview( dateLable)
        addSubview(headlineLable)
        addSubview(storyImageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height / 1.4
        storyImageView.frame = CGRect(x: contentView.width - imageSize - 10,
                                      y: (contentView.height - imageSize) / 2,
                                      width: imageSize,
                                      height: imageSize)
        
        //Layout lable
        let avalableSpase = contentView.width - separatorInset.left - imageSize - 15
        dateLable.frame = CGRect(x: separatorInset.left,
                                 y: contentView.height - 40,
                                 width: avalableSpase,
                                 height: 40)
        sourceLable.sizeToFit()
        sourceLable.frame = CGRect(x: separatorInset.left,
                                   y: 4,
                                   width: avalableSpase,
                                   height: sourceLable.height)
        
        
        headlineLable.frame = CGRect(x: separatorInset.left,
                                     y: sourceLable.bottom + 5,
                                     width: avalableSpase,
                                     height: contentView.height - sourceLable.bottom - dateLable.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLable.text = nil
        dateLable.text = nil
        headlineLable.text = nil
        storyImageView.image = nil
        
    }
    
    public func configure(with viewModal: ViewModal){
        sourceLable.text = viewModal.sourse
        headlineLable.text = viewModal.headline
        dateLable.text = viewModal.date
        storyImageView.sd_setImage(with: viewModal.imageUrl)
        // Manually add Image
        // storyImageView.setImage(from: viewModal.imageUrl)
    }
}
