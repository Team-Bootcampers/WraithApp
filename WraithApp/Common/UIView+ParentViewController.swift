//
//  UIView+ParentViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

extension UIView {
    var ParentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
}
