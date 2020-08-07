//
//  ViewController.swift
//  PopUpButton
//
//  Created by k-o-d-e-n on 06/28/2020.
//  Copyright (c) 2020 k-o-d-e-n. All rights reserved.
//

import UIKit
import PopUpButton

class ViewController: UIViewController {
    var buttons: [PopUpButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let items: [PopUpButton.Item] = (0..<20).map { i in
            PopUpButton.Item(title: "\(Character(Unicode.Scalar(0x1F600 + i)!)) Item \(i)")
        }

        buttons = (0..<4).map({ i -> PopUpButton in
            let button = PopUpButton(items: items)
            button.backgroundColor = .black
            #if !targetEnvironment(macCatalyst)
            if UIDevice.current.userInterfaceIdiom == .pad {
                button.anchor = .viewController(navigationController!)
            }
            button.cover = .blur(.dark)
            #else
            button.cover = .color(nil)
            button.selectionTouchInsideOnly = true
            #endif
            button.layer.cornerRadius = 12
            button.currentIndex = Double(i + 1) / 4.0 > 0.5 ? 5 : 15
            button.addTarget(self, action: #selector(popUpButtonTouchUpInside), for: .valueChanged)
            view.addSubview(button)
            return button
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        buttons[0].frame = CGRect(x: 50, y: 100, width: 130, height: 44)
        buttons[1].frame = CGRect(x: view.bounds.width - 50 - 130, y: 100, width: 130, height: 44)
        buttons[2].frame = CGRect(x: 50, y: view.bounds.height - 100 - 44, width: 130, height: 44)
        buttons[3].frame = CGRect(x: view.bounds.width - 50 - 130, y: view.bounds.height - 100 - 44, width: 130, height: 44)
    }

    @objc func popUpButtonTouchUpInside(_ button: PopUpButton) {
        print("Selected item at index", button.currentIndex)
    }
}

