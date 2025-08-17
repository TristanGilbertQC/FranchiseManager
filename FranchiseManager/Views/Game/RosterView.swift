import SwiftUI

struct RosterView: View {
    @Binding var savedGame: SavedGame
    @State private var selectedPosition: Position? = nil // nil = All Players
    @State private var displayType: DisplayType = .stats
    @State private var sortColumn = "OVR"
    @State private var sortAscending = false
    @State private var selectedPlayer: Player? = nil
    
    enum DisplayType: String, CaseIterable {
        case stats = "Stats"
        case attributes = "Attributes"
    }
    
    private let positionOptions: [Position?] = [nil, .center, .leftWing, .rightWing, .leftDefense, .rightDefense, .goalie]
    
    private func positionDisplayName(_ position: Position?) -> String {
        guard let position = position else { return "All Players" }
        switch position {
        case .center: return "Center"
        case .leftWing: return "Left Wing"
        case .rightWing: return "Right Wing"
        case .leftDefense: return "Left Defense"
        case .rightDefense: return "Right Defense"
        case .goalie: return "Goalie"
        }
    }
    
    var playerTeam: Team? {
        return savedGame.league.teams.first { $0.id == savedGame.playerTeamId }
    }
    
    var filteredPlayers: [Player] {
        guard let team = playerTeam else { return [] }
        
        let players = team.roster
        
        if let position = selectedPosition {
            return players.filter { $0.position == position }
        }
        
        return players // All players
    }
    
