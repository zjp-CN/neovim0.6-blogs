-- This file lies under the path detected and loaded by nvim
-- e.g. `~/.config/nvim/plugin` on my computer

local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt
local extras = require("luasnip.extras")
local m = require("luasnip.extras").m
local l = require("luasnip.extras").l
local postfix = require("luasnip.extras.postfix").postfix

local function reused_func(_, _, user_arg1)
  return user_arg1
end

local function count(_, _, old_state)
  old_state = old_state or {
    updates = 0
  }

  old_state.updates = old_state.updates + 1

  local snip = sn(nil, {
    t(tostring(old_state.updates))
  })

  snip.old_state = old_state
  return snip
end

local function simple_restore(args, _)
  return sn(nil, { i(1, args[1]), i(2, "user_text") })
end

local function simple_restore2(args, _)
  return sn(nil, { i(1, args[1]), r(2, "dyn", i(nil, "user_text")) })
end

ls.add_snippets("all", {
  s("ternary", {
    -- equivalent to "${1:cond} ? ${2:then} : ${3:else}"
    i(1, "cond"), t(" ? "), i(2, "then"), t(" : "), i(3, "else")
  }),
  s("trigger", {
    i(1, "First jump"),
    t(" :: "),
    sn(2, {
      i(1, "Second jump"),
      t " : ",
      i(2, "Third jump")
    })
  }),
  s("trig", {
    i(1),
    f(
      function(args, snip, user_arg_1) return user_arg_1 .. args[1][1] end,
      { 1 },
      { user_args = { "Will be appended to text from i(0)", "aabb" } }
    ),
    i(0)
  }),
  s("trig2", {
    f(reused_func, {}, { user_args = { "text " } }),
    f(reused_func, {}, { user_args = { "different text" } }),
  }),
  s({ trig = "b(%d)", regTrig = true },
    f(function(args, snip) return "Captured Text: " .. snip.captures[1] .. "."
    end, {})
  ),
  s("trig3", {
    i(1, "text_of_first "),
    i(2, { "first_line_of_second", "second_line_of_second" }),
    -- order is 2,1, not 1,2!!
    f(function(args, snip)
      return " end"
    end, { 2, 1 })
  }),
  s("trig4", {
    i(1, "text_of_first "),
    i(2, { "first_line_of_second", "second_line_of_second", "" }),
    -- order is 2,1, not 1,2!!
    f(function(args, snip)
      return args[1][1] .. " " .. args[1][2] .. args[2][1] .. " end"
    end, { 2, 1 })
  }),
  s("trig5", {
    i(1, " text_of_first "),
    i(2, { " first_line_of_second ", " second_line_of_second " }),
    f(function(args, snip)
      return args[1][1] .. args[1][2] .. args[2][1]
    end, { ai[2], ai[1] }) }),
  postfix(".br", {
    f(function(_, parent)
      return "[" .. parent.snippet.env.POSTFIX_MATCH .. "]"
    end, {}),
  }),
  postfix(".brl", {
    l("[" .. l.POSTFIX_MATCH .. "]"),
  }),
  postfix(".brd", {
    d(1, function(_, parent)
      return sn(nil, { t("[" .. parent.env.POSTFIX_MATCH .. "]") })
    end)
  }),
  s("trig6", c(1, {
    t("Ugh boring, a text node"),
    i(nil, "At least I can edit something now..."),
    f(function(args) return "Still only counts as text!!" end, {})
  })),
  s("trig7", sn(1, {
    t("basically just text "),
    i(1, "And an insertNode.")
  })),
  s("isn", {
    isn(1, {
      t({ "This is indented as deep as the trigger",
        "and this is at the beginning of the next line" })
    }, "")
  }),
  s("isn2", {
    isn(1, t({ "//This is", "A multiline", "comment" }), "$PARENT_INDENT//")
  }),
  s("trig8", {
    t "text: ", i(1), t { "", "copy: " },
    d(2, function(args)
      -- the returned snippetNode doesn't need a position; it's inserted
      -- "inside" the dynamicNode.
      return sn(nil, {
        -- jump-indices are local to each snippetNode, so restart at 1.
        i(1, args[1])
      })
    end,
      { 1 })
  }),
  s("trig9", {
    i(1, "change to update"),
    d(2, count, { 1 })
  }),
  s("paren_change", {
    c(1, {
      sn(nil, { t("("), r(1, "user_text"), t(")") }),
      sn(nil, { t("["), r(1, "user_text"), t("]") }),
      sn(nil, { t("{"), r(1, "user_text"), t("}") }),
    }),
  }, {
    stored = {
      user_text = i(1, "default_text")
    }
  }),
  s("rest", {
    i(1, "preset"), t { "", "" },
    d(2, simple_restore, 1)
  }),
  s("rest2", {
    i(1, "preset"), t { "", "" },
    d(2, simple_restore2, 1)
  }),
  s("trig_ai", {
    i(1), c(2, {
      sn(nil, {
        t "cannot access the argnode :(",
        f(function(args) return args[1] end, { 1 })
      }),
      t "sample_text"
    })
  }),
  s("trig_ai2", {
    i(1), c(2, {
      sn(nil, {
        t "can access the argnode :)",
        f(function(args) return args[1] end, { ai[1] })
      }),
      t "sample_text"
    })
  }),

  -- extras
  s("extras1", {
    i(1), t { "", "" }, m(1, "^ABC$", "A")
  }),
  s("extras2", {
    i(1, "INPUT"), t { "", "" }, m(1, l._1:match(l._1:reverse()), "PALINDROME")
  }),
  s("extras3", {
    i(1), t { "", "" }, i(2), t { "", "" },
    m({ 1, 2 }, l._1:match("^" .. l._2 .. "$"), l._1:gsub("a", "e"))
  }),
  s("extras4", { i(1), t { "", "" }, extras.rep(1) }),
  s("extras5", { extras.partial(os.date, "%Y") }),
  s("extras6", { i(1, ""), t { "", "" }, extras.nonempty(1, "not empty!", "empty!") }),
  s("extras7", { i(1), t { "", "" }, extras.dynamic_lambda(2, l._1 .. l._1, 1) }),
})

