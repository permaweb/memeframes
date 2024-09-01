local bint = require('.bint')(256)

local utils = {
  add = function(a, b)
    return tostring(bint(a) + bint(b))
  end,
  subtract = function(a, b)
    return tostring(bint(a) - bint(b))
  end,
  toBalanceValue = function(a)
    return tostring(bint(a))
  end,
  toNumber = function(a)
    return bint.tonumber(a)
  end
}

Handlers.add('transfer', Handlers.utils.hasMatchingTag('Action', 'Transfer'), function(msg)
    assert(type(msg.Recipient) == 'string', 'Recipient is required!')
    assert(type(msg.Quantity) == 'string', 'Quantity is required!')
    assert(bint.__lt(0, bint(msg.Quantity)), 'Quantity must be greater than 0')
  
    if not Balances[msg.From] then Balances[msg.From] = "0" end
    if not Balances[msg.Recipient] then Balances[msg.Recipient] = "0" end
  
    if bint(msg.Quantity) <= bint(Balances[msg.From]) then
      Balances[msg.From] = utils.subtract(Balances[msg.From], msg.Quantity)
      Balances[msg.Recipient] = utils.add(Balances[msg.Recipient], msg.Quantity)
  
      --[[
           Only send the notifications to the Sender and Recipient
           if the Cast tag is not set on the Transfer message
         ]]
      --
      if not msg.Cast then
        -- Debit-Notice message template, that is sent to the Sender of the transfer
        local debitNotice = {
          Target = msg.From,
          Action = 'Debit-Notice',
          Recipient = msg.Recipient,
          Quantity = msg.Quantity,
          Data = Colors.gray ..
              "You transferred " ..
              Colors.blue .. msg.Quantity .. Colors.gray .. " to " .. Colors.green .. msg.Recipient .. Colors.reset
        }
        -- Credit-Notice message template, that is sent to the Recipient of the transfer
        local creditNotice = {
          Target = msg.Recipient,
          Action = 'Credit-Notice',
          Sender = msg.From,
          Quantity = msg.Quantity,
          Data = Colors.gray ..
              "You received " ..
              Colors.blue .. msg.Quantity .. Colors.gray .. " from " .. Colors.green .. msg.From .. Colors.reset
        }
  
        -- Add forwarded tags to the credit and debit notice messages
        for tagName, tagValue in pairs(msg) do
          -- Tags beginning with "X-" are forwarded
          if string.sub(tagName, 1, 2) == "X-" then
            debitNotice[tagName] = tagValue
            creditNotice[tagName] = tagValue
          end
        end
  
        -- Send Debit-Notice and Credit-Notice
        ao.send(debitNotice)
        ao.send(creditNotice)
      end
    else
      ao.send({
        Target = msg.From,
        Action = 'Transfer-Error',
        ['Message-Id'] = msg.Id,
        Error = 'Insufficient Balance!'
      })
    end
  end)


Handlers.add('balance', "Balance", function(msg)
  local bal = '0'

  -- If not Recipient is provided, then return the Senders balance
  if (msg.Tags.Recipient) then
    if (Balances[msg.Tags.Recipient]) then
      bal = Balances[msg.Tags.Recipient]
    end
  elseif msg.Tags.Target and Balances[msg.Tags.Target] then
    bal = Balances[msg.Tags.Target]
  elseif Balances[msg.From] then
    bal = Balances[msg.From]
  end

  Send({
    Target = msg.From,
    Balance = bal,
    Ticker = Ticker,
    Account = msg.Tags.Recipient or msg.From,
    Data = bal
  })
end)


Handlers.add('balances', "Balances",
  function(msg) 
    Send({ Target = msg.From, Data = require('json').encode(Balances) }) 
  end
)
