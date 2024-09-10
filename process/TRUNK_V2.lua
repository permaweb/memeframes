

local json = require('json')
local initialMinted = tonumber(TotalSupply) or 0

Votes = Votes or {}
BuyToken = "xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10" -- $wAR
MaxMint = MaxMint or 42622000000000000 -- Set to 42,622.000000000000 to match the original supply
Multiplier = Multiplier or 1 -- Mint 1 tokens in return for one BuyToken
Minted = Minted or initialMinted
FrameID = FrameID or "nOXJjj_vk0Dc1yCgdWD8kti_1iHruGzLQLNNBHVpN0Y" -- iFRAME ID with ArDrive site for PlaceHolder
Name = "TRUNK"
VoteLength = VoteLength or 670 -- ~24hours
Threshhold = Threshhold or 0.025 -- 2.5% of supply must vote on "yay" to pass a vote
Ticker = "TRUNK"
Logo = 'hqg-Em9DdYHYmMysyVi8LuTGF8IF_F7ZacgjYiSpj0k'

function Man (name) 
  return string.format([[
  v2

  # iFrames: %s

  Join the TRUNK DAO community. Mint DAO Tokens using $wAR, then Stake them for voting on what Webpage to show
    on the iFrame page.

  ## iFrame

  `iFrame = "%s"`

  ## Mint

  ```
  Send({Target = "xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10", Action = "Transfer", Quantity = "1000000000000", Recipient = iFrame  })
  ```

  ## Stake

  ```
  Send({Target = iFrame, Action = "Stake", Quantity = "1000000000000", UnstakeDelay = "670"})
  ```

  ## Vote

  ```
  Send({Target = iFrame, Action = "Vote", Side = "yay", VoteID = "<Vote#>", Command = "Insert command here and use escape quotes", Prop = "Insert your Porposal text here"})
  ```

  ## Get-Votes

  ```
  Send({Target = iFrame, Action = "Get-Votes"})
  ```

]], name, ao.id)
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
  function(m) -- Mints tokens at 1:1000 for the payment token
    local requestedAmount = tonumber(m.Quantity)
    local actualAmount = requestedAmount * Multiplier

    -- Calculate the remaining mintable amount
    local remainingMintable = MaxMint - Minted

    if remainingMintable <= 0 then
      -- If no tokens can be minted, refund the entire amount
      Send({
        Target = BuyToken,
        Action = "Transfer",
        Recipient = m.Sender,
        Quantity = tostring(requestedAmount),
        Data = "Mint is Maxed - Refund"
      })
      print('send refund')
      Send({Target = m.Sender, Data = "Mint Maxed, Refund dispatched"})
      return
    end

    -- Calculate the actual amount to mint and the amount to refund
    local mintAmount = math.min(actualAmount, remainingMintable)
    local refundAmount = (actualAmount - mintAmount) / Multiplier

    -- Ensure refundAmount is treated as an integer
    refundAmount = tonumber(string.format("%.0f", refundAmount))

    -- Mint the allowable amount
    if mintAmount > 0 then
      assert(type(Balances) == "table", "Balances not found!")
      local prevBalance = tonumber(Balances[m.Sender]) or 0
      Balances[m.Sender] = tostring(math.floor(prevBalance + mintAmount))
      Minted = Minted + mintAmount
      print("Minted " .. tostring(mintAmount) .. " to " .. m.Sender)
      Send({Target = m.Sender, Data = "Successfully Minted " .. mintAmount})
    end

    if refundAmount > 0 then
      -- Send the refund for the excess amount
      Send({
        Target = BuyToken,
        Action = "Transfer",
        Recipient = m.Sender,
        Quantity = tostring(refundAmount),
        Data = "Mint is Maxed - Partial Refund"
      })
      print('sending partial refund of ' .. tostring(refundAmount))
      Send({Target = m.Sender, Data = "Mint Maxed, Partial Refund dispatched"})
    end
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
    local id = m.VoteID
    local command = m.Command or ""
    local prop = m.Prop or "" -- Proposal text

    assert(quantity > 0, "No Staked Tokens to vote")
    if not Votes[id] then
      local deadline = tonumber(m['Block-Height']) + VoteLength
      Votes[id] = { yay = 0, nay = 0, deadline = deadline, command = command, prop = prop, voted = { } }
    end
    if Votes[id].deadline > tonumber(m['Block-Height']) then
      if Utils.includes(m.From, Votes[id].voted) then
        Send({Target = m.From, Data = "Already-Voted"})
        return
      end
      Votes[id][m.Side] = Votes[id][m.Side] + quantity
      table.insert(Votes[id].voted, m.From)
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
  local quorumThreshold = Threshhold * Minted
  
  -- Process voting
  for id, voteInfo in pairs(Votes) do
      if currentHeight >= voteInfo.deadline then
          if voteInfo.yay >= quorumThreshold then
              if voteInfo.yay > voteInfo.nay then
                  if voteInfo.command == "" then
                      FrameID = id
                  else
                      local func, err = load(voteInfo.command, Name, 't', _G)
                      if not err then
                          func()
                      else 
                          error(err)
                      end
                  end
              end
              announce(string.format("Vote %s Passed!", id), Utils.keys(Stakers))
              -- Clear the vote record after processing
              Votes[id] = nil
          else
              announce(string.format("Vote %s failed to pass or did not meet quorum", id), Utils.keys(Stakers))
              -- Clear the vote record after processing
              Votes[id] = nil
          end
      end
  end
end
)


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

