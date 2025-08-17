
# Basic implementation
claude-code "Modify the tradeView component to display all current roster players with trade value bars. Each player should show a horizontal progress bar where the bar length/fill represents their trade value based on their overall rating."

# Detailed implementation with specifications
claude-code "Update tradeView to:
1. Display all roster players in a list/grid format
2. Add trade value visualization as horizontal bars next to each player
3. Calculate bar fill percentage using (player.overall / 100) * barWidth
4. Include player name, position, overall rating, and trade value bar
5. Style bars with gradient colors (red for low value, yellow for medium, green for high)"

# Complete UI overhaul
claude-code "Redesign tradeView component to show:
- Player card layout with photo, name, position, overall rating
- Trade value bar underneath each player (width based on overall/100)
- Bar colors: red (0-69), yellow (70-84), green (85+)
- Sortable by trade value
- Add visual indicators for most/least valuable players
- Responsive grid layout for different screen sizes"

# With interactive features
claude-code "Transform tradeView into an interactive trade value dashboard:
- Show all roster players with animated trade value bars
- Bars scale from 0-100% based on player overall rating
- Add hover effects showing exact trade value numbers
- Include sort/filter options (by position, trade value, name)
- Add 'Select for Trade' checkboxes next to high-value players
- Implement search functionality to find specific players"

# Integration with existing trade system
claude-code "Modify existing tradeView to integrate trade value bars:
- Keep current trade functionality intact
- Add trade value visualization to existing player display
- Ensure bars update dynamically when player ratings change
- Make trade value bars clickable to select players for trades
- Add legend explaining trade value color coding
- Maintain compatibility with current roster data structure"