ls.add_snippets("all", {
  -- important! fmt does not return a snippet, it returns a table of nodes.
  s("example1", fmt("just an {iNode1}", {
    iNode1 = i(1, "example")
  })),
  s("example2", fmt([[
  if {} then
    {}
  end
  ]], {
    -- i(1) is at nodes[1], i(2) at nodes[2].
    i(1, "not now"), i(2, "when")
  })),
  s("example3", fmt([[
  if <> then
    <>
  end
  ]], {
    -- i(1) is at nodes[1], i(2) at nodes[2].
    i(1, "not now"), i(2, "when")
  }, {
    delimiters = "<>"
  })),
})

ls.config.setup {
  load_ft_func =
  -- Also load both lua and json when a markdown-file is opened,
  -- javascript for html.
  -- Other filetypes just load themselves.
  require "luasnip.extras.filetype_functions".extend_load_ft {
    markdown = { "lua", "json" },
    html = { "javascript" }
  }
}

ls.env_namespace("DYN", {
  vars = { ONE = "1", TWO = { "1", "2" } },
  multiline_vars = { "TWO" }
})

local function random_lang()
  return ({ "LUA", "VIML", "VIML9" })[math.floor(math.random() / 2 + 1.5)]
end

ls.env_namespace("MY", { vars = { NAME = "LuaSnip", LANG = random_lang } })

-- then you can use  $MY_NAME and $MY_LANG in your snippets

ls.env_namespace("SYS", { vars = os.getenv, eager = { "HOME" } })

-- then you can use  $SYS_HOME which was eagerly initialized but also $SYS_USER (or any other system environment var) in your snippets

ls.env_namespace("POS", { init = function(pos) return { VAL = vim.inspect(pos) } end })

-- then you can use  $POS_VAL in your snippets

