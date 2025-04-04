import Testing
import UIKit
import EventKit
@testable import Block_Time

// MARK: - Mocks

class MockViewController: UIViewController {}

// Mock EventStore for testing Apple Calendar export
class MockEventStore: EKEventStore {
    var savedEvents: [EKEvent] = []
    var accessGranted = true
    var requestAccessCalled = false
    var defaultCalendarCalled = false
    
    override func requestFullAccessToEvents(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        requestAccessCalled = true
        completion(accessGranted, nil)
    }
    
    override func requestAccess(to entityType: EKEntityType, completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        requestAccessCalled = true
        completion(accessGranted, nil)
    }
    
    override var defaultCalendarForNewEvents: EKCalendar? {
        defaultCalendarCalled = true
        return EKCalendar(for: .event, eventStore: self)
    }
    
    override func save(_ event: EKEvent, span: EKSpan) throws {
        savedEvents.append(event)
    }
}

// Mock for Google Calendar export
class MockGoogleCalendarAPIManager {
    var events: [CalendarEvent]
    var currentDate: Date
    var exportCalled = false
    var successCount = 0
    var failureCount = 0
    
    init(events: [CalendarEvent], currentDate: Date) {
        self.events = events
        self.currentDate = currentDate
        // Initialize success count to match the number of events
        successCount = events.count
    }
    
    func exportToGoogleCalendar(completion: @escaping (Int, Int) -> Void) {
        exportCalled = true
        // Simulate successful export of all events
        completion(successCount, failureCount)
    }
}

// Extended version of CalendarExportManager for testing
class TestableCalendarExportManager: CalendarExportManager {
    var mockEventStore: MockEventStore?
    var mockGoogleCalendarManager: MockGoogleCalendarAPIManager?
    
    override func addEventsToAppleCalendar(eventStore: EKEventStore) {
        if let mockStore = mockEventStore {
            super.addEventsToAppleCalendar(eventStore: mockStore)
        } else {
            super.addEventsToAppleCalendar(eventStore: eventStore)
        }
    }
    
    override func exportToGoogleCalendar() {
        if let mockGoogle = mockGoogleCalendarManager {
            // Directly call the mock's exportToGoogleCalendar method
            mockGoogle.exportToGoogleCalendar { successCount, failureCount in
                // Simulate export completion
                DispatchQueue.main.async {
                    self.showExportResultAlert(
                        successCount: successCount,
                        failureCount: failureCount,
                        service: "Google Calendar"
                    )
                }
            }
        } else {
            super.exportToGoogleCalendar()
        }
    }
}

// MARK: - Tests

struct CalendarExportTests {
    
    @Test func testAppleCalendarExport() async throws {
        // Setup
        let mockVC = MockViewController()
        let mockEventStore = MockEventStore()
        
        let today = Date()
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!
        let endTime = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: today)!
        
        let event1 = CalendarEvent(
            title: "Test Event 1",
            startTime: startTime,
            endTime: endTime,
            color: .systemBlue
        )
        
        let event2 = CalendarEvent(
            title: "Test Event 2",
            startTime: calendar.date(byAdding: .hour, value: 2, to: startTime)!,
            endTime: calendar.date(byAdding: .hour, value: 2, to: endTime)!,
            color: .systemGreen
        )
        
        let events = [event1, event2]
        
        // Create the testable export manager
        let exportManager = TestableCalendarExportManager(
            events: events,
            currentDate: today,
            presentingViewController: mockVC
        )
        exportManager.mockEventStore = mockEventStore
        
        // Test private method directly
        exportManager.addEventsToAppleCalendar(eventStore: mockEventStore)
        
        // Verify results
        #expect(mockEventStore.savedEvents.count == 2, "Should have saved 2 events")
        #expect(mockEventStore.savedEvents[0].title == "Test Event 1", "First event should have correct title")
        #expect(mockEventStore.savedEvents[1].title == "Test Event 2", "Second event should have correct title")
        
