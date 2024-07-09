//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 20.11.2023.
//

import UIKit
import Kingfisher

class SingleImageViewController: UIViewController {
    
    //MARK: - Properties
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded else { return }
            setImage()
        }
    }
    
    //MARK: - IBOutlts
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imagePlaceholdetSingle: UIImageView!
    
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: Any) {
        let share = UIActivityViewController(
            activityItems: [imageView.image as Any],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
    }
    
    //MARK: - Private Lifecycle
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func setImage() {
        imagePlaceholdetSingle.isHidden = false
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.imagePlaceholdetSingle.isHidden = true
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                print("error")
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так. Попробовать ещё раз?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: {action in
            self.setImage()
        }))
        self.present(alert, animated: true)
    }
}

//MARK: - Extension: UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
