//
//  BlockTimeTests.swift
//  BlockTimeTests
//
//  Created by Julia Yu on 3/30/25.
//

import Testing
import UIKit
@testable import Block_Time

struct BlockTimeTests {
    
    @Test func testDateExtensionMidnightCrossing() async throws {
        // Create a reference date (today)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Create start time at 10:00 PM
        let startComponents = DateComponents(hour: 22, minute: 0, second: 0)
        let startTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today)!
        
        // Create end time at 1:30 AM
        let endComponents = DateComponents(hour: 1, minute: 30, second: 0)
        let endTimeRaw = calendar.date(bySettingHour: 1, minute: 30, second: 0, of: today)!
        
        // Test that the date extension correctly handles midnight crossing
        let adjustedEndTime = endTimeRaw.combiningDateComponents(
            fromReferenceDate: today,
            isEndTime: true,
            startTime: startTime
        )
        
        // The adjusted end time should be on the next day
        let endTimeDayAfter = calendar.date(byAdding: .day, value: 1, to: endTimeRaw)!
        
        // Validate the dates' hour and minute components match what we expect
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: adjustedEndTime)
        let endMinute = calendar.component(.minute, from: adjustedEndTime)
        
        #expect(startHour == 22)
        #expect(startMinute == 0)
        #expect(endHour == 1)
        #expect(endMinute == 30)
        
        // Check that the end time got adjusted to the next day
        let startDay = calendar.ordinality(of: .day, in: .year, for: startTime)!
        let endDay = calendar.ordinality(of: .day, in: .year, for: adjustedEndTime)!
        
        #expect(endDay == startDay + 1, "End day should be the day after start day")
    }
    
    @Test func testCalendarEventCreation() async throws {
            // Create calendar event with specific properties
            let uniqueId = UUID()
            let eventTitle = "Team Meeting"
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            // Create times for 2:00 PM to 3:30 PM
            let startTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!
            let endTime = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: today)!
            
            // Use the system blue color with alpha
            let eventColor = UIColor.systemBlue.withAlphaComponent(0.7)
            
            // Create a calendar event
            let event = CalendarEvent(
                id: uniqueId,
                title: eventTitle,
                startTime: startTime,
                endTime: endTime,
                color: eventColor
            )
            
            // Verify event properties
            #expect(event.id == uniqueId, "Event should have the assigned ID")
            #expect(event.title == eventTitle, "Event should have the correct title")
            
            // Check time properties
            let startHour = calendar.component(.hour, from: event.startTime)
            let startMinute = calendar.component(.minute, from: event.startTime)
            let endHour = calendar.component(.hour, from: event.endTime)
            let endMinute = calendar.component(.minute, from: event.endTime)
            
            #expect(startHour == 14, "Start hour should be 2 PM (14:00)")
            #expect(startMinute == 0, "Start minute should be 0")
            #expect(endHour == 15, "End hour should be 3 PM (15:00)")
            #expect(endMinute == 30, "End minute should be 30")
            
            // Check duration (should be 90 minutes)
            let durationInMinutes = Int(event.endTime.timeIntervalSince(event.startTime) / 60)
            #expect(durationInMinutes == 90, "Event should be 90 minutes long")
            
            // Verify the event is on the expected day
            let eventDay = calendar.component(.day, from: event.startTime)
            let todayDay = calendar.component(.day, from: today)
            #expect(eventDay == todayDay, "Event should be on today's date")
        }
    
    @Test func testEventTemplateDefaultsAndCreation() async throws {
            // Test the default templates provided by the app
            let defaultTemplates = EventTemplate.defaultTemplates()
            
            // Verify we have the expected number of default templates
            #expect(defaultTemplates.count == 5, "Should have 5 default templates")
            
            // Verify the specific templates exist with correct properties
            let templateNames = defaultTemplates.map { $0.title }
            #expect(templateNames.contains("Cooking"), "Default templates should include Cooking")
            #expect(templateNames.contains("Exercise"), "Default templates should include Exercise")
            #expect(templateNames.contains("Study"), "Default templates should include Study")
            #expect(templateNames.contains("Eat"), "Default templates should include Eat")
            #expect(templateNames.contains("Break"), "Default templates should include Break")
            
            // Find the Study template and verify its duration
            if let studyTemplate = defaultTemplates.first(where: { $0.title == "Study" }) {
                #expect(studyTemplate.duration == 120, "Study template should be 120 minutes")
            } else {
                Issue.record("Study template not found in default templates")
            }
            
            // Create a custom template
            let customTemplateId = UUID()
            let customTemplate = EventTemplate(
                id: customTemplateId,
                title: "Meeting",
                duration: 60,
                color: UIColor.systemRed.withAlphaComponent(0.7)
            )
            
            // Verify custom template properties
            #expect(customTemplate.id == customTemplateId, "Template should have the assigned ID")
            #expect(customTemplate.title == "Meeting", "Template should have the correct title")
            #expect(customTemplate.duration == 60, "Template should have 60 minute duration")
            
            // Create a calendar event from the template with a specific start time
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let startTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!
            
            // Manually create an event based on the template (simulating the app's functionality)
            let endTime = calendar.date(byAdding: .minute, value: Int(customTemplate.duration), to: startTime)!
            let event = CalendarEvent(
                title: customTemplate.title,
                startTime: startTime,
                endTime: endTime,
                color: customTemplate.color
            )
            
            // Verify the event created from the template has the correct properties
            #expect(event.title == "Meeting", "Event should inherit template title")
            #expect(event.endTime.timeIntervalSince(event.startTime) == 3600, "Event should be 60 minutes (3600 seconds)")
        }
    
    @Test func testPositionToTimeConversion() async throws {
        // Create a calendar day view to test the time conversion methods
        let calendarDayView = CalendarDayView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        
        // Test various positions and verify the time they convert to
        let hourHeight = calendarDayView.hourHeight
        
        // Position for 9:00 AM
        let position9AM = 9 * hourHeight
        let time9AM = calendarDayView.positionToTime(position: position9AM)
        let calendar = Calendar.current
        let hour9AM = calendar.component(.hour, from: time9AM)
        let minute9AM = calendar.component(.minute, from: time9AM)
        #expect(hour9AM == 9, "Position should convert to 9:00 AM")
        #expect(minute9AM == 0, "Minutes should be 0")
        
        // Position for 2:30 PM (position = 14.5 * hourHeight)
        let position230PM = 14.5 * hourHeight
        let time230PM = calendarDayView.positionToTime(position: position230PM)
        let hour230PM = calendar.component(.hour, from: time230PM)
        let minute230PM = calendar.component(.minute, from: time230PM)
        #expect(hour230PM == 14, "Position should convert to 2 PM (hour 14)")
        #expect(minute230PM == 30, "Minutes should be 30")
        
        // Test rounding with the roundToMinutes parameter
        let positionAlmost3 = 14.92 * hourHeight // Almost 3:00 PM (14:55)
        let timeRounded = calendarDayView.positionToTime(position: positionAlmost3, roundToMinutes: 15)
        let hourRounded = calendar.component(.hour, from: timeRounded)
        let minuteRounded = calendar.component(.minute, from: timeRounded)
        #expect(hourRounded == 15, "Position should round up to 3:00 PM (hour 15)")
        #expect(minuteRounded == 0, "Minutes should round to 0")
    }

    @Test func testTimeToPositionConversion() async throws {
        // Create a calendar day view to test the position conversion methods
        let calendarDayView = CalendarDayView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let hourHeight = calendarDayView.hourHeight
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Test for 10:00 AM
        let time10AM = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!
        let position10AM = calendarDayView.timeToPosition(event: time10AM)
        #expect(position10AM == 10 * hourHeight, "10:00 AM should convert to position \(10 * hourHeight)")
        
        // Test for 3:45 PM
        let time345PM = calendar.date(bySettingHour: 15, minute: 45, second: 0, of: today)!
        let position345PM = calendarDayView.timeToPosition(event: time345PM)
        let expected345PMPosition = 15.75 * hourHeight // 15 hours + 0.75 of an hour (45 minutes)
        #expect(position345PM == expected345PMPosition, "3:45 PM should convert to position \(expected345PMPosition)")
        
        // Test midnight (special case)
        let midnight = calendar.date(byAdding: .day, value: 1, to: today)!
        let positionMidnight = calendarDayView.timeToPosition(event: midnight)
        #expect(positionMidnight == 24 * hourHeight, "Midnight should convert to position \(24 * hourHeight)")
    }

    @Test func testUIColorToRGBStringConversion() async throws {
        // Test the UIColor extension methods for string conversion and back
        
        // Test with some standard colors
        let testColors = [
            UIColor.red,
            UIColor.blue,
            UIColor.green,
            UIColor.systemTeal.withAlphaComponent(0.7),
            UIColor.systemPurple.withAlphaComponent(0.5)
        ]
        
        for originalColor in testColors {
            // Convert to RGB string
            let rgbString = originalColor.toRGBString()
            
            // Convert back to color
            let convertedColor = UIColor.fromRGBString(rgbString)
            
            // Extract components from both colors for comparison
            var originalRed: CGFloat = 0
            var originalGreen: CGFloat = 0
            var originalBlue: CGFloat = 0
            var originalAlpha: CGFloat = 0
            originalColor.getRed(&originalRed, green: &originalGreen, blue: &originalBlue, alpha: &originalAlpha)
            
            var convertedRed: CGFloat = 0
            var convertedGreen: CGFloat = 0
            var convertedBlue: CGFloat = 0
            var convertedAlpha: CGFloat = 0
            convertedColor.getRed(&convertedRed, green: &convertedGreen, blue: &convertedBlue, alpha: &convertedAlpha)
            
            // Check that all components are the same within a small margin of error
            #expect(abs(originalRed - convertedRed) < 0.001, "Red component should be preserved")
            #expect(abs(originalGreen - convertedGreen) < 0.001, "Green component should be preserved")
            #expect(abs(originalBlue - convertedBlue) < 0.001, "Blue component should be preserved")
            #expect(abs(originalAlpha - convertedAlpha) < 0.001, "Alpha component should be preserved")
        }
        
        // Test with invalid string
        let fallbackColor = UIColor.fromRGBString("invalid-string")
        
        // Should return the default fallback (systemBlue with alpha 0.7)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        fallbackColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Check that the color is blue-ish with roughly 0.7 alpha
        #expect(blue > red && blue > green, "Fallback color should be primarily blue")
        #expect(abs(alpha - 0.7) < 0.001, "Fallback color should have approximately 0.7 alpha")
    }

    @Test func testDayClassFunctionality() async throws {
        // Test the Day struct functionality
        
        // Test creating a day for today
        let today = Date()
        let dayForToday = Day.forDate(today)
        
        // Verify the day date is at the start of the day
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: today)
        
        #expect(calendar.isDate(dayForToday.date, equalTo: startOfToday, toGranularity: .second),
               "Day date should be at start of day")
        
        // Test creating a Day from a specific time and verify it's normalized to start of day
        let timeAtNoon = calendar.date(bySettingHour: 12, minute: 30, second: 45, of: today)!
        let dayFromNoon = Day.forDate(timeAtNoon)
        
        #expect(calendar.isDate(dayFromNoon.date, equalTo: startOfToday, toGranularity: .second),
               "Day created from noon should still be at start of day")
        
        // Test day equality for same date
        let anotherDayObject = Day(date: startOfToday)
        #expect(calendar.isDate(anotherDayObject.date, equalTo: dayForToday.date, toGranularity: .day),
               "Two Day objects for the same day should have equal dates")
        
        // Test day from different date
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let tomorrowDay = Day.forDate(tomorrow)
        
        #expect(!calendar.isDate(tomorrowDay.date, equalTo: dayForToday.date, toGranularity: .day),
               "Day objects for different days should have different dates")
        
        // Test that day initialized with its own ID creates a unique ID
        let day1 = Day(date: startOfToday)
        let day2 = Day(date: startOfToday)
        #expect(day1.id != day2.id, "Day objects should have unique IDs")
    }

    @Test func testEventTemplateDurationFormatting() async throws {
        // This test verifies that event template durations are properly formatted in the UI
        
        // Create templates with different durations
        let shortTemplate = EventTemplate(title: "Short", duration: 15, color: .systemBlue)
        let mediumTemplate = EventTemplate(title: "Medium", duration: 45, color: .systemGreen)
        let hourTemplate = EventTemplate(title: "Hour", duration: 60, color: .systemRed)
        let hourAndMinutesTemplate = EventTemplate(title: "Long", duration: 75, color: .systemPurple)
        let multiHourTemplate = EventTemplate(title: "Very Long", duration: 150, color: .systemOrange)
        
        // Create template views to check the duration label formatting
        let shortTemplateView = EventTemplateView(template: shortTemplate)
        let mediumTemplateView = EventTemplateView(template: mediumTemplate)
        let hourTemplateView = EventTemplateView(template: hourTemplate)
        let hourAndMinutesTemplateView = EventTemplateView(template: hourAndMinutesTemplate)
        let multiHourTemplateView = EventTemplateView(template: multiHourTemplate)
        
        // Extract the duration label from each view (second subview, which is the duration label)
        let shortDurationLabel = shortTemplateView.subviews[1] as! UILabel
        let mediumDurationLabel = mediumTemplateView.subviews[1] as! UILabel
        let hourDurationLabel = hourTemplateView.subviews[1] as! UILabel
        let hourAndMinutesDurationLabel = hourAndMinutesTemplateView.subviews[1] as! UILabel
        let multiHourDurationLabel = multiHourTemplateView.subviews[1] as! UILabel
        
        // Verify the text format is correct for each duration type
        #expect(shortDurationLabel.text == "15 min", "Short duration should display as minutes only")
        #expect(mediumDurationLabel.text == "45 min", "Medium duration should display as minutes only")
        #expect(hourDurationLabel.text == "1 hr", "Hour duration should display as hours only")
        #expect(hourAndMinutesDurationLabel.text == "1 hr 15 min", "Hour and minutes duration should display both")
        #expect(multiHourDurationLabel.text == "2 hr 30 min", "Multi-hour duration should display hours and minutes")
    }
}
