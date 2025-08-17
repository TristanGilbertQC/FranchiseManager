import Foundation
import SwiftUI

// MARK: - Enums and Supporting Types

enum SeasonPhase: String, CaseIterable, Codable {
    case preseason = "PRESEASON"
    case regular = "REGULAR"
    case playoffs = "PLAYOFFS"
    case offseason = "OFFSEASON"
    
    var displayName: String {
        switch self {
        case .preseason: return "Pre-Season"
        case .regular: return "Regular Season"
        case .playoffs: return "Playoffs"
        case .offseason: return "Off-Season"
        }
    }
}

enum SimulationSpeed: Double, CaseIterable {
    case slow = 1.0
    case normal = 3.0
    case fast = 7.0
    case veryFast = 30.0
    
    var displayName: String {
        switch self {
        case .slow: return "Slow"
        case .normal: return "Normal"
        case .fast: return "Fast"
        case .veryFast: return "Very Fast"
        }
    }
}

enum SimulationError: Error {
    case invalidDate(String)
    case scheduleConflict(String)
    case contractCalculationError(String)
    case corruptedSaveData(String)
}

struct SimulationEvent: Codable, Identifiable {
    var id: UUID
    let date: Date
    let type: EventType
    let priority: EventPriority
    let description: String
    
    enum EventType: String, Codable {
        case gameDay
        case contractExpiry
        case tradeDeadline
        case freeAgencyStart
        case draft
        case playerBirthday
        case injuryRecovery
        case seasonTransition
        case allStarBreak
        case playoffStart
    }
    
    enum EventPriority: Int, Codable {
        case low = 0
        case medium = 1
        case high = 2
        case critical = 3
    }
    
    init(date: Date, type: EventType, priority: EventPriority, description: String) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.priority = priority
        self.description = description
    }
}

// MARK: - Date Helpers Extension

