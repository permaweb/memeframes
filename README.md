# TRUNK
## User Staking and voting

Set The DAO/Token Address

```lua
TRUNK = "OT9qTE2467gcozb2g8R6D6N3nQS94ENcaAIJfUzHCww"
```

First the users need CRED and should transfer the CRED to your MemeFrams

```lua
Send({Target = CRED, Action = "Transfer", Quantity = "1000", Recipient = TRUNK})
```

Stake

```lua
Send({Target = TRUNK, Action = "[Stake quantity]", Quantity = "1000", UnstakeDelay = "1000" })
```

Vote to change the FRAME/Prpose a vote to change it

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "yay", TXID="Arweave_tx_ID_here",  VoteID = "current_vote_nonce" })
```
Vote yay(yes)

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "yay",  VoteID = "current_vote_nonce" })
```
Vote nay(no)

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "nay", VoteID = "current_vote_nonce" })
```


## Need Help

[Support channel in AO Discord](https://discord.gg/J6kQXpdPG3)
[Cookbook](https://cookbook_ao.g8way.io)
