# TRUNK
## User Staking and voting
*Note: TRUNK denomination adds 3 zeros. 1000 = 1 TRUNK

Set The DAO/Token Address

```lua
TRUNK = "OT9qTE2467gcozb2g8R6D6N3nQS94ENcaAIJfUzHCww"
```

Stake

```lua
Send({Target = TRUNK, Action = "[Stake quantity]", Quantity = "[Stake quantity]"})
```
See Staked Balance

```lua
Send({Target = TRUNK, Action = "Stakers"})
-- wait for response

TRUNKStakers = require('json').decode(Inbox[#Inbox].Data)

TRUNKStakers["your_staked_address"]
```
Unstake

```lua
Send({Target = "OT9qTE2467gcozb2g8R6D6N3nQS94ENcaAIJfUzHCww", Action = "Unstake", Quantity = "[Unstake quantity]" })
```
Vote "yay"(yes) on a vote to change the FRAME/Propose a vote to change it

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "yay", TXID="Arweave_tx_ID_here"})
```
Vote "nay"(yes) on a vote to change the FRAME

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "nay", TXID="Arweave_tx_ID_here"})
```
Vote yay(yes) on a command like updating the MaxMint setting

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "yay",  VoteID = "current_vote_nonce" })
```
Vote nay(no) on a command like updating the MaxMint setting

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "nay", VoteID = "current_vote_nonce" })
```

