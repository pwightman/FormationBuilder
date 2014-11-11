//
//  FormationView.swift
//  Protector
//
//  Created by Parker Wightman on 10/4/14.
//  Copyright (c) 2014 Alora Studios. All rights reserved.
//

import UIKit

func + (a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x, y: a.y + b.y)
}

func - (a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x, y: a.y - b.y)
}

class FormationView: UIView {

    var didDrop: ((center: CGPoint) -> Void)?
    var initialPosition: CGPoint = CGPointZero

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        self.layer.masksToBounds = true
        let recognizer = UIPanGestureRecognizer(target: self, action: "panned:")
        self.addGestureRecognizer(recognizer)
    }

    func panned(recognizer: UIPanGestureRecognizer) {
        println("In self: \(recognizer.translationInView(self)), in super: \(recognizer.translationInView(self.superview!))")
        switch recognizer.state {
        case .Began:
            self.initialPosition = self.frame.origin
        case .Changed:
            self.frame.origin = self.initialPosition + recognizer.translationInView(self)
        case .Ended, .Failed:
            self.frame.origin = self.initialPosition + recognizer.translationInView(self)
            self.didDrop?(center: self.center)
        default: ()
        }
    }

    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.size.width/2
    }

    private var offset = CGPointZero

//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        self.offset = (touches.anyObject() as UITouch).locationInView(self)
//    }
//
//    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
//        var point = (touches.anyObject() as UITouch).locationInView(self.superview)
//        self.frame.origin = point - offset
//    }
//
//    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
//        self.didDrop?(center: self.center)
//    }
//
//    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
//        self.touchesEnded(touches, withEvent: event)
//    }

}
