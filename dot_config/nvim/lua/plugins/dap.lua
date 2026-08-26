-- Debug Adapter Protocol client. Needs a dap.adapters.<name> +
-- dap.configurations.<filetype> block added per language before a
-- session can actually start.
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    -- rdbg adapter wiring (port allocation, RUBY_DEBUG_* env launch,
    -- Rails/RSpec/Minitest presets) is fiddly enough to be worth a
    -- dedicated plugin rather than hand-rolling
    "suketa/nvim-dap-ruby",
  },
  keys = {
    { "<leader>d", nil, desc = "Debug" },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Continue / start",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle breakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Conditional breakpoint",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "Step into",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "Step over",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "Step out",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Toggle REPL",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Run last",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "Terminate",
    },
    {
      "<leader>dh",
      function()
        require("dap.ui.widgets").hover()
      end,
      mode = { "n", "v" },
      desc = "Hover value",
    },
    {
      "<leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "Toggle debug UI",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("nvim-dap-virtual-text").setup()
    require("dap-ruby").setup()

    -- open/close the UI automatically alongside a debug session
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}
