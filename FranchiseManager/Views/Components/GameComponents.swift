import SwiftUI

struct EventRowView: View {
    let event: SimulationEvent
    
    var body: some View {
        HStack {
            Image(systemName: iconForEventType(event.type))
                .foregroundColor(colorForPriority(event.priority))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.description)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(DateFormatter.gameDate.string(from: event.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(event.type.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(colorForPriority(event.priority).opacity(0.2))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
    
    private func iconForEventType(_ type: SimulationEvent.EventType) -> String {
        switch type {
        case .gameDay: return "sportscourt"
        case .contractExpiry: return "doc.text"
        case .tradeDeadline: return "arrow.left.arrow.right"
        case .freeAgencyStart: return "person.badge.plus"
        case .draft: return "list.bullet.clipboard"
        case .playerBirthday: return "birthday.cake"
        case .injuryRecovery: return "cross.case"
        case .seasonTransition: return "calendar.circle"
        case .allStarBreak: return "star.circle"
        case .playoffStart: return "trophy"
        }
    }
    
    private func colorForPriority(_ priority: SimulationEvent.EventPriority) -> Color {
        switch priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct GameRowView: View {
    let game: Game
    let savedGame: SavedGame
    
    var homeTeam: Team? {
        return savedGame.league.teams.first { $0.id == game.homeTeamId }
    }
    
    var awayTeam: Team? {
        return savedGame.league.teams.first { $0.id == game.awayTeamId }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(awayTeam?.abbreviation ?? "???") @ \(homeTeam?.abbreviation ?? "???")")
                    .font(.headline)
                
                Text(game.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if game.isCompleted, let result = game.result {
                Text("\(result.awayScore) - \(result.homeScore)")
                    .font(.title3)
                    .fontWeight(.semibold)
            } else {
                Text("TBD")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(8)
    }
}