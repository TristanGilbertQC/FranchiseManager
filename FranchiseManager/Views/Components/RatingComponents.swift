import SwiftUI

// MARK: - Star Rating Component
struct StarRating: View {
    let rating: Int
    let maxRating: Int = 5
    let starSize: CGFloat
    
    init(rating: Int, starSize: CGFloat = 16) {
        self.rating = min(max(rating, 0), 100) // Clamp between 0-100
        self.starSize = starSize
    }
    
    private var starCount: Double {
        // Convert 0-100 rating to 0-5 stars
        return Double(rating) / 20.0
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: starImageName(for: index))
                    .font(.system(size: starSize))
                    .foregroundColor(starColor(for: index))
            }
        }
    }
    
    private func starImageName(for index: Int) -> String {
        let starValue = starCount - Double(index)
        if starValue >= 1.0 {
            return "star.fill"
        } else if starValue >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
    
    private func starColor(for index: Int) -> Color {
        let starValue = starCount - Double(index)
        if starValue >= 0.5 {
            return Color(hex: "#FF8C00") // Orange
        } else {
            return Color.gray.opacity(0.4)
        }
    }
}

// MARK: - Skill Rating Row Component
struct SkillRatingRow: View {
    let skillName: String
    let rating: Int
    let showNumerical: Bool
    
    init(skillName: String, rating: Int, showNumerical: Bool = true) {
        self.skillName = skillName
        self.rating = rating
        self.showNumerical = showNumerical
    }
    
    var body: some View {
        HStack {
            Text(skillName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            StarRating(rating: rating, starSize: 14)
            
            if showNumerical {
                Text("\(rating)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ratingColor(rating))
                    .frame(width: 30)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func ratingColor(_ rating: Int) -> Color {
        switch rating {
        case 90...100: return Color(hex: "#00FF00") // Bright green
        case 80...89: return Color(hex: "#ADFF2F") // Green yellow
        case 70...79: return Color(hex: "#FFD700") // Gold
        case 60...69: return Color(hex: "#FFA500") // Orange
        case 50...59: return Color(hex: "#FF6347") // Tomato
        default: return Color(hex: "#FF4500") // Red orange
        }
    }
}

// MARK: - Skill Section Component
struct SkillSection: View {
    let title: String
    let skills: [(String, Int)]
    let backgroundColor: Color
    
    init(title: String, skills: [(String, Int)], backgroundColor: Color = Color.black.opacity(0.3)) {
        self.title = title
        self.skills = skills
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#FF8C00"))
                .padding(.bottom, 4)
            
            VStack(spacing: 8) {
                ForEach(skills.indices, id: \.self) { index in
                    let skill = skills[index]
                    SkillRatingRow(skillName: skill.0, rating: skill.1)
                }
            }
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Player Stat Card Component
struct PlayerStatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let accentColor: Color
    
    init(title: String, value: String, subtitle: String? = nil, accentColor: Color = Color(hex: "#FF8C00")) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.accentColor = accentColor
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(accentColor)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.4))
        .cornerRadius(8)
    }
}

// MARK: - Progress Bar Component
struct ProgressBar: View {
    let value: Double
    let maxValue: Double
    let height: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(value: Double, maxValue: Double = 100, height: CGFloat = 8, 
         backgroundColor: Color = Color.gray.opacity(0.3), 
         foregroundColor: Color = Color(hex: "#FF8C00")) {
        self.value = value
        self.maxValue = maxValue
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(backgroundColor)
                    .frame(height: height)
                    .cornerRadius(height / 2)
                
                Rectangle()
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * CGFloat(value / maxValue), height: height)
                    .cornerRadius(height / 2)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Coach Satisfaction Component
struct CoachSatisfaction: View {
    let satisfaction: Double // 0.0 to 1.0
    
    var satisfactionText: String {
        switch satisfaction {
        case 0.8...1.0: return "EXCELLENT"
        case 0.6..<0.8: return "GOOD"
        case 0.4..<0.6: return "AVERAGE"
        case 0.2..<0.4: return "POOR"
        default: return "VERY POOR"
        }
    }
    
    var satisfactionColor: Color {
        switch satisfaction {
        case 0.8...1.0: return Color(hex: "#00FF00")
        case 0.6..<0.8: return Color(hex: "#ADFF2F")
        case 0.4..<0.6: return Color(hex: "#FFD700")
        case 0.2..<0.4: return Color(hex: "#FFA500")
        default: return Color(hex: "#FF4500")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COACH SATISFACTION")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            HStack {
                ProgressBar(
                    value: satisfaction * 100,
                    height: 12,
                    foregroundColor: satisfactionColor
                )
                
                Text(satisfactionText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(satisfactionColor)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

