//
//  SearchResultSubTitleTableViewCell.swift
//  Spotify
//
//  Created by Sonu Martin on 28/07/21.
//

import UIKit
import SDWebImage

class SearchResultSubTitleTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultSubTitleTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconImageView)
        contentView.addSubview(subTitleLabel)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 10
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: contentView.height)
        
        let labelHeight = contentView.height/2
        label.frame = CGRect(x: iconImageView.right + 10, y: 0, width: contentView.width - iconImageView.right - 15, height: labelHeight)
        label.frame = CGRect(x: iconImageView.right + 10, y: label.bottom, width: contentView.width - iconImageView.right - 15, height: labelHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        subTitleLabel.text = nil
    }
    
    func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel){
        label.text = viewModel.title
        subTitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(with: viewModel.imageURL,placeholderImage: UIImage(systemName: "photo"), completed: nil)
    }
}
