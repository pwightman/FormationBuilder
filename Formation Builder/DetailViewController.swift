//
//  DetailViewController.swift
//  Formation Builder
//
//  Created by Parker Wightman on 10/23/14.
//  Copyright (c) 2014 Alora Studios. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {


    var detailItem: Formation? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        for view in (self.view.subviews as [UIView]) { view.removeFromSuperview() }
        if let formation = self.detailItem {
            for (i, point) in enumerate(formation.points) {
                self.view.addSubview(self.configuredFormationViewAtIndex(i))
            }
        }
    }

    func configuredFormationViewAtIndex(index: Int) -> FormationView {
        let point = self.detailItem!.points[index]

        let view = FormationView(frame: CGRectZero)
        view.backgroundColor = UIColor.yellowColor()
        view.center = point
        view.frame.size = CGSize(width: 30, height: 30)

        view.didDrop = { [weak self] newCenter in
            if let this = self {
                this.detailItem!.points[index] = newCenter
            }
        }

        return view
    }

    @IBAction func addTapped(sender: AnyObject) {
        self.detailItem!.points.append(CGPoint(x: 100, y: 100))
        self.view.addSubview(self.configuredFormationViewAtIndex(self.detailItem!.points.count - 1))
    }

    @IBAction func renamedTapped(sender: AnyObject) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

}

