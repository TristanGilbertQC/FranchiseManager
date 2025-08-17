import SwiftUI

struct CalendarView: View {
    @Binding var savedGame: SavedGame
    @State private var currentMonth = Date()
    @StateObject private var advanceDayManager = AdvanceDayManager()
    
    private var currentDate: Date {
        savedGame.currentDate
    }
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstDayOfWeek = calendar.component(.weekday, from: firstOfMonth)
        let daysFromPreviousMonth = (firstDayOfWeek - calendar.firstWeekday + 7) % 7
        
        let startDate = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: firstOfMonth)!
        
        return (0..<42).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Calendar Header
            VStack(spacing: 10) {
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(monthYear)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Current game date indicator
                Text("Current Date: \(DateFormatter.gameDate.string(from: currentDate))")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            // Days of week header
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(days, id: \.self) { date in
                    CalendarDayCardView(
                        date: date,
                        currentDate: currentDate,
                        currentMonth: currentMonth,
                        savedGame: savedGame
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Advance Day Button
            VStack(spacing: 15) {
                if advanceDayManager.isSimulating {
                    VStack(spacing: 10) {
                        ProgressView(value: advanceDayManager.simulationProgress)
                            .frame(maxWidth: 200)
                        
                        Text(advanceDayManager.simulationStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Button("Advance Day") {
                        advanceOneDay()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 200)
                    .disabled(advanceDayManager.isSimulating)
                }
            }
            .padding()
        }
        .onAppear {
            // Set current month to the game's current date
            currentMonth = currentDate
        }
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func advanceOneDay() {
        Task { @MainActor in
            do {
                savedGame = try await advanceDayManager.advanceDay(savedGame: savedGame)
                // Update current month to follow the game date
                currentMonth = savedGame.currentDate
            } catch {
                print("Error advancing day: \(error)")
            }
        }
    }
}

struct CalendarDayCardView: View {
    let date: Date
    let currentDate: Date
    let currentMonth: Date
    let savedGame: SavedGame
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isCurrentDate: Bool {
        calendar.isDate(date, inSameDayAs: currentDate)
    }
    
    private var isInCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private var playerTeamGames: [Game] {
        savedGame.currentSeason.games.filter { game in
            calendar.isDate(game.date, inSameDayAs: date) &&
            (game.homeTeamId == savedGame.playerTeamId || game.awayTeamId == savedGame.playerTeamId)
        }
    }
    
    private var hasPlayerGame: Bool {
        !playerTeamGames.isEmpty
    }
    
    private var opponentInfo: (abbreviation: String, isHome: Bool)? {
        guard let game = playerTeamGames.first else { return nil }
        
        let isPlayerHome = game.homeTeamId == savedGame.playerTeamId
        let opponentId = isPlayerHome ? game.awayTeamId : game.homeTeamId
        
        if let opponent = savedGame.league.teams.first(where: { $0.id == opponentId }) {
            return (opponent.abbreviation, !isPlayerHome)
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Day number
            Text(dayNumber)
                .font(.system(size: 14, weight: isCurrentDate ? .bold : .medium))
                .foregroundColor(dayTextColor)
            
            // Game information
            if hasPlayerGame, let opponent = opponentInfo {
                VStack(spacing: 2) {
                    // Opponent abbreviation
                    Text(opponent.abbreviation)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(gameTextColor)
                        .lineLimit(1)
                    
                    // Home/Away indicator
                    Text(opponent.isHome ? "H" : "@")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(gameTextColor.opacity(0.8))
                }
            } else if isInCurrentMonth {
                // Empty space to maintain consistent card height
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
            }
        }
        .frame(minWidth: 50, minHeight: 60)
        .padding(4)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(cardBorderColor, lineWidth: cardBorderWidth)
        )
        .cornerRadius(8)
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 1)
        .opacity(cardOpacity)
    }
    
    // MARK: - Computed Styling Properties
    
    private var dayTextColor: Color {
        if isCurrentDate {
            return .white
        } else if !isInCurrentMonth {
            return .secondary
        } else if hasPlayerGame {
            return .primary
        } else {
            return .primary
        }
    }
    
    private var gameTextColor: Color {
        if isCurrentDate {
            return .white
        } else {
            return .blue
        }
    }
    
    private var cardBackground: Color {
        if isCurrentDate {
            return .red
        } else if hasPlayerGame {
            return Color.blue.opacity(0.1)
        } else if isInCurrentMonth {
            return Color.gray.opacity(0.05)
        } else {
            return Color.clear
        }
    }
    
    private var cardBorderColor: Color {
        if isCurrentDate {
            return .red
        } else if hasPlayerGame {
            return .blue.opacity(0.3)
        } else if isInCurrentMonth {
            return Color.gray.opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    private var cardBorderWidth: CGFloat {
        if isCurrentDate || hasPlayerGame {
            return 1.5
        } else {
            return 0.5
        }
    }
    
    private var shadowColor: Color {
        if isCurrentDate {
            return .red.opacity(0.3)
        } else if hasPlayerGame {
            return .blue.opacity(0.2)
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private var shadowRadius: CGFloat {
        if isCurrentDate || hasPlayerGame {
            return 3
        } else {
            return 1
        }
    }
    
    private var cardOpacity: Double {
        if !isInCurrentMonth {
            return 0.4
        } else {
            return 1.0
        }
    }
}