    var sortedPlayers: [Player] {
        return filteredPlayers.sorted { player1, player2 in
            switch sortColumn {
            case "OVR":
                return sortAscending ? player1.overall < player2.overall : player1.overall > player2.overall
            case "AGE":
                return sortAscending ? player1.age < player2.age : player1.age > player2.age
            case "SAL":
                let sal1 = player1.contract?.salary ?? 0
                let sal2 = player2.contract?.salary ?? 0
                return sortAscending ? sal1 < sal2 : sal1 > sal2
            default:
                return false
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#3D1A1A"),
                    Color(hex: "#000000")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Filter Controls
                filterControls
                
                // Main Content - Conditional Layout
                if let selectedPlayer = selectedPlayer, let team = playerTeam {
                    // Show player detail view when player is selected
                    HStack(alignment: .top, spacing: 20) {
                        // Left side: Condensed player table (40% of space)
                        VStack(spacing: 0) {
                            Text("ROSTER")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            condensedTableView
                        }
                        .frame(maxWidth: .infinity)
                        .layoutPriority(1)
                        
                        // Right side: Player detail view (60% of space)
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("PLAYER DETAILS")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button("Back to Roster") {
                                    self.selectedPlayer = nil
                                }
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#FF6B35"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(hex: "#4A2525"))
                                )
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.bottom, 15)
                            
                            PlayerDetailView(player: selectedPlayer, team: team)
                        }
                        .frame(maxWidth: .infinity)
                        .layoutPriority(2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                } else {
                    // Show full roster layout when no player is selected
                    HStack(alignment: .top, spacing: 20) {
                        // Left side: Player table (takes 2/3 of space)
                        tableView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .layoutPriority(2)
                        
                        // Right side: Statistics card (takes 1/3 of space)
                        statisticsCard
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .layoutPriority(1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                }
                
                // Bottom Statistics Section (spans full width)
                statisticsSection
            }
        }
        .cornerRadius(10)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("FRANCHISE MODE ROSTER MOVES")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .textCase(.uppercase)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(playerTeam?.fullName ?? "No Team")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Text(DateFormatter.gameDate.string(from: savedGame.currentDate))
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    // MARK: - Filter Controls
    private var filterControls: some View {
        HStack(spacing: 10) {
            // Position Filter Dropdown
            Menu {
                ForEach(positionOptions.indices, id: \.self) { index in
                    let position = positionOptions[index]
                    Button(action: {
                        selectedPosition = position
                    }) {
                        HStack {
                            Text(positionDisplayName(position))
                            if selectedPosition == position {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(positionDisplayName(selectedPosition))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#4A2525"))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Display Type Dropdown
            Menu {
                ForEach(DisplayType.allCases, id: \.self) { type in
                    Button(action: {
                        displayType = type
                    }) {
                        HStack {
                            Text(type.rawValue)
                            if displayType == type {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(displayType.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#4A2525"))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Table View
    private var tableView: some View {
        VStack(spacing: 0) {
            // Table Headers
            tableHeaders
            
            // Table Rows
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                        PlayerRowView(
                            player: player,
                            displayType: displayType,
                            isEvenRow: index % 2 == 1,
                            onTap: {
                                print("🎯 Player clicked: \(player.fullName)")
                                selectedPlayer = player
                                print("🎯 selectedPlayer set to: \(selectedPlayer?.fullName ?? "nil")")
                                print("🎯 playerTeam available: \(playerTeam?.fullName ?? "nil")")
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Condensed Table View
    private var condensedTableView: some View {
        VStack(spacing: 0) {
            // Condensed Table Headers
            HStack(spacing: 0) {
                TableHeaderText("POS", width: 40)
                TableHeaderText("PLAYER", width: 100, alignment: .leading)
                TableHeaderText("OVR", width: 45)
            }
            .padding(.horizontal, 10)
            .padding(.top, 15)
            .padding(.bottom, 8)
            
            // Condensed Table Rows
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                        CondensedPlayerRowView(
                            player: player,
                            isEvenRow: index % 2 == 1,
                            isSelected: selectedPlayer?.id == player.id,
                            onTap: {
                                print("🎯 Condensed player clicked: \(player.fullName)")
                                selectedPlayer = player
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Table Headers
    private var tableHeaders: some View {
        HStack(spacing: 0) {
            TableHeaderText("POS", width: 50)
            TableHeaderText("PLAYER", width: 120, alignment: .leading)
            
            HStack(spacing: 2) {
                TableHeaderText("OVR", width: 50)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
                    .foregroundColor(Color(hex: "#888888"))
            }
            .frame(width: 60)
            
            if displayType == .stats {
                // Stats headers
                TableHeaderText("GP", width: 40)
                TableHeaderText("G", width: 40)
                TableHeaderText("A", width: 40)
                TableHeaderText("PTS", width: 40)
                TableHeaderText("+/-", width: 40)
                TableHeaderText("PIM", width: 40)
                TableHeaderText("SOG", width: 40)
                TableHeaderText("HITS", width: 50)
                TableHeaderText("TOI", width: 50, alignment: .trailing)
            } else {
                // Attributes headers
                TableHeaderText("SPD", width: 40)
                TableHeaderText("SHT", width: 40)
                TableHeaderText("PAS", width: 40)
                TableHeaderText("DEF", width: 40)
                TableHeaderText("STR", width: 40)
                TableHeaderText("BAL", width: 40)
                TableHeaderText("AGI", width: 40)
                TableHeaderText("STA", width: 40)
                TableHeaderText("CLU", width: 50, alignment: .trailing)
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        HStack(spacing: 20) {
            // Team Salary Block
            StatBlock(
                title: "TEAM SALARY",
                primaryValue: formatSalary(playerTeam?.salary ?? 0),
                secondaryText: "Cap Hit: \(formatSalary(playerTeam?.salary ?? 0))\nSpace: \(formatSalary(playerTeam?.capSpace ?? 0))"
            )
            
            // NHL Salary Cap Block
            StatBlock(
                title: "NHL SALARY CAP",
                primaryValue: formatSalary(playerTeam?.salaryCap ?? 80000000),
                secondaryText: "Min: \(formatSalary(playerTeam?.salaryCap ?? 80000000))\nMax: \(formatSalary(playerTeam?.salaryCap ?? 80000000))"
            )
            
            // NHL Roster Block
            StatBlock(
                title: "NHL ROSTER",
                primaryValue: "\(playerTeam?.rosterCount ?? 0)",
                secondaryText: "Skaters: \(skatersCount)\nGoalies: \(goaliesCount)"
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color(hex: "#1A0F0F"))
        .padding(.top, 20)
    }
    
    // MARK: - Computed Properties
    private var skatersCount: Int {
        guard let team = playerTeam else { return 0 }
        return team.roster.filter { $0.position != .goalie }.count
    }
    
    private var goaliesCount: Int {
        guard let team = playerTeam else { return 0 }
        return team.roster.filter { $0.position == .goalie }.count
    }
    
    private var topScorer: Player? {
        guard let team = playerTeam else { return nil }
        return team.roster
            .filter { $0.position != .goalie && $0.seasonStats.gamesPlayed > 0 }
            .max { $0.seasonStats.points < $1.seasonStats.points }
    }
    
    private var topGoalie: Player? {
        guard let team = playerTeam else { return nil }
        return team.roster
            .filter { $0.position == .goalie && $0.seasonStats.gamesPlayed > 0 }
            .max { $0.seasonStats.wins < $1.seasonStats.wins }
    }
    
    private func formatSalary(_ amount: Int) -> String {
        if amount >= 1000000 {
            return String(format: "%.1fM", Double(amount) / 1000000.0)
        } else if amount >= 1000 {
            return String(format: "%.0fK", Double(amount) / 1000.0)
        } else {
            return "\(amount)"
        }
    }
    
    // MARK: - Statistics Card
    private var statisticsCard: some View {
        VStack(spacing: 0) {
            // Section 1: Future feature placeholder
            VStack {
                // Future feature placeholder
                Spacer()
            }
            .frame(minHeight: 100)
            
            // Divider
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
            
            // Section 2: Top Scorer
            VStack(alignment: .leading, spacing: 8) {
                Text("TOP SCORER")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#00CED1"))
                    .textCase(.uppercase)
                
                if let scorer = topScorer {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(scorer.fullName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(scorer.position.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: "#4A2525"))
                                )
                        }
                        
                        Text("\(scorer.seasonStats.goals) - \(scorer.seasonStats.assists) - \(scorer.seasonStats.points)")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#888888"))
                    }
                } else {
                    Text("No stats available")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#888888"))
                        .italic()
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Divider
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
            
            // Section 3: Top Goalie
            VStack(alignment: .leading, spacing: 8) {
                Text("TOP GOALIE")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#00CED1"))
                    .textCase(.uppercase)
                
                if let goalie = topGoalie {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(goalie.fullName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("G")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: "#4A2525"))
                                )
                        }
                        
                        Text("\(goalie.seasonStats.wins)-\(goalie.seasonStats.losses) | \(String(format: "%.2f", goalie.seasonStats.goalsAgainstAverage)) | \(String(format: "%.3f", goalie.seasonStats.savePercentage))")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#888888"))
                    }
                } else {
                    Text("No stats available")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#888888"))
                        .italic()
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 250, maxWidth: .infinity)
        .padding(20)
        .background(
            ZStack {
                // Base background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#1A0F0F").opacity(0.9))
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.2),
                                Color.clear,
                                Color.black.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#333333"), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Views


struct TableHeaderText: View {
    let text: String
    let width: CGFloat
    let alignment: HorizontalAlignment
    
    init(_ text: String, width: CGFloat, alignment: HorizontalAlignment = .center) {
        self.text = text
        self.width = width
        self.alignment = alignment
    }
    
    var body: some View {
        VStack {
            if alignment == .leading {
                HStack {
                    Text(text.uppercased())
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#888888"))
                    Spacer()
                }
            } else if alignment == .trailing {
                HStack {
                    Spacer()
                    Text(text.uppercased())
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#888888"))
                }
            } else {
                Text(text.uppercased())
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#888888"))
            }
        }
        .frame(width: width)
    }
}

struct PlayerRowView: View {
    let player: Player
    let displayType: RosterView.DisplayType
    let isEvenRow: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 0) {
            // POS
            Text(player.position.rawValue)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 50)
            
            // PLAYER
            HStack {
                Text(player.fullName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(width: 120)
            
            // OVR
            Text("\(player.overall)")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 60)
            
            if displayType == .stats {
                // Stats columns
                Text("\(player.seasonStats.gamesPlayed)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                Text("\(player.seasonStats.goals)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                Text("\(player.seasonStats.assists)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                Text("\(player.seasonStats.points)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                Text(player.seasonStats.plusMinus >= 0 ? "+\(player.seasonStats.plusMinus)" : "\(player.seasonStats.plusMinus)")
                    .font(.system(size: 14))
                    .foregroundColor(player.seasonStats.plusMinus >= 0 ? .green : .red)
                    .frame(width: 40)
                
                Text("\(player.seasonStats.penaltyMinutes)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                Text("\(player.seasonStats.shots)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                Text("\(player.seasonStats.hits)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 50)
                
                HStack {
                    Spacer()
                    Text(formatTimeOnIce(player.seasonStats.averageTimeOnIce))
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .frame(width: 50)
                
            } else {
                // Attributes columns
                if let skaterAttribs = player.skaterAttributes {
                    Text("\(skaterAttribs.speed)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(skaterAttribs.shootingAccuracy)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(skaterAttribs.passingAccuracy)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(skaterAttribs.defensivePositioning)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(skaterAttribs.strength)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(skaterAttribs.balance)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(skaterAttribs.agility)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(skaterAttribs.stamina)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    HStack {
                        Spacer()
                        Text("\(skaterAttribs.clutch)")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50)
                    
                } else if let goalieAttribs = player.goalieAttributes {
                    // Goalie attributes
                    Text("\(goalieAttribs.lateralMovement)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(goalieAttribs.gloveHand)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(goalieAttribs.passingAccuracy)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(goalieAttribs.anglePlay)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(goalieAttribs.reactionTime)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(goalieAttribs.recovery)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(goalieAttribs.flexibility)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    Text("\(goalieAttribs.focus)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 40)
                    
                    HStack {
                        Spacer()
                        Text("\(goalieAttribs.clutch)")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50)
                } else {
                    // Fallback for players without attributes
                    ForEach(0..<9, id: \.self) { _ in
                        Text("-")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(width: 40)
                    }
                }
            }
        }
        .frame(height: 44)
        .background(
            Group {
                if isHovered {
                    Color(hex: "#4A2525").opacity(0.6)
                } else {
                    isEvenRow ? Color(hex: "#1A1A1A").opacity(0.3) : Color.clear
                }
            }
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(
            color: isHovered ? Color.black.opacity(0.3) : Color.clear,
            radius: isHovered ? 5 : 0
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            print("🔘 PlayerRowView tapped for: \(player.fullName)")
            onTap()
        }
        .padding(.horizontal, 15)
    }
    
    private func formatSalary(_ amount: Int) -> String {
        if amount >= 1000000 {
            return String(format: "%.1fM", Double(amount) / 1000000.0)
        } else if amount >= 1000 {
            return String(format: "%.0fK", Double(amount) / 1000.0)
        } else {
            return "\(amount)"
        }
    }
    
    private func formatTimeOnIce(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct StatBlock: View {
    let title: String
    let primaryValue: String
    let secondaryText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#888888"))
            
            Text(primaryValue)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(secondaryText)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#888888"))
                .lineLimit(nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CondensedPlayerRowView: View {
    let player: Player
    let isEvenRow: Bool
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 0) {
            // POS
            Text(player.position.rawValue)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .frame(width: 40)
            
            // PLAYER
            HStack {
                Text(player.fullName)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color(hex: "#FF6B35") : .white)
                    .lineLimit(1)
                Spacer()
            }
            .frame(width: 100)
            
            // OVR
            Text("\(player.overall)")
                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? Color(hex: "#FF6B35") : .white)
                .frame(width: 45)
        }
        .frame(height: 32)
        .background(
            Group {
                if isSelected {
                    Color(hex: "#FF6B35").opacity(0.2)
                } else if isHovered {
                    Color(hex: "#4A2525").opacity(0.6)
                } else {
                    isEvenRow ? Color(hex: "#1A1A1A").opacity(0.3) : Color.clear
                }
            }
        )
        .overlay(
            Rectangle()
                .fill(isSelected ? Color(hex: "#FF6B35") : Color.clear)
                .frame(width: 3)
                .frame(maxWidth: .infinity, alignment: .leading)
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            print("🔘 CondensedPlayerRowView tapped for: \(player.fullName)")
            onTap()
        }
        .padding(.horizontal, 10)
    }
}


// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}