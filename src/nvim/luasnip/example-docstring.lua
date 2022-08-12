-- This file lies in `~/.config/nvim/luasnippets/all` on my computer

local doc1 = s({ trig = "doc(%d)", regTrig = true, }, f(
  function(_args, snip)
    return string.rep("repeatme ", tonumber(snip.captures[1]))
  end, {}
))
local doc2 = s({ trig = "doc(%d)", regTrig = true, docTrig = "doc2" }, f(
  function(_args, snip)
    return string.rep("repeatme ", tonumber(snip.captures[1]))
  end, {}
))
local doc3 = s({ trig = "doc_three(%d)", regTrig = true, docstring = "repeatmerepeatmerepeatme" }, f(
  function(_args, snip)
    return string.rep("repeatme ", tonumber(snip.captures[1]))
  end, {}
))

local function gen(snip)
  return table.concat(snip:get_docstring())
end

-- local ls = require "luasnip"
-- equivalent to return { doc1, doc2, doc3 }
-- ls.add_snippets("all", { doc1, doc2, doc3 })

local dyn = s("dyn_return", d(1, function(args, parent)
  return sn(nil, {
    t(parent.snippet.env.DYN_ONE),
    t "..",
    t(table.concat(parent.snippet.env.DYN_TWO)),
    t "..",
    t(tostring(#parent.snippet.env.DYN_TWO)), -- This one behaves as a table
    t "..",
    t(parent.snippet.env.WTF_YEA), -- Unknow vars also work
  })
end, {}))
-- print(dyn:get_docstring()[1])

return {
  -- parse("doc_one", gen(doc1)),
  parse("doc_two", gen(doc2)),
  parse("doc_three", gen(doc3)),
  doc1,
  parse("dyn_parse", gen(dyn)),
  dyn,
  parse("dyn_plain", "${1:$DYN_ONE..$DYN_TWO..1..$WTF_YEA}$0"),
}
