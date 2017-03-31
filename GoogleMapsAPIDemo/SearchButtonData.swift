//
//  SearchButtonData.swift
//  GoogleMapsAPIDemo
//
//  Created by Christopher Schlitt on 3/30/17.
//  Copyright © 2017 Christopher Schlitt. All rights reserved.
//

import Foundation
import UIKit

class SearchButtonData {
    
    var image: String
    var search: String
    var color: String
    
    init(search: String, image: String, color: String){
        self.image = image
        self.search = search
        self.color = color
    }
    
    static func getData() -> [SearchButtonData] {
        var data = [SearchButtonData]()
        data.append(SearchButtonData(search: "Auto Repair", image: "auto.png", color: "#2E5077"))
        data.append(SearchButtonData(search: "Plumber", image: "plumber.png", color: "#2E5077"))
        data.append(SearchButtonData(search: "Electronics Repair", image: "devices.png", color: "#2E5077"))
        data.append(SearchButtonData(search: "Electrician", image: "electrician.png", color: "#2E5077"))
        data.append(SearchButtonData(search: "Dog Daycare", image: "dog.png", color: "#2E5077"))
        data.append(SearchButtonData(search: "Groceries", image: "shop.png", color: "#2E5077"))
        data.append(SearchButtonData(search: "Beer", image: "beer.png", color: "#2E5077"))
        return data
    }
    
}
