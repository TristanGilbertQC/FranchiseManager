import SwiftUI

enum PositionFilter: String, CaseIterable {
    case all = "ALL"
    case defensemen = "DEFENSEMEN"
    case forwards = "FORWARDS"
    case goalies = "GOALIES"
    
    var displayName: String {
        switch self {
        case .all: return "ALL"
        case .defensemen: return "DEFENSEMEN"
        case .forwards: return "FORWARDS"
        case .goalies: return "GOALIES"
        }
    }
}

enum InjuryFilter: String, CaseIterable {
    case all = "ALL"
    case healthy = "HEALTHY"
    case injured = "INJURED"
    
    var displayName: String { rawValue }
}

enum WTCFilter: String, CaseIterable {
    case all = "ALL"
    case available = "AVAILABLE"
    case ntc = "NTC"
    case mntc = "M-NTC"
    
    var displayName: String { rawValue }
}

enum OverallFilter: String, CaseIterable {
    case all = "ALL"
    case elite = "85+"
    case good = "75-84"
    case average = "65-74" 
    case below = "Under 65"
    
    var displayName: String { rawValue }
}

struct TradesView: View {
    @Binding var savedGame: SavedGame
    @State private var selectedPositionFilter: PositionFilter = .all
    @State private var selectedInjuryFilter: InjuryFilter = .all
    @State private var selectedWTCFilter: WTCFilter = .all
    @State private var selectedOverallFilter: OverallFilter = .all
    @State private var sortBy: SortOption = .tradeValue
    @State private var sortAscending = false
    
    enum SortOption {
        case position, player, overall, tradeValue
    }
    
    var playerTeam: Team? {
        savedGame.league.teams.first { $0.id == savedGame.playerTeamId }
    }
    
    var filteredAndSortedPlayers: [Player] {
        guard let team = playerTeam else { return [] }
        
        var players = team.roster
        
        // Apply position filter
        switch selectedPositionFilter {
        case .all:
            break
        case .defensemen:
            players = players.filter { $0.position == .leftDefense || $0.position == .rightDefense }
        case .forwards:
            players = players.filter { $0.position == .center || $0.position == .leftWing || $0.position == .rightWing }
        case .goalies:
            players = players.filter { $0.position == .goalie }
        }
        
        // Apply injury filter
        switch selectedInjuryFilter {
        case .all:
            break
        case .healthy:
            players = players.filter { _ in true } // Assuming no injury system yet
        case .injured:
            players = players.filter { _ in false } // Assuming no injury system yet
        }
        
        // Apply WTC (Willingness to Trade) filter
        switch selectedWTCFilter {
        case .all:
            break
        case .available:
            players = players.filter { $0.overall < 75 }
        case .ntc:
            players = players.filter { $0.overall >= 85 }
        case .mntc:
            players = players.filter { $0.overall >= 75 && $0.overall < 85 }
        }
        
        // Apply overall rating filter
        switch selectedOverallFilter {
        case .all:
            break
        case .elite:
            players = players.filter { $0.overall >= 85 }
        case .good:
            players = players.filter { $0.overall >= 75 && $0.overall < 85 }
        case .average:
            players = players.filter { $0.overall >= 65 && $0.overall < 75 }
        case .below:
            players = players.filter { $0.overall < 65 }
        }
        
        // Apply sorting
        players.sort { player1, player2 in
            let result: Bool
            switch sortBy {
            case .position:
                result = player1.position.rawValue < player2.position.rawValue
            case .player:
                result = player1.fullName < player2.fullName
            case .overall:
                result = player1.overall < player2.overall
            case .tradeValue:
                result = tradeValue(for: player1) < tradeValue(for: player2)
            }
            return sortAscending ? result : !result
        }
        
        return players
    }
    
    var hasActiveFilters: Bool {
        selectedPositionFilter != .all || 
        selectedWTCFilter != .all || 
        selectedInjuryFilter != .all || 
        selectedOverallFilter != .all
    }
    
    func clearAllFilters() {
        selectedPositionFilter = .all
        selectedWTCFilter = .all
        selectedInjuryFilter = .all
        selectedOverallFilter = .all
    }
    
    func tradeValue(for player: Player) -> Double {
        return Double(player.overall) / 100.0
    }
    
    func tradeValueColor(for player: Player) -> Color {
        let overall = player.overall
        if overall >= 85 {
            return .green
        } else if overall >= 70 {
            return .yellow
        } else {
            return .red
        }
    }
    
    func potentialLabel(for player: Player) -> String {
        let overall = player.overall
        if overall >= 85 {
            return "EXACT"
        } else if overall >= 80 {
            return "EXACT"
        } else if overall >= 75 {
            return "LOW"
        } else {
            return "MED"
        }
    }
    
