//
//  FullImageViewController.swift
//  FirebaseInstaClone
//
//  Created by Natavan Gurbanova on 17.01.25.
//

import UIKit
import SnapKit

class FullImageViewController: UIViewController {
    
    var postImageURL: String? // URL of the image to be displayed
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupImageView()
        loadImage()
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // Fullscreen layout
        }
    }
    
    private func loadImage() {
        guard let urlString = postImageURL, let url = URL(string: urlString) else { return }
        imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
    }
}
