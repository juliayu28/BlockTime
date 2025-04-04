//
//  Day.swift
//  Block Time
//
//  Created by Julia Yu on 3/19/25.
//
import Foundation

struct Day {
    var id: UUID
    var date: Date
    
    init(id: UUID = UUID(), date: Date) {
        self.id = id
        self.date = date
    }
    
    static func forDate(_ date: Date) -> Day {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return Day(date: startOfDay)
    }
}
