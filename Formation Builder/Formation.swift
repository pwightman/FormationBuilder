//
//  Formation.swift
//  Protector
//
//  Created by Parker Wightman on 10/4/14.
//  Copyright (c) 2014 Alora Studios. All rights reserved.
//

import UIKit
import CloudKit

class Formation {

    var name: String = ""
    var points: [CGPoint] = []
    private let _record: CKRecord

    var record: CKRecord {
        self._record.setValue(self.name, forKey: "Name")
        self._record.setValue(self.points.map { "[\($0.x),\($0.y)]" }, forKey: "Points")

        return self._record
    }

    init(record: CKRecord) {
        self.name = record.valueForKey("Name") as String
        self.points = (record.valueForKey("Points") as [String]).map { point -> CGPoint in
            CGPointFromString(point)
        }
        self._record = record
    }

}