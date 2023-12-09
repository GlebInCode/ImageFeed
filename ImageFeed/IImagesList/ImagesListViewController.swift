//
//  ViewController.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 02.11.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    //MARK: - IBOutlts

    @IBOutlet private var tableView: UITableView!
    
    //MARK: - Private Properties
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    let photosName: [String] = Array(0..<21).map{ "\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
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
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = (indexPath.row + 1) % 2 == 0
        let likeImage = isLiked ? UIImage(named: "likeButtonOn") : UIImage(named: "likeButtonOff")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.likeButton.setTitle("", for: .normal)
        
        
        addGradient(to: cell.cellImage, with: indexPath)
    }
    
    func addGradient(to cellImage: UIImageView, with indexPath: IndexPath) {
        if let sublayers = cellImage.layer.sublayers {
            for layer in sublayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                    break
                }
            }
        }
        
        let cellHeight = tableView(tableView, heightForRowAt: indexPath)
        let gradientLayer = CAGradientLayer()
        let colorTop = UIColor { _ in UIColor(named: "YP Black") ?? UIColor.black }.withAlphaComponent(0).cgColor
        let colotBottom = UIColor { _ in UIColor(named: "YP Black") ?? UIColor.black }.withAlphaComponent(0.2).cgColor
        
        gradientLayer.frame = CGRect(x: 0, y: cellHeight - 38, width: cellImage.bounds.width, height: 30)
        gradientLayer.colors = [colorTop, colotBottom]
        gradientLayer.locations = [0.0, 1.0]
        cellImage.layer.addSublayer(gradientLayer)
    }
}

//MARK: - Extension: UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeinght = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeinght
    }
}

//MARK: - Extension: UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none //убрали выделение ячейки
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
