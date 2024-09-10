Threshhold = 0.025

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
              announce(string.format("Vote %s Complete", id), Utils.keys(Stakers))
              -- Clear the vote record after processing
              Votes[id] = nil
          else
              announce(string.format("Vote %s did not meet quorum to pass", id), Utils.keys(Stakers))
              -- Clear the vote record after processing
              Votes[id] = nil
          end
      end
  end
end
)

