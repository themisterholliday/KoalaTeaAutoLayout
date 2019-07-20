//
//  ViewController.swift
//  KoalaTeaAutoLayout
//
//  Created by themisterholliday on 07/17/2019.
//  Copyright (c) 2019 themisterholliday. All rights reserved.
//

import UIKit
import KoalaTeaAutoLayout

class ViewController: UIViewController {

    lazy var layoutView = UIView()
    lazy var layoutView2 = UIView()

    lazy var layoutView3 = UIView()
    var constraints1: [NSLayoutConstraint] = []
    var constraints2: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(layoutView)
        layoutView.backgroundColor = .red
        layoutView.layout {
            $0.top == self.view.safeAreaLayoutGuide.topAnchor
            $0.leading == self.view.leadingAnchor + 20
            $0.trailing == self.view.trailingAnchor - 20
            $0.height.equal(to: self.view.heightAnchor, multiplier: 0.1)
        }

        self.view.addSubview(layoutView2)
        layoutView2.backgroundColor = .green
        layoutView2.layout {
            $0.centerXAnchor == self.view.centerXAnchor
            $0.centerYAnchor == self.view.centerYAnchor
            $0.height == 80
            $0.width == $0.height + 100
        }

        setupAnimatedExample()
    }

    func setupAnimatedExample() {
        self.view.addSubview(layoutView3)
        layoutView3.backgroundColor = .blue
        constraints1 = layoutView3.returnedLayout {
            return [
                $0.centerXAnchor == self.view.centerXAnchor,
                $0.bottom == self.view.safeAreaLayoutGuide.bottomAnchor,
                $0.height == 80,
                $0.width == $0.height + 100,
            ]
        }

        constraints2 = layoutView3.returnedLayout {
            return [
                $0.top == layoutView2.bottomAnchor,
                $0.centerXAnchor == self.view.centerXAnchor,
                $0.height == 80,
                $0.width == $0.height + 100,
            ]
        }
        constraints2.deactivateAll()

        animate()
    }

    func animate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.constraints1.deactivateAll()
            self.constraints2.activateAll()

            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.constraints2.deactivateAll()
                    self.constraints1.activateAll()

                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: { _ in
                        self.animate()
                    })
                }
            })
        }
    }
}

