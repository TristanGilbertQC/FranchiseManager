
1. **Overall Layout Structure**:
  - Create an HStack as the main container
  - Left side: Player table (70% width)
  - Right side: Statistics card (30% width)
  - Add spacing of 20 between the two sections

2. **Player Row Hover Effect**:
  - Track hover state for each row using @State
  - On hover: Apply background color (#4A2525, 0.6 opacity)
  - On hover: Scale the row slightly (1.02)
  - On hover: Add subtle shadow (radius: 5, color: black, 0.3 opacity)
  - Animate transitions with duration 0.2 seconds
  - Cursor should change to pointer on hover

3. **Right Side Statistics Card**:
  - Create a rounded rectangle card (cornerRadius: 12)
  - Background: Dark semi-transparent (#1A0F0F, 0.9 opacity)
  - Add border: 1 point, color (#333333)
  - Internal padding: 20 all sides

4. **Card Section Layout**:
  - Divide card into 3 equal sections vertically
  - Add divider lines between sections (color: #333333, height: 1)
  - Each section height: flexible based on content

5. **Section 1 (Empty Placeholder)**:
  - Leave empty for future content
  - Maintain minimum height of 100 points
  - Add comment: "// Future feature placeholder"

6. **Section 2 (Top Scorer)**:
  - Header: "TOP SCORER" in cyan/teal (#00CED1, size: 12, uppercase)
  - Player name in white (size: 18, bold)
  - Stats below name: "G - A - PTS" format (size: 14, gray)
  - Add small player position badge (size: 10)

7. **Section 3 (Top Goalie)**:
  - Header: "TOP GOALIE" in cyan/teal (#00CED1, size: 12, uppercase)
  - Goalie name in white (size: 18, bold)
  - Stats below name: "W-L | GAA | SV%" format (size: 14, gray)
  - Add small "G" position indicator

8. **Responsive Behavior**:
  - Ensure card maintains its width ratio
  - Stack vertically on smaller screens if needed
  - Keep hover effects smooth on all screen sizes

9. **Data Binding**:
  - Use computed properties to find top scorer and goalie
  - Update automatically when stats change
  - Handle cases where no players have stats yet

10. **Visual Polish**:
   - Add subtle gradient overlay to card background
   - Ensure text contrast meets accessibility standards
   - Match the existing dark theme aesthetic

Test completion criteria: The view should compile without errors, display smooth hover effects on player rows, and show a properly formatted statistics card on the right side.
