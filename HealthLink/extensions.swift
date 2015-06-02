//
//  extensions.swift
//  HealthLink
//
//  Created by Jason Kusnier on 6/1/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation

extension NSDate {
    public func shortDateString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(self)
    }
}

extension Double {
    public func intString() -> String? {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        
        return formatter.stringFromNumber(self)
    }
    
    public func shortDecimalString() -> String? {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 2

        return formatter.stringFromNumber(self)
    }
}

extension Int {
    public func intString() -> String? {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        
        return formatter.stringFromNumber(self)
    }
}