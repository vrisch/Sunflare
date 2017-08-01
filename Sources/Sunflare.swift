//
//  Sunflare.swift
//  Sunflare
//
//  Created by vrisch on {TODAY}.
//  Copyright © 2017 Sunflare. All rights reserved.
//

import Foundation
import UIKit

public protocol ViewPresenter {
    associatedtype VC: UIViewController
    
    weak var viewController: VC? { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidDisappear()

    func configureNavigationItem(_ navigationItem: UINavigationItem)
}

public extension ViewPresenter {
    
    func viewDidLoad() {
    }
    
    func viewWillAppear() {
    }
    
    func viewDidDisappear() {
    }

    func configureNavigationItem(_ navigationItem: UINavigationItem) {
    }
}
