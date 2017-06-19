//
//  StackViewController.swift
//  Sunflare-iOS
//
//  Created by Magnus Nilsson on 2017-06-19.
//  Copyright © 2017 Sunflare. All rights reserved.
//

import UIKit

public protocol StackViewPresenter: class, ViewPresenter {
    weak var stackView: UIStackView? { get set }
}

public class StackViewController<P: StackViewPresenter>: UIViewController {
    var stackView: UIStackView!
    let presenter: P
    
    public init(presenter: P) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        
        edgesForExtendedLayout = []
        view.backgroundColor = .white
        
        stackView = UIStackView()
        stackView.spacing = 8
        view.addSubview(stackView)
        
        presenter.stackView = stackView
        presenter.viewDidLoad()
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }
}

