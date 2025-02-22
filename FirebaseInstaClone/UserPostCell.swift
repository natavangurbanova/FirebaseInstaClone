//
//  UserPostCell.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 17.02.25.
//

import UIKit
import SnapKit
import SDWebImage

class UserPostCell: UICollectionViewCell {
    
    static let identifier = "PostCell"
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with url: String) {
        imageView.loadImage(from: url)
    }
}
