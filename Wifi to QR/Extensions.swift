//
//  UIViewExtension.swift
//  Wifi to QR
//
//  Created by Eugen on 13.05.18.
//  Copyright © 2018 Eugen. All rights reserved.
//

import UIKit

extension UIView {
    func makeScreenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { (context) in
            self.layer.render(in: context.cgContext)
        }
    }
}
