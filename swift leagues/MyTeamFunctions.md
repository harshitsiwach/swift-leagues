# Smart Contract Functions for "My Team" Tab

## Team Management Functions

### 1. submitTeam(uint256 contestId, string[] playerIds, string captain, string viceCaptain)
- **Type**: nonpayable (writes to blockchain)
- **Purpose**: Submit a team for a specific contest
- **Parameters**:
  - `contestId`: ID of the contest to submit the team to
  - `playerIds`: Array of player IDs for the team
  - `captain`: Player ID of the team captain
  - `viceCaptain`: Player ID of the vice captain
- **Usage**: Primary function for creating and submitting teams

### 2. getTeamInfo(uint256 teamId)
- **Type**: view (reads from blockchain)
- **Purpose**: Get detailed information about a specific team
- **Returns**: 
  - `address owner`: Address of the team owner
  - `uint256 contestId`: ID of the contest the team is in
  - `string[] playerIds`: Array of player IDs in the team
  - `string captain`: Player ID of the team captain
  - `string viceCaptain`: Player ID of the vice captain
  - `uint256 score`: Current score of the team
  - `bool hasClaimedPrize`: Whether the prize has been claimed
  - `uint256 submissionTime`: Timestamp when the team was submitted
- **Usage**: Display team details

### 3. getUserContestTeams(address user, uint256 contestId)
- **Type**: view (reads from blockchain)
- **Purpose**: Get all team IDs associated with a user in a specific contest
- **Returns**: `uint256[]` - Array of team IDs
- **Usage**: Show all teams a user has in a specific contest

### 4. getUserTeams(address user)
- **Type**: Not directly available, but can be implemented using:
  - `userTeams(address, uint256)` mapping
  - `userContestTeams(uint256, address, uint256)` mapping
- **Purpose**: Get all teams associated with a user across all contests
- **Usage**: Show all teams a user has created

## Player Management Functions

### 5. getPlayerInfo(string playerId)
- **Type**: view (reads from blockchain)
- **Purpose**: Get detailed information about a specific player
- **Returns**:
  - `string name`: Name of the player
  - `enum SportType sport`: Sport type of the player
  - `address priceFeed`: Address of the price feed for the player
  - `bool isActive`: Whether the player is active
- **Usage**: Display player details in team view

### 6. getPlayersBySport(enum SportType sport)
- **Type**: view (reads from blockchain)
- **Purpose**: Get all player IDs for a specific sport
- **Returns**: `string[]` - Array of player IDs
- **Usage**: Show available players when creating/editing teams

### 7. getAllPlayerIds()
- **Type**: view (reads from blockchain)
- **Purpose**: Get all player IDs in the system
- **Returns**: `string[]` - Array of all player IDs
- **Usage**: Show all available players

## Contest-Related Functions (for team context)

### 8. getContestDetails(uint256 contestId)
- **Type**: view (reads from blockchain)
- **Purpose**: Get detailed information about a specific contest
- **Returns**:
  - `string name`: Name of the contest
  - `enum SportType sport`: Sport type of the contest
  - `uint256 entryFee`: Entry fee for the contest
  - `uint256 prizePool`: Current prize pool
  - `uint256 startTime`: Start time of the contest
  - `uint256 endTime`: End time of the contest
  - `uint256 maxParticipants`: Maximum number of participants
  - `uint256 currentParticipants`: Current number of participants
  - `enum ContestState state`: Current state of the contest
- **Usage**: Display contest information related to teams

### 9. canUserJoinContest(uint256 contestId, address user)
- **Type**: view (reads from blockchain)
- **Purpose**: Check if a user can join a specific contest
- **Returns**: `bool` - Whether the user can join
- **Usage**: Validate team submission before allowing it

## Prize Claim Functions

### 10. claimPrize(uint256 contestId, uint256 teamId)
- **Type**: nonpayable (writes to blockchain)
- **Purpose**: Claim prize for a winning team
- **Parameters**:
  - `contestId`: ID of the contest
  - `teamId`: ID of the team claiming the prize
- **Usage**: Allow users to claim their winnings

### 11. claimRefund(uint256 contestId)
- **Type**: nonpayable (writes to blockchain)
- **Purpose**: Claim refund for a cancelled contest
- **Parameters**:
  - `contestId`: ID of the cancelled contest
- **Usage**: Allow users to get refunds for cancelled contests

## Utility Functions

### 12. isContestInState(uint256 contestId, enum ContestState state)
- **Type**: view (reads from blockchain)
- **Purpose**: Check if a contest is in a specific state
- **Returns**: `bool` - Whether the contest is in the specified state
- **Usage**: Validate actions based on contest state

### 13. TEAM_SIZE()
- **Type**: view (reads from blockchain)
- **Purpose**: Get the required team size
- **Returns**: `uint8` - Required number of players per team
- **Usage**: Validate team composition

## Read-Only Mappings (for direct access)

### 14. teams(uint256)
- **Type**: view mapping
- **Purpose**: Direct access to team information
- **Returns**: Same structure as getTeamInfo
- **Usage**: Efficient access to team data

### 15. players(string)
- **Type**: view mapping
- **Purpose**: Direct access to player information
- **Returns**: Same structure as getPlayerInfo
- **Usage**: Efficient access to player data

### 16. contests(uint256)
- **Type**: view mapping
- **Purpose**: Direct access to contest information
- **Returns**: Same structure as getContestDetails
- **Usage**: Efficient access to contest data

## Events (for listening to changes)

### 17. TeamSubmitted(address indexed user, uint256 indexed contestId, uint256 teamId)
- **Purpose**: Emitted when a team is submitted
- **Usage**: Update UI in real-time when teams are created

### 18. PrizeClaimed(address indexed winner, uint256 amount, uint256 contestId)
- **Purpose**: Emitted when a prize is claimed
- **Usage**: Update UI when prizes are claimed

### 19. RefundClaimed(address indexed user, uint256 amount, uint256 contestId)
- **Purpose**: Emitted when a refund is claimed
- **Usage**: Update UI when refunds are processed

## Key Functions for "My Team" Tab Implementation

1. **Primary Functions**:
   - `getUserContestTeams(address user, uint256 contestId)` - To show teams in specific contests
   - `getTeamInfo(uint256 teamId)` - To display detailed team information
   - `getPlayerInfo(string playerId)` - To show player details in teams
   - `getContestDetails(uint256 contestId)` - To provide context for teams

2. **Action Functions**:
   - `submitTeam(...)` - To create/edit teams
   - `claimPrize(...)` - To claim winnings
   - `claimRefund(...)` - To get refunds

3. **Validation Functions**:
   - `canUserJoinContest(...)` - To validate team submissions
   - `isContestInState(...)` - To validate actions based on contest state
   - `TEAM_SIZE()` - To validate team composition