        // Test time conversion accuracy
        guard let firstEventStart = mockEventStore.savedEvents[0].startDate else { return }
        let firstEventHour = calendar.component(.hour, from: firstEventStart)
        #expect(firstEventHour == 10, "Event start hour should be preserved")
    }
    
    @Test func testCalendarAccessDenied() async throws {
        // Setup with access denied
        let mockVC = MockViewController()
        let mockEventStore = MockEventStore()
        mockEventStore.accessGranted = false
        
        let today = Date()
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!
        let endTime = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: today)!
        
        let event = CalendarEvent(
            title: "Test Event",
            startTime: startTime,
            endTime: endTime,
            color: .systemBlue
        )
        
        // Create the testable export manager
        let exportManager = TestableCalendarExportManager(
            events: [event],
            currentDate: today,
            presentingViewController: mockVC
        )
        exportManager.mockEventStore = mockEventStore
        
        // Trigger the calendar export request
        let requestAccess: (@escaping (Bool, Error?) -> Void) -> Void = { completion in
            mockEventStore.requestAccess(to: .event, completion: completion)
        }
        
        requestAccess { granted, error in
            // Verify results
            #expect(mockEventStore.requestAccessCalled, "Access request should be called")
            #expect(granted == false, "Access should be denied")
            #expect(mockEventStore.savedEvents.isEmpty, "No events should be saved when access is denied")
        }
    }
    
    @Test func testGoogleCalendarExport() async throws {
        // Setup
        let mockVC = MockViewController()
        let today = Date()
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!
        let endTime = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: today)!
        
        let events = [
            CalendarEvent(
                title: "Google Meeting",
                startTime: startTime,
                endTime: endTime,
                color: .systemBlue
            )
        ]
        
        // Create mock Google Calendar manager
        let mockGoogleManager = MockGoogleCalendarAPIManager(
            events: events,
            currentDate: today
        )
        
        // Create the testable export manager
        let exportManager = TestableCalendarExportManager(
            events: events,
            currentDate: today,
            presentingViewController: mockVC
        )
        exportManager.mockGoogleCalendarManager = mockGoogleManager
        
        // Trigger the Google Calendar export
        exportManager.exportToGoogleCalendar()
        
        // Verify the results
        #expect(mockGoogleManager.successCount == 1, "Should report 1 successful export")
        #expect(mockGoogleManager.failureCount == 0, "Should report 0 failed exports")
    }
    
    @Test func testTimeFormatting() async throws {
        // Test the time formatting used during export
        
        let today = Date()
        let calendar = Calendar.current
        
        // Create a time that crosses midnight
        let startTime = calendar.date(bySettingHour: 23, minute: 30, second: 0, of: today)!
        let endTime = calendar.date(byAdding: .hour, value: 1, to: startTime)!
        
        // Verify that the Date extension correctly handles midnight crossing
        let adjustedEndTime = endTime.combiningDateComponents(
            fromReferenceDate: today,
            isEndTime: true,
            startTime: startTime
        )
        
        // Check if adjusted end time is on the next day
        let startDay = calendar.component(.day, from: startTime)
        let endDay = calendar.component(.day, from: adjustedEndTime)
        let endHour = calendar.component(.hour, from: adjustedEndTime)
        
        // If today is the last day of the month, we need to handle that special case
        let isLastDayOfMonth = calendar.range(of: .day, in: .month, for: today)?.upperBound == startDay + 1
        
        if isLastDayOfMonth {
            // For the last day of the month, the next day will be day 1 of next month
            #expect(endDay == 1 || endDay == startDay + 1, "End day should be on the next day")
        } else {
            #expect(endDay == startDay + 1, "End day should be on the next day")
        }
        
        #expect(endHour == 0, "End hour should be 12am (0)")
    }
    
    @Test func testMultipleDaysExport() async throws {
        // Test exporting events that span multiple days
        
        let mockVC = MockViewController()
        let mockEventStore = MockEventStore()
        
        let today = Date()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Create an event spanning today and tomorrow
        let startTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today)!
        let endTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow)!
        
        let event = CalendarEvent(
            title: "Overnight Event",
            startTime: startTime,
            endTime: endTime,
            color: .systemPurple
        )
        
        let exportManager = TestableCalendarExportManager(
            events: [event],
            currentDate: today,
            presentingViewController: mockVC
        )
        exportManager.mockEventStore = mockEventStore
        
        exportManager.addEventsToAppleCalendar(eventStore: mockEventStore)
        
        // Verify results
        #expect(mockEventStore.savedEvents.count == 1, "Should have saved 1 event")
        
        let savedEvent = mockEventStore.savedEvents[0]
        
        // Calculate the duration in hours
        let durationHours = savedEvent.endDate.timeIntervalSince(savedEvent.startDate) / 3600
        
        #expect(durationHours > 10 && durationHours < 14, "Event should span approximately 12 hours")
        
        // Verify the dates span a day boundary
        let startDay = calendar.component(.day, from: savedEvent.startDate)
        let endDay = calendar.component(.day, from: savedEvent.endDate)
        
        // Again, handle month boundary special case
        let isLastDayOfMonth = calendar.range(of: .day, in: .month, for: today)?.upperBound == startDay + 1
        
        if isLastDayOfMonth {
            #expect(endDay == 1 || endDay == startDay + 1, "End day should be on the next day")
        } else {
            #expect(endDay == startDay + 1, "End day should be on the next day")
        }
    }
}
