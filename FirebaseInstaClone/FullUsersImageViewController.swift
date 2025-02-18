//
//  FullUsersImageViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 12.02.25.
//

import UIKit
import SnapKit

class FullUsersImageViewController: UIViewController {
    
    var postImageURL: String?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupImageView()
        loadImage()
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadImage() {
        guard let urlString = postImageURL, let url = URL(string: urlString) else { return }
        imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
    }
}
