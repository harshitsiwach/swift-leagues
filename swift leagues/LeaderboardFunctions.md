# Smart Contract Functions for Leaderboard Tab

## Functions Related to Leaderboard/Ranking

1. **getContestRankings(uint256 contestId)**
   - Returns: `uint256[] teamIds`, `uint256[] scores`
   - Purpose: Gets the rankings of teams in a specific contest based on scores

2. **getContestTeams(uint256 contestId)**
   - Returns: `uint256[]`
   - Purpose: Gets all team IDs for a specific contest

3. **getTeamInfo(uint256 teamId)**
   - Returns: `Team` struct containing:
     - `address owner`
     - `uint256 contestId`
     - `string[] playerIds`
     - `string captain`
     - `string viceCaptain`
     - `uint256 score`
     - `bool hasClaimedPrize`
     - `uint256 submissionTime`
   - Purpose: Gets detailed information about a specific team

4. **teamRankings(uint256, uint256)**
   - Returns: `uint256`
   - Purpose: Mapping to store team rankings

5. **teams(uint256)**
   - Returns: `Team` struct (same as getTeamInfo)
   - Purpose: Public mapping to access team information directly

6. **getUserContestTeams(address user, uint256 contestId)**
   - Returns: `uint256[]`
   - Purpose: Gets all team IDs associated with a user in a specific contest

7. **userTeams(address, uint256)**
   - Returns: `uint256`
   - Purpose: Mapping to store user team associations

8. **userContestTeams(uint256, address, uint256)**
   - Returns: `uint256`
   - Purpose: Mapping to store user contest team associations

## Additional Useful Functions for Context

9. **getContestDetails(uint256 contestId)**
   - Returns: Contest details including name, sport, entry fee, prize pool, timing, participants, and state
   - Purpose: Gets comprehensive information about a contest

10. **getActiveContestIds()**
    - Returns: `uint256[]`
    - Purpose: Gets IDs of all currently active contests

11. **getFinishedContestIds()**
    - Returns: `uint256[]`
    - Purpose: Gets IDs of all finished contests (most relevant for leaderboards)

12. **isContestInState(uint256 contestId, ContestState state)**
    - Returns: `bool`
    - Purpose: Checks if a contest is in a specific state (useful for filtering finished contests)

## Supporting Functions

13. **getPlayerInfo(string playerId)**
    - Returns: `Player` struct with name, sport, priceFeed, and isActive status
    - Purpose: Gets information about a specific player

14. **contestTeams(uint256, uint256)**
    - Returns: `uint256`
    - Purpose: Mapping to associate contests with teams

## Key Functions for Leaderboard Implementation

For implementing a leaderboard tab in the app, the most important functions would be:

1. `getFinishedContestIds()` - To find contests that have results
2. `getContestDetails(contestId)` - To display contest information
3. `getContestRankings(contestId)` - To get the ranked teams and scores
4. `getTeamInfo(teamId)` - To display team details (owner, players, etc.)
5. `getPlayerInfo(playerId)` - To display player details in teams