-- Plugin configuration
return {
    "f-person/git-blame.nvim",
    config = function()
        -- Enable Git blame inline by default
        vim.g.gitblame_enabled = 1
        vim.g.gitblame_message_template = "<author> • <date> • <summary> (<sha>)"

        -- Set the delay for blame messages
        vim.g.gitblame_delay = 500

        -- Customize the blame text highlight group
        vim.g.gitblame_highlight_group = "GitBlame"
        vim.api.nvim_set_hl(0, "GitBlame", { fg = "#3B4261" }) -- Darker grey color

        -- Define the `open_pr` function globally
        _G.open_pr = function()
            -- Run git blame for the current line
            local blame = vim.fn.systemlist("git blame -L " .. vim.fn.line(".") .. ",+1 " .. vim.fn.expand("%"))
            if not blame or #blame == 0 or string.find(blame[1], "^0{8,}") then
                print("No blame information available for this line.")
                return
            end

            -- Extract the commit hash
            local sha = string.match(blame[1], "^%w+")
            if not sha then
                print("No commit hash found.")
                return
            end

            -- Get the commit message
            local commit_message = vim.fn.systemlist("git log --format=%B -n 1 " .. sha)
            if not commit_message or #commit_message == 0 then
                print("No commit message found.")
                return
            end

            -- Extract PR number from commit message (e.g., "Merge pull request #123")x
            local pr_number = string.match(table.concat(commit_message, "\n"), "#(%d+)")
            if not pr_number then
                print("No PR number found in the commit message.")
                return
            end

            -- Get the remote URL and normalize it
            local repo_url = vim.fn.systemlist("git config --get remote.origin.url")[1]
            if not repo_url or repo_url == "" then
                print("No remote repository URL found.")
                return
            end
            repo_url = repo_url:gsub("%.git$", ""):gsub("^git@(.+):", "https://%1/")

            -- Construct the PR URL and open it in the browser
            local pr_url = repo_url .. "/pull/" .. pr_number
            vim.fn.system({ "open", pr_url }) -- macOS-specific "open". Use "xdg-open" for Linux
            print("Opened PR in browser: " .. pr_url)
        end

        -- Map the keybinding to open PR
        vim.api.nvim_set_keymap("n", "<leader>go", ":lua open_pr()<CR>", { noremap = true, silent = true })

    end,
    event = "BufReadPost",
}
