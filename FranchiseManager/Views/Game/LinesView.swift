import SwiftUI

struct LinesView: View {
    @Binding var savedGame: SavedGame
    @State private var selectedPlayerForLine: Player?
    @State private var selectedLineIndex: Int?
    @State private var selectedPosition: Position?
    
    var playerTeam: Team? {
        return savedGame.league.teams.first { $0.id == savedGame.playerTeamId }
    }
    
    var body: some View {
        VStack {
            if let team = playerTeam {
                List {
                    // Forward Lines
                    Section {
                        ForEach(0..<team.lines.forwardLines.count, id: \.self) { index in
                            ForwardLineView(
                                line: team.lines.forwardLines[index],
                                team: team,
                                onPlayerTap: { position in
                                    selectedLineIndex = index
                                    selectedPosition = position
                                }
                            )
                        }
                    } header: {
                        Text("Forward Lines")
                    }
                    
                    // Defense Pairs
                    Section {
                        ForEach(0..<team.lines.defensePairs.count, id: \.self) { index in
                            DefensePairView(
                                line: team.lines.defensePairs[index],
                                team: team,
                                onPlayerTap: { position in
                                    selectedLineIndex = index + 10 // Offset for defense
                                    selectedPosition = position
                                }
                            )
                        }
                    } header: {
                        Text("Defense Pairs")
                    }
                    
                    // Goalies
                    Section {
                        GoalieLineView(lines: team.lines, team: team)
                    } header: {
                        Text("Goalies")
                    }
                }
            } else {
                Text("No team selected")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: .constant(selectedLineIndex != nil && selectedPosition != nil)) {
            if let team = playerTeam, let lineIndex = selectedLineIndex, let position = selectedPosition {
                PlayerSelectionView(
                    team: team,
                    position: position,
                    onPlayerSelected: { player in
                        assignPlayerToLine(player: player, lineIndex: lineIndex, position: position)
                        selectedLineIndex = nil
                        selectedPosition = nil
                    },
                    onCancel: {
                        selectedLineIndex = nil
                        selectedPosition = nil
                    }
                )
            }
        }
    }
    
    private func assignPlayerToLine(player: Player, lineIndex: Int, position: Position) {
        guard var team = playerTeam else { return }
        
        if lineIndex < 10 {
            // Forward line
            switch position {
            case .leftWing:
                team.lines.forwardLines[lineIndex].leftWingId = player.id
            case .center:
                team.lines.forwardLines[lineIndex].centerId = player.id
            case .rightWing:
                team.lines.forwardLines[lineIndex].rightWingId = player.id
            default:
                break
            }
        } else {
            // Defense pair
            let defenseIndex = lineIndex - 10
            switch position {
            case .leftDefense:
                team.lines.defensePairs[defenseIndex].leftDefenseId = player.id
            case .rightDefense:
                team.lines.defensePairs[defenseIndex].rightDefenseId = player.id
            default:
                break
            }
        }
        
        // Update the saved game
        if let teamIndex = savedGame.league.teams.firstIndex(where: { $0.id == team.id }) {
            savedGame.league.teams[teamIndex] = team
        }
    }
}

struct ForwardLineView: View {
    let line: Line
    let team: Team
    let onPlayerTap: (Position) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(line.name)
                .font(.headline)
            
            HStack {
                PlayerSlotView(
                    playerId: line.leftWingId,
                    position: .leftWing,
                    team: team,
                    onTap: { onPlayerTap(.leftWing) }
                )
                
                PlayerSlotView(
                    playerId: line.centerId,
                    position: .center,
                    team: team,
                    onTap: { onPlayerTap(.center) }
                )
                
                PlayerSlotView(
                    playerId: line.rightWingId,
                    position: .rightWing,
                    team: team,
                    onTap: { onPlayerTap(.rightWing) }
                )
            }
        }
        .padding(.vertical, 4)
    }
}

struct DefensePairView: View {
    let line: Line
    let team: Team
    let onPlayerTap: (Position) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(line.name)
                .font(.headline)
            
            HStack {
                PlayerSlotView(
                    playerId: line.leftDefenseId,
                    position: .leftDefense,
                    team: team,
                    onTap: { onPlayerTap(.leftDefense) }
                )
                
                PlayerSlotView(
                    playerId: line.rightDefenseId,
                    position: .rightDefense,
                    team: team,
                    onTap: { onPlayerTap(.rightDefense) }
                )
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct GoalieLineView: View {
    let lines: TeamLines
    let team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Starting")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let goalieId = lines.startingGoalieId,
                       let goalie = team.roster.first(where: { $0.id == goalieId }) {
                        Text(goalie.fullName)
                            .font(.headline)
                    } else {
                        Text("No goalie assigned")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Backup")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let goalieId = lines.backupGoalieId,
                       let goalie = team.roster.first(where: { $0.id == goalieId }) {
                        Text(goalie.fullName)
                            .font(.headline)
                    } else {
                        Text("No goalie assigned")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct PlayerSlotView: View {
    let playerId: UUID?
    let position: Position
    let team: Team
    let onTap: () -> Void
    
    var player: Player? {
        guard let playerId = playerId else { return nil }
        return team.roster.first { $0.id == playerId }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(position.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let player = player {
                    Text(player.lastName)
                        .font(.headline)
                        .foregroundColor(.primary)
                } else {
                    Text("Empty")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(minWidth: 80, minHeight: 60)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlayerSelectionView: View {
    let team: Team
    let position: Position
    let onPlayerSelected: (Player) -> Void
    let onCancel: () -> Void
    
    var availablePlayers: [Player] {
        return team.roster.filter { $0.position == position }
    }
    
    var body: some View {
        NavigationStack {
            List(availablePlayers, id: \.id) { player in
                Button(action: {
                    onPlayerSelected(player)
                }) {
                    HStack {
                        Text(player.fullName)
                            .font(.headline)
                        Spacer()
                        Text(player.position.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select \(position.displayName)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}