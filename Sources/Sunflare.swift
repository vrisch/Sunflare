//
//  Sunflare.swift
//  Sunflare
//
//  Created by vrisch on {TODAY}.
//  Copyright © 2017 Sunflare. All rights reserved.
//

import Foundation

public protocol ViewPresenter {
    func viewDidLoad() throws
    func viewWillAppear() throws
    func viewDidDisappear() throws
    
    func viewDidFail(error: Error)
}

public extension ViewPresenter {
    
    func viewDidLoad() throws {
    }
    
    func viewWillAppear() throws {
    }
    
    func viewDidDisappear() throws {
    }
    
    func viewDidFail(error: Error) {
        print("viewDidFail: \(error)")
    }
}