extension Calendar {
    func daysBetween(_ date1: Date, and date2: Date) -> Int {
        let components = dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
    
    func isDate(_ date1: Date, inSameWeekAs date2: Date) -> Bool {
        return compare(date1, to: date2, toGranularity: .weekOfYear) == .orderedSame
    }
    
    func isDate(_ date1: Date, inSameMonthAs date2: Date) -> Bool {
        return compare(date1, to: date2, toGranularity: .month) == .orderedSame
    }
}

extension DateFormatter {
    static let gameDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    static let seasonYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    static let monthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
}

// MARK: - Important Dates Utility

struct ImportantDates {
    static func seasonStartDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = 10
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func regularSeasonStartDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = 10
        components.day = 10
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func allStarBreakDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year + 1
        components.month = 2
        components.day = 15
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func tradeDeadlineDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year + 1
        components.month = 3
        components.day = 3
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func regularSeasonEndDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year + 1
        components.month = 4
        components.day = 15
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func playoffStartDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year + 1
        components.month = 4
        components.day = 20
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func playoffEndDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year + 1
        components.month = 6
        components.day = 15
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func draftDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year + 1
        components.month = 6
        components.day = 25
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func freeAgencyStartDate(for year: Int) -> Date {
        var components = DateComponents()
        components.year = year + 1
        components.month = 7
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Event Queue

class EventQueue: ObservableObject, Codable {
    @Published private var events: [SimulationEvent] = []
    
    enum CodingKeys: CodingKey {
        case events
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        events = try container.decode([SimulationEvent].self, forKey: .events)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(events, forKey: .events)
    }
    
    init() {}
    
    func scheduleEvent(_ event: SimulationEvent) {
        events.append(event)
        events.sort { $0.date < $1.date }
    }
    
    func getEventsForDate(_ date: Date) -> [SimulationEvent] {
        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func removeProcessedEvents(before date: Date) {
        events.removeAll { $0.date < date }
    }
    
    func getAllEvents() -> [SimulationEvent] {
        return events
    }
    
    func getUpcomingEvents(limit: Int = 10) -> [SimulationEvent] {
        let now = Date()
        return events.filter { $0.date >= now }.prefix(limit).map { $0 }
    }
}

// MARK: - Season Calendar

class SeasonCalendar: ObservableObject, Codable {
    @Published var currentDate: Date
    @Published var season: Int
    @Published var phase: SeasonPhase
    @Published var eventQueue: EventQueue
    
    enum CodingKeys: CodingKey {
        case currentDate, season, phase, eventQueue
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentDate = try container.decode(Date.self, forKey: .currentDate)
        season = try container.decode(Int.self, forKey: .season)
        phase = try container.decode(SeasonPhase.self, forKey: .phase)
        eventQueue = try container.decode(EventQueue.self, forKey: .eventQueue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentDate, forKey: .currentDate)
        try container.encode(season, forKey: .season)
        try container.encode(phase, forKey: .phase)
        try container.encode(eventQueue, forKey: .eventQueue)
    }
    
    init(startYear: Int) {
        self.currentDate = ImportantDates.seasonStartDate(for: startYear)
        self.season = startYear
        self.phase = .preseason
        self.eventQueue = EventQueue()
        
        scheduleSeasonEvents()
    }
    
    // MARK: - Computed Properties
    
    var formattedDate: String {
        return DateFormatter.gameDate.string(from: currentDate)
    }
    
    var seasonDisplayString: String {
        return "\(season)-\(String(season + 1).suffix(2))"
    }
    
    var currentPhaseDisplayName: String {
        return phase.displayName
    }
    
    // MARK: - Date Progression
    
    func advanceDate(by days: Int) throws {
        guard days > 0 else {
            throw SimulationError.invalidDate("Cannot advance by negative days")
        }
        
        let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) ?? currentDate
        let oldDate = currentDate
        
        currentDate = newDate
        
        // Process events for each day
        var processingDate = oldDate
        for _ in 0..<days {
            processingDate = Calendar.current.date(byAdding: .day, value: 1, to: processingDate) ?? processingDate
            processEventsForDate(processingDate)
        }
        
        // Check for phase transitions
        updatePhaseIfNeeded()
        
        // Clean up old events
        eventQueue.removeProcessedEvents(before: Calendar.current.date(byAdding: .day, value: -7, to: currentDate) ?? currentDate)
    }
    
    func advanceToDate(_ targetDate: Date) throws {
        let days = Calendar.current.daysBetween(currentDate, and: targetDate)
        if days > 0 {
            try advanceDate(by: days)
        }
    }
    
    // MARK: - Phase Management
    
    private func updatePhaseIfNeeded() {
        let newPhase = getCurrentPhase()
        if newPhase != phase {
            let oldPhase = phase
            phase = newPhase
            
            // Schedule transition event
            let transitionEvent = SimulationEvent(
                date: currentDate,
                type: .seasonTransition,
                priority: .high,
                description: "Season phase changed from \(oldPhase.displayName) to \(newPhase.displayName)"
            )
            eventQueue.scheduleEvent(transitionEvent)
            
            // If moving to next season, update season year
            if oldPhase == .offseason && newPhase == .preseason {
                season += 1
                scheduleSeasonEvents()
            }
        }
    }
    
    private func getCurrentPhase() -> SeasonPhase {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        // Determine which season year we're in (hockey seasons span two calendar years)  
        let seasonYear = (currentMonth >= 8) ? currentYear : currentYear - 1
        
        let regularSeasonStart = ImportantDates.regularSeasonStartDate(for: seasonYear)
        let regularSeasonEnd = ImportantDates.regularSeasonEndDate(for: seasonYear)
        let playoffEnd = ImportantDates.playoffEndDate(for: seasonYear)
        
        if currentDate < regularSeasonStart {
            return .preseason
        } else if currentDate < regularSeasonEnd {
            return .regular
        } else if currentDate < playoffEnd {
            return .playoffs
        } else {
            return .offseason
        }
    }
    
    func getDaysUntilNextPhase() -> Int {
        let nextPhaseDate: Date
        
        switch phase {
        case .preseason:
            nextPhaseDate = ImportantDates.regularSeasonStartDate(for: season)
        case .regular:
            nextPhaseDate = ImportantDates.regularSeasonEndDate(for: season)
        case .playoffs:
            nextPhaseDate = ImportantDates.playoffEndDate(for: season)
        case .offseason:
            nextPhaseDate = ImportantDates.seasonStartDate(for: season + 1)
        }
        
        return max(0, Calendar.current.daysBetween(currentDate, and: nextPhaseDate))
    }
    
    // MARK: - Event Processing
    
    private func processEventsForDate(_ date: Date) {
        let events = eventQueue.getEventsForDate(date)
        for event in events {
            processEvent(event)
        }
    }
    
    private func processEvent(_ event: SimulationEvent) {
        // Process different event types
        switch event.type {
        case .gameDay:
            break // Game processing handled elsewhere
        case .contractExpiry:
            break // Contract processing handled elsewhere
        case .tradeDeadline:
            break // Trade deadline processing
        case .freeAgencyStart:
            break // Free agency processing
        case .draft:
            break // Draft processing
        case .playerBirthday:
            break // Player aging processing
        case .injuryRecovery:
            break // Injury recovery processing
        case .seasonTransition:
            break // Already handled in phase transitions
        case .allStarBreak:
            break // All-star break processing
        case .playoffStart:
            break // Playoff start processing
        }
    }
    
    // MARK: - Season Events Scheduling
    
    private func scheduleSeasonEvents() {
        // Clear existing events for this season
        eventQueue.removeProcessedEvents(before: ImportantDates.seasonStartDate(for: season + 2))
        
        // Schedule key season events
        let events = [
            SimulationEvent(
                date: ImportantDates.regularSeasonStartDate(for: season),
                type: .seasonTransition,
                priority: .high,
                description: "Regular season begins"
            ),
            SimulationEvent(
                date: ImportantDates.allStarBreakDate(for: season),
                type: .allStarBreak,
                priority: .medium,
                description: "All-Star Break"
            ),
            SimulationEvent(
                date: ImportantDates.tradeDeadlineDate(for: season),
                type: .tradeDeadline,
                priority: .critical,
                description: "Trade Deadline"
            ),
            SimulationEvent(
                date: ImportantDates.playoffStartDate(for: season),
                type: .playoffStart,
                priority: .high,
                description: "Playoffs begin"
            ),
            SimulationEvent(
                date: ImportantDates.draftDate(for: season),
                type: .draft,
                priority: .high,
                description: "Entry Draft"
            ),
            SimulationEvent(
                date: ImportantDates.freeAgencyStartDate(for: season),
                type: .freeAgencyStart,
                priority: .high,
                description: "Free Agency begins"
            )
        ]
        
        for event in events {
            eventQueue.scheduleEvent(event)
        }
    }
    
    // MARK: - Utility Methods
    
    func isTradeDeadline() -> Bool {
        let tradeDeadline = ImportantDates.tradeDeadlineDate(for: season)
        return Calendar.current.isDate(currentDate, inSameDayAs: tradeDeadline)
    }
    
    func isAllStarBreak() -> Bool {
        let allStarDate = ImportantDates.allStarBreakDate(for: season)
        let calendar = Calendar.current
        
        // All-star break is typically a week
        let breakStart = calendar.date(byAdding: .day, value: -3, to: allStarDate) ?? allStarDate
        let breakEnd = calendar.date(byAdding: .day, value: 3, to: allStarDate) ?? allStarDate
        
        return currentDate >= breakStart && currentDate <= breakEnd
    }
    
    func getGamesRemainingInSeason() -> Int {
        // This will be calculated based on scheduled games
        // For now, return estimated based on date
        switch phase {
        case .preseason:
            return 82
        case .regular:
            let regularSeasonEnd = ImportantDates.regularSeasonEndDate(for: season)
            let daysRemaining = Calendar.current.daysBetween(currentDate, and: regularSeasonEnd)
            return max(0, min(82, daysRemaining / 2)) // Rough estimate
        case .playoffs, .offseason:
            return 0
        }
    }
    
    func transitionToNextPhase() {
        let nextPhaseDate: Date
        
        switch phase {
        case .preseason:
            nextPhaseDate = ImportantDates.regularSeasonStartDate(for: season)
        case .regular:
            nextPhaseDate = ImportantDates.regularSeasonEndDate(for: season)
        case .playoffs:
            nextPhaseDate = ImportantDates.playoffEndDate(for: season)
        case .offseason:
            nextPhaseDate = ImportantDates.seasonStartDate(for: season + 1)
        }
        
        do {
            try advanceToDate(nextPhaseDate)
        } catch {
            print("Error transitioning to next phase: \(error)")
        }
    }
    
    // MARK: - Save/Load
    
    func save(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }
    
    static func load(from url: URL) throws -> SeasonCalendar {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(SeasonCalendar.self, from: data)
    }
}

// MARK: - Game Simulation Context Protocol

protocol GameSimulationContext {
    var currentDate: Date { get }
    var seasonPhase: SeasonPhase { get }
    var daysSinceLastGame: Int { get }
    var isBackToBack: Bool { get }
    var travelFatigue: Double { get }
}

extension SeasonCalendar: GameSimulationContext {
    var seasonPhase: SeasonPhase {
        return phase
    }
    
    var daysSinceLastGame: Int {
        // This would be calculated based on team's last game
        // For now, return a default value
        return 1
    }
    
    var isBackToBack: Bool {
        // This would check if team played yesterday
        // For now, return false
        return false
    }
    
    var travelFatigue: Double {
        // This would calculate based on travel distance and time
        // For now, return no fatigue
        return 0.0
    }
}