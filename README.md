# TRUNK
## User Staking and voting
*Note: TRUNK denomination adds 3 zeros. 1000 = 1 TRUNK

### Set The DAO/Token Address

```lua
TRUNK = "OT9qTE2467gcozb2g8R6D6N3nQS94ENcaAIJfUzHCww"
```

### Stake

```lua
Send({Target = TRUNK, Action = "[Stake quantity]", Quantity = "[Stake quantity]"})
```
### See Staked Balance

```lua
Send({Target = TRUNK, Action = "Stakers"})
-- wait for response

TRUNKStakers = require('json').decode(Inbox[#Inbox].Data)

TRUNKStakers["your_staked_address"]
```
### Unstake

```lua
Send({Target = TRUNK, Action = "Unstake", Quantity = "Unstake_quantity" })
```
### Propose a vote to change the FRAME

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "nay", Command = [[FrameID= "Arweave_tx_ID_here"]]})
```

### Vote yay(yes)

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "yay",  VoteID = "current_vote_number" })
```
### Vote nay(no)

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "nay", VoteID = "current_vote_number" })
```

