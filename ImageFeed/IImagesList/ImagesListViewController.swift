//
//  ViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 02.11.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    //MARK: - IBOutlts
    
    @IBOutlet private var tableView: UITableView!
    
    //MARK: - Private Properties
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private let tokenStoreg = OAuth2TokenStorage.shared
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    let photosName: [String] = Array(0..<21).map{ "\($0)"}
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageListObserver()
        imagesListService.fetchPhotosNextPage()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
    
    //MARK: - Lifecycle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.cellImage.kf.indicatorType = .activity
        let urlImage = URL(string: photos[indexPath.row].thumbImageURL)
        cell.cellImage.kf.setImage(
            with: urlImage,
            placeholder: UIImage(named: "ImagePlaceholder"))
        cell.dateLabel.text = photos[indexPath.row].createdAt
        let likeImage = photos[indexPath.row].isLiked ? UIImage(named: "likeButtonOn") : UIImage(named: "likeButtonOff")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.likeButton.setTitle("", for: .normal)
    }
    
    private func addImageListObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateTableViewAnimated() {
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
            imagesListService.fetchPhotosNextPage()
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
        
        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
}


extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                AlertPresenter.showAletr(on: self, title: "Что-то пошло не так", message: "Не удалось поставить лайк")
            }
        }
    }
}
