//
//  CardView.swift
//  native_ios_new1
//
//  Created by Tanakorn Chauekid on 11/4/2566 BE.
//

import Foundation
import UIKit


@IBDesignable class CardView : UIView {
    var cornerRadius : CGFloat = 10
    var ofsetShadowOpacity : Float = 5
    var colorShadow = UIColor.systemGray4
    
    override func layoutSubviews() {
        layer.cornerRadius = self.cornerRadius
        layer.shadowOpacity = self.ofsetShadowOpacity
        layer.shadowColor = self.colorShadow.cgColor
    }
}
