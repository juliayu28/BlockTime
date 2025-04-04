//
//  AIScheduleGenerator.swift
//  Block Time
//
//  Created by Julia Yu on 3/28/25.
//
import UIKit

class AIScheduleGenerator {
    // MARK: - Properties
    private let apiKey: String
    private let apiEndpoint = "https://api.anthropic.com/v1/messages"
    private let model = "claude-3-7-sonnet-20250219"
    
    // MARK: - Initialization
    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ClaudeAPIKey") as? String,
              !apiKey.isEmpty else {
            fatalError("Claude API Key not found in Info.plist. Add a string entry with key 'ClaudeAPIKey'")
        }
        
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    func generateSchedule(
        templates: [EventTemplate],
        date: Date,
        startHour: Int = 9,
        endHour: Int = 21,
        constraints: String? = nil,
        completion: @escaping (Result<[CalendarEvent], Error>) -> Void
    ) {
        let formattedTemplates = formatTemplatesForPrompt(templates)
        let prompt = createPrompt(
            templates: formattedTemplates,
            date: date,
            startHour: startHour,
            endHour: endHour,
            constraints: constraints
        )
        
        callClaudeAPI(prompt: prompt) { result in
            switch result {
            case .success(let responseText):
                do {
                    let events = try self.parseResponseToEvents(
                        response: responseText,
                        templates: templates,
                        date: date
                    )
                    completion(.success(events))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func formatTemplatesForPrompt(_ templates: [EventTemplate]) -> String {
        let templatePairs = templates.map { "\"\($0.title)\": \(Int($0.duration))" }
        return "{\(templatePairs.joined(separator: ", "))}"
    }
    
    private func createPrompt(
        templates: String,
        date: Date,
        startHour: Int,
        endHour: Int,
        constraints: String?
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        
        var prompt = """
        I need you to create a daily schedule for \(dateString) using the following activities and their durations (in minutes):
        
        \(templates)
        
        Requirements:
        1. Schedule activities between \(startHour):00 AM and \(endHour):00 PM
        2. Include appropriate breaks between activities
        3. Try to create a balanced day with a good mix of activities
        4. Each activity should have a specific start time and end time
        
        """
        
        if let constraints = constraints, !constraints.isEmpty {
            prompt += "Additional constraints/preferences:\n\(constraints)\n\n"
        }
        
        prompt += """
        Return the schedule in a JSON format that I can parse. Use this exact format:
        
        ```json
        [
          {
            "title": "Activity Name",
            "startTime": "HH:MM",
            "endTime": "HH:MM"
          },
          {
            "title": "Next Activity",
            "startTime": "HH:MM",
            "endTime": "HH:MM"
          }
        ]
        ```
        
        Please ensure there are no overlapping times, and all times are valid within the \(startHour) AM to \(endHour) PM range.
        """
        
        return prompt
    }
    
    private func callClaudeAPI(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: apiEndpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(apiKey)", forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 1000,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let content = json["content"] as? [[String: Any]],
                   let firstMessage = content.first,
                   let text = firstMessage["text"] as? String {
                    
                    DispatchQueue.main.async {
                        completion(.success(text))
                    }
                } else if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let error = errorJson["error"] as? [String: Any],
                          let message = error["message"] as? String {
                    DispatchQueue.main.async {
                        completion(.failure(APIError.apiError(message)))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(APIError.invalidResponse))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func parseResponseToEvents(
        response: String,
        templates: [EventTemplate],
        date: Date
    ) throws -> [CalendarEvent] {
        guard let jsonString = extractJSONFromResponse(response) else {
            throw APIError.invalidJSON
        }
        
        guard let jsonData = jsonString.data(using: .utf8),
              let eventDicts = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            throw APIError.invalidJSON
        }
        
        let templateLookup = Dictionary(uniqueKeysWithValues: templates.map { ($0.title, $0) })
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)
        
        let events = eventDicts.compactMap { eventDict -> CalendarEvent? in
            guard let title = eventDict["title"] as? String,
                  let startTimeString = eventDict["startTime"] as? String,
                  let endTimeString = eventDict["endTime"] as? String,
                  let startDate = parseTimeString(startTimeString, baseDate: dateStart),
                  let endDate = parseTimeString(endTimeString, baseDate: dateStart) else {
                return nil
            }
            
            let color = templateLookup[title]?.color ?? UIColor.systemBlue.withAlphaComponent(0.7)
            
            return CalendarEvent(
                id: UUID(),
                title: title,
                startTime: startDate,
                endTime: endDate,
                color: color
            )
        }
        
        return events.sorted { $0.startTime < $1.startTime }
    }
    
    private func extractJSONFromResponse(_ response: String) -> String? {
        let jsonPattern = "```json\\s*(.+?)\\s*```"
        let regex = try? NSRegularExpression(pattern: jsonPattern, options: [.dotMatchesLineSeparators])
        
        if let match = regex?.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)),
           let jsonRange = Range(match.range(at: 1), in: response) {
            return String(response[jsonRange])
        }
        
        if response.contains("[") && response.contains("]") {
            if let startIndex = response.firstIndex(of: "["),
               let endIndex = response.lastIndex(of: "]") {
                return String(response[startIndex...endIndex])
            }
        }
        
        return nil
    }
    
    private func parseTimeString(_ timeString: String, baseDate: Date) -> Date? {
        let components = timeString.components(separatedBy: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]),
              hour >= 0, hour < 24,
              minute >= 0, minute < 60 else {
            return nil
        }
        
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate)
    }
    
    // MARK: - Error Types
    enum APIError: Error, LocalizedError {
        case invalidURL
        case noData
        case invalidResponse
        case invalidJSON
        case apiError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .noData:
                return "No data received from API"
            case .invalidResponse:
                return "Invalid response from API"
            case .invalidJSON:
                return "Could not parse schedule from API response"
            case .apiError(let message):
                return "API Error: \(message)"
            }
        }
    }
}
