//
//  SttDateExtensions.swift
//  STT
//
//  Created by Piter Standret on 6/22/18.
//  Edited by Alex Balan on 3/15/19
//  Copyright © 2019 Peter Standret <pstandret@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public extension Date {
    
    /// Return new Date which contain only year, month and day without hour, minute, seconds
    var date: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    
    /// Get number of seconds between two date
    /// - Parameter date: date to compate self to.
    /// - Returns: number of seconds between self and given date.
    func secondsSince(_ date: Date) -> Double {
        return timeIntervalSince(date)
    }
    
    /// Get number of minutes between two date
    /// - Parameter date: date to compate self to.
    /// - Returns: number of minutes between self and given date.
    func minutesSince(_ date: Date) -> Double {
        return timeIntervalSince(date) / 60
    }
    
    /// Get number of hours between two date
    /// - Parameter date: date to compate self to.
    /// - Returns: number of hours between self and given date.
    func hoursSince(_ date: Date) -> Double {
        return timeIntervalSince(date) / 3600
    }
    
    /// Get number of days between two date
    /// - Parameter date: date to compate self to.
    /// - Returns: number of days between self and given date.
    func daysSince(_ date: Date) -> Double {
        return timeIntervalSince(date) / (3600 * 24)
    }
    
    /// Returns a Date with the specified amount of components added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    /// Returns a Date with the specified amount of components subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
    
    /// Return string representation of date with specific format
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    // MARK: - deprecated
    
    @available(swift, obsoleted: 4.0, renamed: "date")
    func onlyDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    @available(swift, obsoleted: 4.0, message: "Might cause integrity break of Date timezone in the app!")
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    @available(swift, obsoleted: 4.0, renamed: "secondsSince")
    func differenceInMinutes() -> Int {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.minute]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: Date(), to: self);
        
        return difference.minute!
    }
    
    @available(swift, obsoleted: 4.0, message: "Might cause integrity break of Date timezone in the app! Use DateFormatter instead.")
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