    func potentialColor(for player: Player) -> Color {
        let label = potentialLabel(for: player)
        switch label {
        case "EXACT":
            return .white
        case "LOW":
            return .blue
        case "MED":
            return .gray
        default:
            return .white
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("FRANCHISE MODE SELECT PLAYER")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if let team = playerTeam {
                    Text("\(team.city) | \(savedGame.calendar.formattedDate)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.black)
            
            // Filter buttons
            HStack(spacing: 4) {
                ForEach(PositionFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedPositionFilter = filter
                    }) {
                        Text(filter.displayName)
                            .font(.caption)
                            .foregroundColor(selectedPositionFilter == filter ? .white : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedPositionFilter == filter ? Color.gray.opacity(0.3) : Color.clear)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Button("POSITION") {
                    sortBy = .position
                    sortAscending.toggle()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(4)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.black)
            
            // Column headers with filter dropdowns
            HStack {
                Menu {
                    ForEach(PositionFilter.allCases, id: \.self) { filter in
                        Button(filter.displayName) {
                            selectedPositionFilter = filter
                        }
                    }
                } label: {
                    HStack {
                        Text("POS")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .frame(width: 40, alignment: .leading)
                
                Menu {
                    ForEach(WTCFilter.allCases, id: \.self) { filter in
                        Button(filter.displayName) {
                            selectedWTCFilter = filter
                        }
                    }
                } label: {
                    HStack {
                        Text("WTC")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .frame(width: 60, alignment: .center)
                
                Menu {
                    ForEach(InjuryFilter.allCases, id: \.self) { filter in
                        Button(filter.displayName) {
                            selectedInjuryFilter = filter
                        }
                    }
                } label: {
                    HStack {
                        Text("INJ")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .frame(width: 40, alignment: .center)
                
                Text("CLAUSE")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .center)
                
                Button("PLAYER") {
                    sortBy = .player
                    sortAscending.toggle()
                }
                .font(.caption)
                .foregroundColor(.gray)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                Text("LEAGUE")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 60, alignment: .center)
                
                Text("POT")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .center)
                
                Button("TRADE VALUE") {
                    sortBy = .tradeValue
                    sortAscending.toggle()
                }
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 120, alignment: .center)
                
                Menu {
                    ForEach(OverallFilter.allCases, id: \.self) { filter in
                        Button(filter.displayName) {
                            selectedOverallFilter = filter
                        }
                    }
                } label: {
                    HStack {
                        Text("OVR")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .frame(width: 40, alignment: .center)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            // Active filters summary
            if hasActiveFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Text("Active Filters:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if selectedPositionFilter != .all {
                            FilterChip(title: "POS: \(selectedPositionFilter.displayName)") {
                                selectedPositionFilter = .all
                            }
                        }
                        
                        if selectedWTCFilter != .all {
                            FilterChip(title: "WTC: \(selectedWTCFilter.displayName)") {
                                selectedWTCFilter = .all
                            }
                        }
                        
                        if selectedInjuryFilter != .all {
                            FilterChip(title: "INJ: \(selectedInjuryFilter.displayName)") {
                                selectedInjuryFilter = .all
                            }
                        }
                        
                        if selectedOverallFilter != .all {
                            FilterChip(title: "OVR: \(selectedOverallFilter.displayName)") {
                                selectedOverallFilter = .all
                            }
                        }
                        
                        Button("Clear All") {
                            clearAllFilters()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 4)
                .background(Color.black)
            }
            
            // Player list
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(filteredAndSortedPlayers) { player in
                        PlayerTradeRow(player: player, tradeValue: tradeValue, tradeValueColor: tradeValueColor, potentialLabel: potentialLabel, potentialColor: potentialColor)
                    }
                }
            }
            .background(Color.black)
            
            // Bottom info
            HStack {
                if let team = playerTeam {
                    HStack {
                        AsyncImage(url: URL(string: "https://via.placeholder.com/50x50")) { image in
                            image.resizable()
                        } placeholder: {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 50, height: 50)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        
                        Text(team.abbreviation)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("SALARY CAP AVAILABLE")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$10.430M")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("LEGEND")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("INTERESTED IN GIVING AWAY")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color.black)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

struct PlayerTradeRow: View {
    let player: Player
    let tradeValue: (Player) -> Double
    let tradeValueColor: (Player) -> Color
    let potentialLabel: (Player) -> String
    let potentialColor: (Player) -> Color
    
    var body: some View {
        HStack {
            // Position
            Text(player.position.rawValue)
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 40, alignment: .leading)
            
            // WTC (Willingness to Trade)
            if player.overall < 75 {
                Text("M-NTC")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(3)
                    .frame(width: 60, alignment: .center)
            } else {
                Text("-")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 60, alignment: .center)
            }
            
            // Injury
            Text("-")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 40, alignment: .center)
            
            // Clause
            Text("-")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .center)
            
            // Player name
            Text(player.fullName)
                .font(.caption)
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            // League
            Image(systemName: "sportscourt")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 60, alignment: .center)
            
            // Potential
            HStack {
                Text("Elite")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(potentialLabel(player))
                    .font(.caption)
                    .foregroundColor(potentialColor(player))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(2)
            }
            .frame(width: 80, alignment: .center)
            
            // Trade Value Bar
            HStack {
                Rectangle()
                    .fill(tradeValueColor(player))
                    .frame(width: CGFloat(tradeValue(player)) * 80, height: 8)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80 - CGFloat(tradeValue(player)) * 80, height: 8)
                    .cornerRadius(2)
            }
            .frame(width: 120, alignment: .center)
            
            // Overall
            Text("\(player.overall)")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 40, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.black)
    }
}

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.3))
        .cornerRadius(12)
    }
}