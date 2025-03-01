//
//  FeedCell.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 16.01.25.
//

import UIKit
import SnapKit
import SDWebImage
import Firebase

protocol FeedCellDelegate: AnyObject {
    func didTapLikeButton(on post: Post)
}

class FeedCell: UICollectionViewCell {
    
    var post: Post?
    weak var delegate: FeedCellDelegate?
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .red
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(postImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(likesLabel)
        
        postImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(250)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }
        
        likesLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton)
            make.leading.equalTo(likeButton.snp.trailing).offset(10)
        }
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with post: Post) {
        self.post = post
        
        if let url = URL(string: post.imageUrl) {
            postImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
        }
        
        likeButton.isSelected = post.likedBy.contains(Auth.auth().currentUser?.uid ?? "")
        likesLabel.text = "\(post.likes) Likes"
    }
    
    @objc private func likeButtonTapped() {
        guard let post = post else { return }
        delegate?.didTapLikeButton(on: post)
    }
}
