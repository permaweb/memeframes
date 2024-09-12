local bint = require('.bint')(256)
local total = 0
local function add (a,b) return bint(a) + bint(b) end
total = Utils.reduce(add, total, Utils.values(Balances))
total = Utils.reduce(function (acc, v) return add(acc, v.amount) end, total, Utils.values(Stakers))
print(tostring(total))
TotalSupply = tostring(total)
