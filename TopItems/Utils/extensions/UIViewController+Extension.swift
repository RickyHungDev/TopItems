//
//  UIViewController+Extension.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addChild(childController: UIViewController, to view: UIView) {
        self.addChild(childController)
        childController.view.frame = view.bounds
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    func remove(childController: UIViewController, from view: UIView) {
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
    
}
