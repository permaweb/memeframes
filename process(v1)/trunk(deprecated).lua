--[[
-- MEMEFRAMES (Adaptation for TRUNK Token)
-- Version: 0.1

-- NOTE: Requires token blueprint and staking blueprint to be loaded in order to run.

-- Install 

> .load-blueprint token
> .load-blueprint staking

> .load process/memeframes.lua

Get-Info - Manpage
Get-Votes - return

]]
local json = require('json')
Votes = Votes or {}
-- $CRED
BuyToken = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
MaxMint = 10000000
Minted = 0
-- INITIAL FRAME ID
FrameID = FrameID or Inbox[1].FrameID 
-- INITIAL NAME
TRUNK = TRUNK or Inbox[1]["TRUNK"]
VoteLength = 30 * 24

function Man (name) 
  return string.format([[
  
  # Trunk: %s

  Join the TRUNK community. Mint $TRUNK Tokens using $CRED, then Stake them for voting on the Webpage to show
    on the TRUNK page.

  ## TRUNK

  `TRUNK = "%s"`

  ## Mint

  ```
  Send({Target = CRED, Action = "Transfer", Quantity = "1000", Recipient = TRUNK  })
  ```

  ## Stake

  ```
  Send({Target = TRUNK, Action = "Stake", Quantity = "1000", UnstakeDelay = "1000"})
  ```

  ## Vote

  ```
  Send({Target = TRUNK, Action = "Vote", Side = "yay", TXID = "{TXID}" })
  ```

  ## Get-Votes

  ```
  Send({Target = TRUNK, Action = "Get-Votes"})
  ```

]], name, ao.id)
end

local function refund(sender, amt)
  -- return unused tokens
  Send({
    Target = BuyToken,
    Action = "Transfer",
    Recipient = sender,
    Quantity = tostring(amt)
  })
end

local function announce(msg, pids)
  Utils.map(function (pid) 
    Send({Target = pid, Data = msg })
  end, pids)
end


-- GetVotes
Handlers.prepend("Get-Votes", function (m) 
  return m.Action == "Get-Votes"
end, function (m)
  Send({
    Target = m.From,
    Data = require('json').encode(
      Utils.map(function (k) return { tx = k, yay = Votes[k].yay, nay = Votes[k].nay, deadline = Votes[k].deadline} end ,
       Utils.keys(Votes))
    ) 
  }) 
  print("Sent Votes to caller")
end
)

-- GetInfo
Handlers.prepend("Get-Info", function (m) return m.Action == "Get-Info" end, function (m)
  Send({
    Target = m.From,
    Data = Man(Name)
  })
  print('Send Info to ' .. m.From)
end)


-- MINT
Handlers.prepend(
  "Mint",
  function(m)
    return m.Action == "Credit-Notice" and m.From == BuyToken
  end,
  function(m)
    local requestedAmount = tonumber(m.Quantity)
    local actualAmount = requestedAmount
    -- if over limit refund difference
    if (Minted + requestedAmount) > MaxMint then
      actualAmount = (Minted + requestedAmount) - MaxMint
      refund(m.Sender, requestedAmount - actualAmount)
    end
    assert(type(Balances) == "table", "Balances not found!")
    local prevBalance = tonumber(Balances[m.Sender]) or 0
    Balances[m.Sender] = tostring(math.floor(prevBalance + actualAmount))
    print("Minted " .. tostring(actualAmount) .. " to " .. m.Sender)
    Send({Target = m.Sender, Data = "Successfully Minted " .. actualAmount})
  end
)

-- GET-FRAME
Handlers.prepend(
  "Get-Frame",
  Handlers.utils.hasMatchingTag("Action", "Get-Frame"),
  function(m)
    Send({
      Target = m.From,
      Action = "Frame-Response",
      Data = FrameID
    })
    print("Sent FrameID: " .. FrameID)
  end
)

local function continue(fn) 
  return function (msg) 
    local result = fn(msg)
    if result == -1 then 
      return "continue"
    end
    return result
  end
end

-- Vote for Frame or Command
Handlers.prepend("vote", 
  continue(Handlers.utils.hasMatchingTag("Action", "Vote")),
  function (m)
    assert(type(Stakers) == "table", "Stakers is not in process, please load blueprint")
    assert(type(Stakers[m.From]) == "table", "Is not staker")
    assert(m.Side and (m.Side == 'yay' or m.Side == 'nay'), 'Vote yay or nay is required!')

    local quantity = tonumber(Stakers[m.From].amount)
    local id = m.TXID
    local command = m.Command or ""
    
    assert(quantity > 0, "No Staked Tokens to vote")
    if not Votes[id] then
      local deadline = tonumber(m['Block-Height']) + VoteLength
      Votes[id] = { yay = 0, nay = 0, deadline = deadline, command == command }
    end
    if Votes[id].deadline > tonumber(m['Block-Height']) then
      Votes[id][m.Side] = Votes[id][m.Side] + quantity
      print("Voted " .. m.Side .. " for " .. id)
      Send({Target = m.From, Data = "Voted"})
    else 
      Send({Target = m.From, Data = "Expired"})
    end
  end
)

-- Finalization Handler
Handlers.after("vote").add("VoteFinalize",
function (msg) 
  return "continue"
end,
function(msg)
  local currentHeight = tonumber(msg['Block-Height'])
  
  -- Process voting
  for id, voteInfo in pairs(Votes) do
      if currentHeight >= voteInfo.deadline then
          if voteInfo.yay > voteInfo.nay then
              if not voteInfo.command then
                FrameID = id
              else
                -- TODO: Test that command execution runs with the right scope?
                local func, err = load(voteInfo.command, Name, 't', _G)
                if not err then
                  func()
                else 
                  error(err)
                end
              end
          end
          announce(string.format("Vote %s Complete", id), Utils.keys(Stakers))
          -- Clear the vote record after processing
          Votes[id] = nil
      end
  end
end
)
