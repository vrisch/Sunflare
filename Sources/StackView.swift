//
//  ReusableView.swift
//  Sunflare-iOS
//
//  Created by Magnus Nilsson on 2017-09-01.
//  Copyright © 2017 Sunflare. All rights reserved.
//

import Foundation
import UIKit

public class StackView<P: StackViewPresenter>: UIStackView {
    public var presenter: P? = nil {
        willSet {
            do {
                try presenter?.viewDidDisappear()
                subviews.forEach { $0.removeFromSuperview() }
            } catch let error {
                presenter?.viewDidFail(error: error)
            }
        }
        didSet {
            do {
                presenter?.stackViewController = nil
                try presenter?.viewDidLoad()
                try presenter?.viewWillAppear()
            } catch let error {
                presenter?.viewDidFail(error: error)
            }
        }
    }

    deinit {
        do {
            try presenter?.viewDidDisappear()
        } catch let error {
            presenter?.viewDidFail(error: error)
        }
    }
}
