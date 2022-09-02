//
//  ViewClass.swift
//  MapBox_Implementation
//
//  Created by Muhammad Asar on 5/28/22.

import UIKit

class CustomAnnotatoinView: UIView {
 
    @IBOutlet weak var img: UIImageView!
    static func getView() -> UIView {
        let view = Bundle.main.loadNibNamed("CustomAnnotatoinView", owner: nil, options: [:])?.first as! UIView
        return view
    }
    
}

