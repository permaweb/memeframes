# MemeFrames

MemeFrames are permaweb pages with a DAO _inside_. Once you launch a MemeFrame, anyone can deposit testnet $CRED to mint the DAOs native token until the cap is reached (1,000 $CRED by default). After minting, token holders can vote to change the contents of their permaweb page. Add an ARNS name to it and you have a community controlled site/app.

The MemeFrame's DAO also retains the treasury of $CRED tokens used in minting. Token holders can vote to use (and grow) these however they like.

## Requirements
- Node version 20.
- aos - `npm i -g https://get_ao.g8way.io`
- A sense of humor.
- $CRED to burn. They will probably all go to zero.


## Deploying

To deploy your MemeFrame clone this repo and run the following:

```sh
aos trunk --data src/index.html \
--tag-name MemeFrame-Name --tag-value TRUNK \
--tag-name MemeFrame --tag-value TRUNK \
--tag-name FrameID --tag-value {default html tx id}  \
--tag-name Content-Type --tag-value text/html
```

Then in aos:

```
.load-blueprint token
.load-blueprint staking
.load process/trunk.lua
```


## User Staking and voting

Set MemeFrame Address

```lua
TRUNK = "{Your MemeFrame Address}"
```

First the users need CRED and should transfer the CRED to your MemeFrams

```lua
Send({Target = CRED, Action = "Transfer", Quanity = "1000", Recipient = TRUNK})
```

Stake

```lua
Send({Target = TRUNK, Action = "Stake", Quantity = "1000", UnstakeDelay = "1000" })
```

Vote to change the FRAME

```lua
Send({ Target = TRUNK, Action = "Vote", Side = "yay", TXID="..." })
```

## Need Help

[Support channel in AO Discord](https://discord.gg/J6kQXpdPG3)
[Cookbook](https://cookbook_ao.g8way.io)
