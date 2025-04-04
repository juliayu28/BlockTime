//
//  Utils.swift
//  Block Time
//
//  Created on 3/27/25.
//

import Foundation

extension Date {
    /// Combines the date components from a reference date with time components from this date
    /// Handles cases where an event crosses midnight by adjusting the end date to the next day
    func combiningDateComponents(fromReferenceDate referenceDate: Date, isEndTime: Bool = false, startTime: Date? = nil) -> Date {
        let calendar = Calendar.current
        
        // Extract date components from reference date
        let referenceDateComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        
        // Extract time components from this date
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        
        // Combine reference date with time
        var combinedComponents = DateComponents()
        combinedComponents.year = referenceDateComponents.year
        combinedComponents.month = referenceDateComponents.month
        combinedComponents.day = referenceDateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        
        // Create the combined date
        let combinedDate = calendar.date(from: combinedComponents) ?? self
        
        // Handle midnight crossing - if this is an end time and there's a start time,
        // and the combined end time is earlier than the similarly-processed start time,
        // then add one day to the end time
        if isEndTime, let startTime = startTime {
            let combinedStartDate = startTime.combiningDateComponents(fromReferenceDate: referenceDate)
            if combinedDate < combinedStartDate {
                return calendar.date(byAdding: .day, value: 1, to: combinedDate) ?? combinedDate
            }
        }
        
        return combinedDate
    }
}
