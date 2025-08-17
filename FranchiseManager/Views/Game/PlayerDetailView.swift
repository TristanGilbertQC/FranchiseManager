import SwiftUI

struct PlayerDetailView: View {
    let player: Player
    let team: Team
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#3D1A1A"),
                    Color(hex: "#000000")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Main Content Grid
                    mainContentGrid
                    
                    // Bottom Section
                    bottomSection
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Team branding background
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FF8C00").opacity(0.8),
                        Color(hex: "#FF4500").opacity(0.6)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 200)
                
                HStack(alignment: .top) {
                    // Player headshot placeholder
                    VStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.7))
                            )
                        
                        Spacer()
                    }
                    .padding(.leading, 30)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Player info
                    VStack(alignment: .trailing, spacing: 8) {
                        // Date stamp
                        Text(DateFormatter.gameDate.string(from: Date()))
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 20)
                            .padding(.trailing, 30)
                        
                        Spacer()
                        
                        // Player name
                        Text(player.fullName.uppercased())
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                        
                        // Stats bar
                        HStack(spacing: 16) {
                            PlayerStatCard(title: "#", value: "\(player.jerseyNumber)", accentColor: .white)
                            PlayerStatCard(title: "POS", value: player.position.rawValue, accentColor: .white)
                            PlayerStatCard(title: "AGE", value: "\(player.age)", accentColor: .white)
                            PlayerStatCard(title: "HT", value: formatHeight(player.height), accentColor: .white)
                            PlayerStatCard(title: "WT", value: "\(player.weight)", accentColor: .white)
                            PlayerStatCard(title: "SHOOTS", value: player.handedness.rawValue, accentColor: .white)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.trailing, 30)
                }
            }
            
            // Team logo integration (placeholder)
            HStack {
                Text(team.fullName.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#FF8C00"))
                    .padding(.leading, 30)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.5))
        }
    }
    
    // MARK: - Main Content Grid
    private var mainContentGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            // Left Column - Puck Skills
            VStack(spacing: 16) {
                puckSkillsSection
            }
            
            // Center Column - Multiple Sections
            VStack(spacing: 16) {
                draftInfoSection
                sensesSection
                skatingSection
            }
            
            // Right Column - Performance Stats
            VStack(spacing: 16) {
                shootingSection
                physicalSection
                defenseSection
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
    
    // MARK: - Left Column Components
    private var puckSkillsSection: some View {
        SkillSection(
            title: "Puck Skills",
            skills: [
                ("Deking", player.skaterAttributes?.passingCreativity ?? 50),
                ("Hand-Eye", player.skaterAttributes?.quickRelease ?? 50),
                ("Passing", player.skaterAttributes?.passingAccuracy ?? 50),
                ("Puck Control", player.skaterAttributes?.passingVision ?? 50)
            ],
            backgroundColor: Color.black.opacity(0.4)
        )
    }
    
    // MARK: - Center Column Components
    private var draftInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DRAFTED")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#FF8C00"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("2023 - ROUND 1")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white)
                
                Text("DRAFTED BY")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(team.fullName.uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#FF8C00"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.black.opacity(0.4))
        .cornerRadius(12)
    }
    
    private var sensesSection: some View {
        SkillSection(
            title: "Senses",
            skills: [
                ("Discipline", player.skaterAttributes?.discipline ?? 50),
                ("Off. Awareness", player.skaterAttributes?.gameAwareness ?? 50),
                ("Poise", player.skaterAttributes?.composure ?? 50)
            ],
            backgroundColor: Color.black.opacity(0.4)
        )
    }
    
    private var skatingSection: some View {
        SkillSection(
            title: "Skating",
            skills: [
                ("Acceleration", player.skaterAttributes?.acceleration ?? 50),
                ("Agility", player.skaterAttributes?.agility ?? 50),
                ("Balance", player.skaterAttributes?.balance ?? 50),
                ("Endurance", player.skaterAttributes?.stamina ?? 50),
                ("Speed", player.skaterAttributes?.speed ?? 50)
            ],
            backgroundColor: Color.black.opacity(0.4)
        )
    }
    
    // MARK: - Right Column Components
    private var shootingSection: some View {
        SkillSection(
            title: "Shooting",
            skills: [
                ("Slap Shot Accuracy", player.skaterAttributes?.shootingAccuracy ?? 50),
                ("Slap Shot Power", player.skaterAttributes?.shootingPower ?? 50),
                ("Wrist Shot Accuracy", player.skaterAttributes?.shootingAccuracy ?? 50),
                ("Wrist Shot Power", player.skaterAttributes?.quickRelease ?? 50)
            ],
            backgroundColor: Color.black.opacity(0.4)
        )
    }
    
    private var physicalSection: some View {
        SkillSection(
            title: "Physical",
            skills: [
                ("Aggressiveness", player.skaterAttributes?.intimidation ?? 50),
                ("Body Checking", player.skaterAttributes?.bodyChecking ?? 50),
                ("Durability", player.skaterAttributes?.injuryRecovery ?? 50),
                ("Fighting Skill", player.skaterAttributes?.intimidation ?? 50),
                ("Strength", player.skaterAttributes?.strength ?? 50)
            ],
            backgroundColor: Color.black.opacity(0.4)
        )
    }
    
    private var defenseSection: some View {
        SkillSection(
            title: "Defense",
            skills: [
                ("Def. Awareness", player.skaterAttributes?.defensivePositioning ?? 50),
                ("Faceoffs", player.skaterAttributes?.anticipation ?? 50),
                ("Shot Blocking", player.skaterAttributes?.shotBlocking ?? 50),
                ("Stick Checking", player.skaterAttributes?.stickChecking ?? 50)
            ],
            backgroundColor: Color.black.opacity(0.4)
        )
    }
    
    // MARK: - Bottom Section
    private var bottomSection: some View {
        VStack(spacing: 20) {
            // Coach Satisfaction
            CoachSatisfaction(satisfaction: Double(player.skaterAttributes?.coachability ?? 50) / 100.0)
            
            // Navigation
            HStack {
                Button("← BACK TO ROSTER") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#FF8C00"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
                
                Spacer()
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }
    
    // MARK: - Helper Functions
    private func formatHeight(_ heightInches: Int) -> String {
        let feet = heightInches / 12
        let inches = heightInches % 12
        return "\(feet)'\(inches)\""
    }
}

// MARK: - Preview
#Preview {
    // Create a sample player for preview
    let samplePlayer = Player(
        firstName: "Cam",
        lastName: "York",
        jerseyNumber: 24,
        position: .leftDefense,
        age: 23,
        height: 72,
        weight: 185,
        handedness: .left,
        birthplace: "Anaheim, CA",
        teamId: UUID()
    )
    
    let sampleTeam = Team(
        name: "Flyers",
        city: "Philadelphia",
        abbreviation: "PHI",
        primaryColor: "orange",
        secondaryColor: "black"
    )
    
    PlayerDetailView(player: samplePlayer, team: sampleTeam)
}