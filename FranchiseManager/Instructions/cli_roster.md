Please update the rosterView to match the following design specifications:

1. **Background and Container**:
  - Apply a dark gradient background from top (#3D1A1A) to bottom (#000000)
  - Add rounded corners to the main container (cornerRadius: 10)
  - Set the view to fill the entire available space

2. **Header Section**:
  - Create a top header bar with horizontal padding of 20
  - Left side: Display "FRANCHISE MODE ROSTER MOVES" in white, uppercase, bold font (size: 16)
  - Right side: Display team name and date in white text (size: 14)
  - Add vertical padding of 15 to the header

3. **Filter Controls**:
  - Create two segmented control buttons below the header
  - Style with dark background (#2A1515) for unselected, lighter (#4A2525) for selected
  - Add "NHL" and "RT DEFENSEMEN" as options
  - Use white text (size: 14) with bold weight for selected state
  - Apply cornerRadius of 6 to buttons
  - Add horizontal spacing of 10 between buttons

4. **Table Header Row**:
  - Create column headers with uppercase text in gray color (#888888)
  - Columns: POS, PLAYER, OVR, INJ, CLAUSE, SAL, REM, CONT, WAIV, ROLE
  - Use font size 12 for headers
  - Add bottom padding of 8 and top padding of 20
  - Add sort indicator (down arrow) next to OVR column

5. **Table Data Rows**:
  - Alternate row backgrounds: odd rows transparent, even rows with dark overlay (#1A1A1A, 0.3 opacity)
  - Set row height to 44 points
  - Use white text color for all data cells (size: 14)
  - Left-align text columns (POS, PLAYER)
  - Center-align OVR values
  - Display "NTC" in red background pill shape where applicable
  - Show "-" for empty INJ column
  - Right-align salary columns (SAL, REM)
  - Center-align CONT, WAIV columns
  - Add horizontal padding of 15 for first and last columns, 10 for others

6. **Bottom Statistics Section**:
  - Create three information blocks with dark background (#1A0F0F)
  - Left block: "TEAM SALARY" with cap hit and space info in gray text (size: 12)
  - Center block: "NHL SALARY CAP" with min/max salary info
  - Right block: "NHL ROSTER" with skater/goalie counts
  - Use white for primary values, gray (#888888) for labels
  - Add vertical padding of 15 and horizontal padding of 20

7. **Progress Bar**:
  - Add a red progress bar below statistics section
  - Height: 4 points
  - Show cap usage percentage visually

8. **Bottom Control Bar**:
  - Create a black bar at the very bottom with function buttons
  - Include "MUTE SALARY CAP", "GO TO EDIT LINES", "SORT", "PLAYER INFO" buttons
  - Add media controls on the left side
  - Use icon + text for buttons where applicable
  - Set height to 50 points

9. **Typography Summary**:
  - Primary text: System font, white color
  - Secondary labels: System font, gray (#888888)
  - Use medium/semibold weight for player names
  - Salary values in standard white

10. **Special Elements**:
   - NTC badges: Red background (#CC3333), white text, cornerRadius of 10
   - Position combinations (LD/RD) shown with "/" separator
   - "Unc" truncated text in ROLE column

Test completion criteria: The view should compile without errors and display a dark-themed roster management interface matching the provided screenshot layout.


Code:
ds
fdsfdsfds
f
dsf
ds
fds
f
