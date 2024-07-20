//
//  ViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 02.11.2023.
//

import UIKit
import Kingfisher

//MARK: - ImagesListViewControllerProtocol

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated()
}

//MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    //MARK: - IBOutlts
    
    @IBOutlet private var tableView: UITableView!
    
    //MARK: - Properties
    
    var presenter: ImagesListPresenterProtocol?
    
    //MARK: - Private Properties
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var photos = [Photo]()
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ImagesListPresentor(view: self)
        presenter?.addImageListObserver()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
    
    //MARK: - ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.photosNextPage()
    }
    
    //MARK: - Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let imageURL = URL(string: photos[indexPath.row].largeImageURL)
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, width: CGFloat, height: CGFloat) {
        cell.dateLabel.text = nil
        cell.likeButton.setImage(nil, for: .normal)
        let gradient = createGradientLayer(width: width, height: height)
        cell.cellImage.layer.insertSublayer(gradient, at: 0)
        let urlImage = URL(string: photos[indexPath.row].thumbImageURL)
        cell.cellImage.kf.setImage(with: urlImage) { result in
            switch result {
            case .success(_):
                gradient.removeFromSuperlayer()
                cell.cellImage.layer.removeAllAnimations()
                cell.cellImage.contentMode = .scaleAspectFill
                if let date = self.photos[indexPath.row].createdAt {
                    cell.dateLabel.text = CustomDateFormatter.shared.dateFormatter.string(from: date )
                }
                let likeImage = self.photos[indexPath.row].isLiked ? UIImage(named: "likeButtonOn") : UIImage(named: "likeButtonOff")
                cell.likeButton.setImage(likeImage, for: .normal)
                cell.likeButton.setTitle("", for: .normal)
            case .failure(let error):
                gradient.removeFromSuperlayer()
                cell.cellImage.layer.removeAllAnimations()
                cell.cellImage.image = UIImage(named: "ImagePlaceholdetSingle")
                cell.cellImage.contentMode = .center
                print("Не удалось загрузить изображение \(#function): \(error.localizedDescription)")
            }
        }
        
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                tableView.performBatchUpdates {
                    let indexPaths = (oldCount..<newCount).map { i in
                        IndexPath(row: i, section: 0)
                    }
                    tableView.insertRows(at: indexPaths, with: .automatic)
                } completion: { _ in }
            }
        }
    }
    
    //MARK: - Private Methods
    
    private func createGradientLayer(width: CGFloat, height: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = CGFloat(16)
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        return gradient
    }
}

//MARK: - Extension: UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeinght = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeinght
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt IndexPath: IndexPath) {
        if IndexPath.row == photos.count - 1 {
            presenter?.photosNextPage()
        }
    }
}

//MARK: - Extension: UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBlack
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imagesListCell.dateLabel.text = nil
        imagesListCell.likeButton.setImage(nil, for: .normal)
        let cellWidth = cell.bounds.width
        let cellHeight = cell.bounds.height
        imagesListCell.delegate = self
        configCell(
            for: imagesListCell,
            with: indexPath,
            width: cellWidth,
            height: cellHeight
        )
        return imagesListCell
    }
}

//MARK: - Extension: ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                print(self.photos[indexPath.row])
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                AlertPresenter.showAletr(on: self, title: "Что-то пошло не так", message: "Не удалось поставить лайк")
            }
        }
    }
}
