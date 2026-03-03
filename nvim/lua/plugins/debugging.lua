return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
    "nvim-telescope/telescope-dap.nvim",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
    local codelldb = vim.fn.stdpath("data")
      .. "/mason/packages/codelldb/extension/adapter/codelldb"

		dapui.setup({
			controls = {
				element = "repl",
				enabled = true,
				icons = {
					disconnect = "",
					pause = "",
					play = "",
					run_last = "",
					step_back = "",
					step_into = "",
					step_out = "",
					step_over = "",
					terminate = "",
				},
			},
			element_mappings = {},
			expand_lines = true,
			floating = {
				border = "rounded",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			force_buffers = true,
			icons = {
				collapsed = "",
				current_frame = "",
				expanded = "",
			},
			layouts = {
				{
					elements = {
						{
							id = "scopes",
							size = 0.25,
						},
						{
							id = "breakpoints",
							size = 0.25,
						},
						{
							id = "stacks",
							size = 0.25,
						},
						{
							id = "watches",
							size = 0.25,
						},
					},
					position = "right",
					size = 50,
				},
				{
					elements = {
						{
							id = "repl",
							size = 0.5,
						},
						{
							id = "console",
							size = 0.5,
						},
					},
					position = "bottom",
					size = 10,
				},
			},
			mappings = {
				edit = "e",
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				repl = "r",
				toggle = "t",
			},
			render = {
				indent = 1,
				max_value_lines = 100,
			},
		})

		for _, adapterType in ipairs({ "node", "chrome", "msedge" }) do
			local pwaType = "pwa-" .. adapterType

			dap.adapters[pwaType] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb,
    args = { "--port", "${port}" },
    detached = false,
  },
}

 -- ---------- Helpers ----------
      local function cwd()
        return vim.fn.getcwd()
      end

      local function dirname_name_lower()
        local dir = cwd()
        local name = vim.fn.fnamemodify(dir, ":t")
        return dir, name, string.lower(name)
      end

      local function is_executable(path)
        return path and path ~= "" and vim.fn.filereadable(path) == 1 and vim.fn.executable(path) == 1
      end

      local function newest_executable_in_dir(dir)
        local best_path, best_mtime = nil, -1

        for name, t in vim.fs.dir(dir) do
          if t == "file" then
            local path = dir .. "/" .. name

            -- skip obvious non-binaries
            if not name:match("%.cpp$") and not name:match("%.c$") and not name:match("%.h$") and not name:match("%.hpp$")
              and not name:match("%.o$") and not name:match("%.a$") and not name:match("%.so$")
              and not name:match("%.txt$") and not name:match("%.md$") and not name:match("%.lua$")
            then
              if is_executable(path) then
                local st = vim.uv.fs_stat(path)
                local mtime = (st and st.mtime and st.mtime.sec) or 0
                if mtime > best_mtime then
                  best_mtime = mtime
                  best_path = path
                end
              end
            end
          end
        end

        return best_path
      end

      local function auto_program()
        local dir, _, lower = dirname_name_lower()

        -- Common, predictable candidates first
        local candidates = {
          dir .. "/" .. lower,              -- SteakCooker -> steakcooker
          dir .. "/build/" .. lower,        -- build/steakcooker
          dir .. "/a.out",                  -- a.out
          dir .. "/build/main",             -- build/main (only if you actually build it)
        }

        for _, p in ipairs(candidates) do
          if is_executable(p) then
            return p
          end
        end

        -- Fallback: newest executable sitting in the folder
        local found = newest_executable_in_dir(dir)
        if found then
          return found
        end

        -- Last resort: show a clear error instead of a random path
        vim.notify(
          "No executable found in: " .. dir .. "\nBuild one (e.g. `g++ -g main.cpp -o " .. lower .. "`)",
          vim.log.levels.ERROR
        )
        return dir .. "/" .. lower
      end

dap.configurations.cpp = {
        {
          name = "Debug (auto-detect executable)",
          type = "codelldb",
          request = "launch",
          program = auto_program,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Debug (a.out)",
          type = "codelldb",
          request = "launch",
          program = function() return cwd() .. "/a.out" end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Debug (this file -> build/<file>)",
          type = "codelldb",
          request = "launch",
          program = function()
            return cwd() .. "/build/" .. vim.fn.expand("%:t:r")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Debug (args)",
          type = "codelldb",
          request = "launch",
          program = auto_program,
          cwd = "${workspaceFolder}",
          args = function()
            local input = vim.fn.input("Args: ")
            if input == nil or input == "" then return {} end
            return vim.split(input, "%s+")
          end,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
        },
      }


dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

			-- this allow us to handle launch.json configurations
			-- which specify type as "node" or "chrome" or "msedge"
			dap.adapters[adapterType] = function(cb, config)
				local nativeAdapter = dap.adapters[pwaType]

				config.type = pwaType

				if type(nativeAdapter) == "function" then
					nativeAdapter(cb, config)
				else
					cb(nativeAdapter)
				end
			end
		end

		local enter_launch_url = function()
			local co = coroutine.running()
			return coroutine.create(function()
				vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:" }, function(url)
					if url == nil or url == "" then
						return
					else
						coroutine.resume(co, url)
					end
				end)
			end)
		end

		for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }) do
			dap.configurations[language] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file using Node.js (nvim-dap)",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to process using Node.js (nvim-dap)",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
				-- requires ts-node to be installed globally or locally
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file using Node.js with ts-node/register (nvim-dap)",
					program = "${file}",
					cwd = "${workspaceFolder}",
					runtimeArgs = { "-r", "ts-node/register" },
				},
				{
					type = "pwa-chrome",
					request = "launch",
					name = "Launch Chrome (nvim-dap)",
					url = enter_launch_url,
					webRoot = "${workspaceFolder}",
					sourceMaps = true,
				},
				{
					type = "pwa-msedge",
					request = "launch",
					name = "Launch Edge (nvim-dap)",
					url = enter_launch_url,
					webRoot = "${workspaceFolder}",
					sourceMaps = true,
				},
			}
		end

		local netcoredbgCommand = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe"

		dap.adapters.coreclr = {
			type = "executable",
			command = netcoredbgCommand,
			args = { "--interpreter=vscode" },
		}

		local dotnet_build_project = function()
			local default_path = vim.fn.getcwd() .. "/"

			if vim.g["dotnet_last_proj_path"] ~= nil then
				default_path = vim.g["dotnet_last_proj_path"]
			end

			local path = vim.fn.input("Path to your *proj file", default_path, "file")

			vim.g["dotnet_last_proj_path"] = path

			local cmd = "dotnet build -c Debug " .. path .. ""

			print("")
			print("Cmd to execute: " .. cmd)

			local f = os.execute(cmd)

			if f == 0 then
				print("\nBuild: ✔️ ")
			else
				print("\nBuild: ❌ (code: " .. f .. ")")
			end
		end

		local dotnet_get_dll_path = function()
			local request = function()
				return vim.fn.input("Path to dll to debug: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
			end

			if vim.g["dotnet_last_dll_path"] == nil then
				vim.g["dotnet_last_dll_path"] = request()
			else
				if
					vim.fn.confirm("Change the path to dll?\n" .. vim.g["dotnet_last_dll_path"], "&yes\n&no", 2) == 1
				then
					vim.g["dotnet_last_dll_path"] = request()
				end
			end

			return vim.g["dotnet_last_dll_path"]
		end

		dap.configurations.cs = {
			{
				type = "coreclr",
				name = "Launch - coreclr (nvim-dap)",
				request = "launch",
				program = function()
					if vim.fn.confirm("Rebuild first?", "&yes\n&no", 2) == 1 then
						dotnet_build_project()
					end

					return dotnet_get_dll_path()
				end,
			},
		}

		local codelldb_path = vim.fn.has("win32") 
      and vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb.exe" 
      or vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"

    dap.adapters.lldb = {
      type = 'executable',
      command = '/usr/bin/lldb-dap', -- adjust as needed, must be absolute path
      name = 'lldb'
    }	

		local convertArgStringToArray = function(config)
			local c = {}

			for k, v in pairs(vim.deepcopy(config)) do
				if k == "args" and type(v) == "string" then
					c[k] = require("dap.utils").splitstr(v)
				else
					c[k] = v
				end
			end

			return c
		end

		for key, _ in pairs(dap.configurations) do
			dap.listeners.on_config[key] = convertArgStringToArray
		end

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
		vim.keymap.set("n", "<Leader>dbc", dap.clear_breakpoints, { desc = "Clear all breakpoints" })
		vim.keymap.set("n", "<Leader>dbl", dap.list_breakpoints, { desc = "List all breakpoints" })

		local continue = function()
			-- support for vscode launch.json is partial.
			-- not all configuration options and features supported
			if vim.fn.filereadable(".vscode/launch.json") then
				require("dap.ext.vscode").load_launchjs()
			end
			dap.continue()
		end

		vim.keymap.set("n", "<Leader>dc", continue, { desc = "Continue" })
	end,
}
