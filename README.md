# MemeFrames

MemeFrames are permaweb pages with a DAO _inside_. Once you launch a MemeFrame, anyone can deposit testnet $CRED to mint the DAOs native token until the cap is reached (1,000 $CRED by default). After minting, token holders can vote to change the contents of their permaweb page. Add an ARNS name to it and you have a community controlled site/app.

The MemeFrame's DAO also retains the treasury of $CRED tokens used in minting. Token holders can vote to use (and grow) these however they like.

## Requirements
- Node version 20.
- A sense of humor.
- $CRED to burn. They will probably all go to zero.

## Deploying

To deploy your MemeFrame clone this repo and run the following:

```sh
aos --data src/index.html --tag-name MemeFrame --tag-value MemeFrame --tag-name FrameID --tag-value XFvaK9uJOBzU55sx3MG5aBeDNs8x1PIeOkN8PQY4atc  --tag-name Content-Type --tag-value text/html
```

Then in aos:

```
.load-blueprint token
.load-blueprint staking
.load process/memeframes.lua
```

Change 'MEMEFRAME_NAME' to your preferred name unless you want your community to rally under a particularly stupid name.
