//
//  ViewExtensions.swift
//  Projeto iOS
//
//  Created by Jagni Dasa Horta Bezerra on 15/09/17.
//  Copyright © 2017 Jagni Dasa Horta Bezerra. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor.black
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOppacity: CGFloat {
        get {
            return CGFloat(layer.shadowOpacity)
        }
        set {
            layer.shadowOpacity = Float(newValue)
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowVerticalOffset: CGFloat {
        get {
            return layer.shadowOffset.height
        }
        set {
            layer.shadowOffset = CGSize(width: shadowHorizontalOffset, height: newValue)
        }
    }
    
    @IBInspectable var shadowHorizontalOffset: CGFloat {
        get {
            return layer.shadowOffset.width
        }
        set {
            layer.shadowOffset = CGSize(width: newValue, height: shadowVerticalOffset)
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
}
