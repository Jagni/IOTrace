//
//  CircleView.swift
//  Quiz
//
//  Created by Jagni Dasa Horta Bezerra on 15/12/17.
//  Copyright © 2017 Unichristus. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class RoundButton: UIButton {
    var ratio : CGFloat = 0
    @IBInspectable var cornerRatio: CGFloat {
        get {
            return ratio
        }
        set {
            ratio = newValue
            self.layer.cornerRadius = newValue * bounds.size.width
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size.width <= bounds.size.height{
        	layer.cornerRadius = ratio * bounds.size.width
        } else {
            layer.cornerRadius = ratio * bounds.size.height
        }
    }
}

@IBDesignable public class RoundView: UIView {
    var ratio : CGFloat = 0
    @IBInspectable var cornerRatio: CGFloat {
        get {
            return ratio
        }
        set {
            ratio = newValue
            self.layer.cornerRadius = newValue * bounds.size.width
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size.width <= bounds.size.height{
            layer.cornerRadius = ratio * bounds.size.width
        } else {
            layer.cornerRadius = ratio * bounds.size.height
        }
    }
}

@IBDesignable public class ImageRoundView: UIImageView {
    var ratio : CGFloat = 0
    @IBInspectable var cornerRatio: CGFloat {
        get {
            return ratio
        }
        set {
            ratio = newValue
            self.layer.cornerRadius = newValue * bounds.size.width
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size.width <= bounds.size.height{
            layer.cornerRadius = ratio * bounds.size.width
        } else {
            layer.cornerRadius = ratio * bounds.size.height
        }
    }
}
