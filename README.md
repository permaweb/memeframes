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


## Need Help

[Support channel in AO Discord](https://discord.gg/J6kQXpdPG3)
[Cookbook](https://cookbook_ao.g8way.io)
