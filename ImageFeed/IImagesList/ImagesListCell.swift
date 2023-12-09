//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Глеб Хамин on 06.11.2023.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    //test
}
