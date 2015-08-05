//
//  extensions.swift
//  WorkoutMerge
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
    
    public func timeFormat() -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }
    public func relativeDateFormat() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.doesRelativeDateFormatting = true
        
        return dateFormatter.stringFromDate(self)
    }
    
    public func ISOStringFromDate() -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.stringFromDate(self).stringByAppendingString("Z")
    }
    
    public func dayOfWeek() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
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