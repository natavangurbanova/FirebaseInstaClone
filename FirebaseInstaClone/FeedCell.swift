//
//  FeedCell.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 16.01.25.
//

import UIKit
import SnapKit

class FeedCell: UICollectionViewCell {
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(postImageView)
        setupUI()
        postImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.0
    }
    
}