ls.add_snippets("all", {
  ls.parser.parse_snippet({ trig = "lsp" }, "$1 is ${2|hard,easy,challenging|}"),
  s("selected_text", f(function(args, snip)
    local res, env = {}, snip.env
    table.insert(res, "Selected Text (current line is " .. env.TM_LINE_NUMBER .. "):")
    for _, ele in ipairs(env.SELECT_RAW) do table.insert(res, ele) end
    return res
  end, {})),

  s("custom_env", d(1, function(args, parent)
    local env = parent.snippet.env
    return sn(nil, t {
      "NAME: " .. env.MY_NAME,
      "LANG: " .. env.MY_LANG,
      "HOME: " .. env.SYS_HOME,
      "USER: " .. env.SYS_USER,
      "VAL: " .. env.POS_VAL
    })
  end, {})),

  s("dyn_addsnip", d(1, function(args, parent)
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
})

vim.cmd [[
vnoremap <c-v>a  "ac<cmd>lua require('luasnip.extras.otf').on_the_fly()<cr>
inoremap <c-v>a  <cmd>lua require('luasnip.extras.otf').on_the_fly("a")<cr>
]]

require "luasnip".config.setup { store_selection_keys = "<Tab>" }
local paths = "./luasnippets"
require "luasnip.loaders.from_vscode".load { paths = paths }
require "luasnip.loaders.from_snipmate".load { paths = paths }
require "luasnip.loaders.from_lua".load { paths = paths }

-- require("luasnip.loaders").edit_snippet_files {
--   format = function(file, source_name)
--     if source_name == "lua" then return nil
--     else return file
--         :gsub("/root/.config/nvim/luasnippets", "$LuaSnip")
--     end
--   end
-- }
-- require("luasnip.loaders").edit_snippet_files { edit = function(file) vim.cmd("vs|e " .. file) end }

local ext_opts = {
  -- these ext_opts are applied when the node is active (e.g. it has been
  -- jumped into, and not out yet).
  active =
  -- this is the table actually passed to `nvim_buf_set_extmark`.
  {
    -- highlight the text inside the node red.
    -- hl_group = "Error"
    virt_text = { { "Active", "Error" } }
  },
  -- these ext_opts are applied when the node is not active, but
  -- the snippet still is.
  passive = {
    -- add virtual text on the line of the node, behind all text.
    virt_text = { { "virtual text!!", "WarningMsg" } }
  },
  -- and these are applied when both the node and the snippet are inactive.
  snippet_passive = {}
}

ls.add_snippets("all", {
  s("ext_opt", {
    i(1, "text1", {
      node_ext_opts = ext_opts
    }),
    t { "", "" },
    i(2, "text2", {
      node_ext_opts = ext_opts
    })
  }),

  -- s({ trig = "doc(%d)", regTrig = true, }, {
  --   f(function(args, snip)
  --     return string.rep("repeatme ", tonumber(snip.captures[1]))
  --   end, {})
  -- }),
  -- s({ trig = "doc(%d)", regTrig = true, docTrig = "2" }, {
  --   f(function(args, snip)
  --     return string.rep("repeatme ", tonumber(snip.captures[1]))
  --   end, {})
  -- }),
  -- s({ trig = "doc(%d)", regTrig = true, docstring = "repeatmerepeatmerepeatme" }, {
  --   f(function(args, snip)
  --     return string.rep("repeatme ", tonumber(snip.captures[1]))
  --   end, {})
  -- }),

})

-- vim.api.nvim_create_autocmd("User", {
--   pattern = "LuasnipInsertNodeEnter",
--   callback = function()
--     local node = require("luasnip").session.event_node
--     print(table.concat(node:get_text(), "\n"))
--   end
-- })

-- vim.api.nvim_create_autocmd("User", {
--   pattern = "LuasnipPreExpand",
--   callback = function()
--     -- get event-parameters from `session`.
--     local snippet = require("luasnip").session.event_node
--     local expand_position =
--     require("luasnip").session.event_args.expand_pos

--     print(string.format("expanding snippet %s at %s:%s",
--       table.concat(snippet:get_docstring(), "\n"),
--       expand_position[1],
--       expand_position[2]
--     ))
--   end
-- })
