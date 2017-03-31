//
//  ServiceCell.swift
//  GoogleMapsAPIDemo
//
//  Created by Christopher Schlitt on 3/29/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import UIKit

class ServiceCell: UICollectionViewCell {
    
    /* Instance Variables */
    var data: SearchButtonData!
    
    /* UI Outlets */
    @IBOutlet weak var image: UIImageView!
    
    func refreshUI(){
        DispatchQueue.main.async {
            self.image.image = UIImage(named: self.data.image)
            self.clipsToBounds = true
            self.layer.cornerRadius = 32.5
            self.backgroundColor = UIColor.hexStringToUIColor(hex: self.data.color)
            self.layer.borderColor = UIColor.hexStringToUIColor(hex: self.data.color).darker(by: 2.5)?.cgColor
            self.layer.borderWidth = 2
        }
    }
    
}
