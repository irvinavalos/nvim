(local icons (require :icons))

(fn lsp-diagnostics-count [severity-level]
  (if (not (rawget vim :lsp))
      0
      (let [count (. (vim.diagnostic.count 0 {:severity severity-level})
                     severity-level)]
        (if (= count nil) 0 count))))

(fn git-diff [diff-type]
  (let [gsd vim.b.gitsigns_status_dict]
    (if (and gsd (. gsd diff-type))
        (. gsd diff-type) 0)))

(fn mode []
  (string.format "%%#StatusLineMode# %s %%*" (. (vim.api.nvim_get_mode) :mode)))

(fn python-env []
  (let [venv (os.getenv :VIRTUAL_ENV_PROMPT)]
    (if (= venv nil)
        ""
        (let [venv-str (string.gsub venv "%s+" "")]
          (string.format "%%#StatusLineMedium# %s%%*" venv-str)))))

(fn lsp-active []
  (if (not (rawget vim :lsp))
      ""
      (let [curr-buf (vim.api.nvim_get_current_buf)
            clients (vim.lsp.get_clients {:bufnr curr-buf})
            space "%#StatusLineMedium# %*"]
        (if (> (length clients) 0) (.. space "%#StatusLineMedium#LSP%* ") ""))))

(fn diagnostics-error []
  (let [count (lsp-diagnostics-count vim.diagnostic.severity.ERROR)]
    (if (> count 0)
        (string.format "%%#StatusLineLspError# %s %s%%*"
                       icons.diagnostics.ERROR count)
        "")))

(fn diagnostics-warning []
  (let [count (lsp-diagnostics-count vim.diagnostic.severity.WARN)]
    (if (> count 0)
        (string.format "%%#StatusLineLspWarn# %s %s%%*" icons.diagnostics.WARN
                       count)
        "")))

(fn diagnostics-info []
  (let [count (lsp-diagnostics-count vim.diagnostic.severity.INFO)]
    (if (> count 0)
        (string.format "%%#StatusLineLspInfo# %s %s%%*" icons.diagnostics.INFO
                       count)
        "")))

(fn diagnostics-hint []
  (let [count (lsp-diagnostics-count vim.diagnostic.severity.HINT)]
    (if (> count 0)
        (string.format "%%#StatusLineLspHint# %s %s%%*" icons.diagnostics.HINT
                       count)
        "")))

(local lsp-progress {:client nil
                     :kind nil
                     :title nil
                     :percentage nil
                     :message nil})

(local statusline-augroup
       (vim.api.nvim_create_augroup :gmr_statusline {:clear true}))

(vim.api.nvim_create_autocmd :LspProgress
                             {:group statusline-augroup
                              :desc "Update LSP progress bar in statusline"
                              :pattern [:begin :report :end]
                              :callback (fn [args]
                                          (when (and args.data
                                                     args.data.client_id)
                                            (set lsp-progress.client
                                                 (vim.lsp.get_client_by_id args.data.client_id))
                                            (set lsp-progress.kind
                                                 args.data.params.value.kind)
                                            (set lsp-progress.message
                                                 args.data.params.value.message)
                                            (set lsp-progress.percentage
                                                 args.data.params.value.percentage)
                                            (set lsp-progress.title
                                                 args.data.params.value.title)
                                            (if (= lsp-progress.kind :end)
                                                (do
                                                  (set lsp-progress.title nil)
                                                  (vim.defer_fn (fn []
                                                                  (vim.cmd.redrawstatus))
                                                    500))
                                                (vim.cmd.redrawstatus))))})

(fn lsp-status []
  (if (not (rawget vim :lsp))
      ""
      (< vim.o.columns 120)
      ""
      (or (not lsp-progress.client) (not lsp-progress.title))
      ""
      (let [title (or lsp-progress.title "")
            percentage (or (and lsp-progress.percentage
                                (.. lsp-progress.percentage "%%"))
                           "")
            message (or lsp-progress.message "")]
        (var lsp-message (string.format "%s" title))
        (if (not= message "")
            (set lsp-message (string.format "%s %s" lsp-message message)))
        (if (not= percentage "")
            (set lsp-message (string.format "%s %s" lsp-message percentage)))
        (string.format "%%#StatusLineLspMessages#%s%%* " lsp-message))))

(fn git-diff-added []
  (let [added (git-diff :added)]
    (if (> added 0) (string.format "%%#StatusLineGitDiffAdded#+%s%%*" added) "")))

(fn git-diff-changed []
  (let [changed (git-diff :changed)]
    (if (> changed 0)
        (string.format "%%#StatusLineGitDiffChanged#~%s%%*" changed)
        "")))

(fn git-diff-removed []
  (let [removed (git-diff :removed)]
    (if (> removed 0)
        (string.format "%%#StatusLineGitDiffRemoved#-%s%%*" removed)
        "")))

(fn git-branch-icon []
  "%#StatusLineGitBranchIcon#%*")

(fn git-branch []
  (let [branch vim.b.gitsigns_head]
    (if (or (= branch "") (= branch nil)) ""
        (string.format "%%#StatusLineMedium#%s%%*" branch))))

(fn full-git []
  (var full "")
  (local space "%#StatusLineMedium# %*")
  (local branch (git-branch))
  (if (not= branch "")
      (let [icon (git-branch-icon)]
        (set full (.. full space icon space branch space))))
  (local added (git-diff-added))
  (if (not= added "") (set full (.. full added space)))
  (local changed (git-diff-changed))
  (if (not= changed "") (set full (.. full changed space)))
  (local removed (git-diff-removed))
  (if (not= removed "") (set full (.. full removed space)))
  full)

(fn file-percentage []
  (local curr-line (. (vim.api.nvim_win_get_cursor 0) 1))
  (local lines (vim.api.nvim_buf_line_count 0))
  (string.format "%%#StatusLineMedium#  %d%%%% %%*"
                 (math.ceil (* (/ curr-line lines) 100))))

(fn total-lines []
  (local lines (vim.fn.line "$"))
  (string.format "%%#StatusLineMedium#of %s %%*" lines))

(fn cursor-position []
  (local pos (vim.api.nvim_win_get_cursor 0))
  (local line (. pos 1))
  (local col (+ (. pos 2) 1))
  (string.format "%%#StatusLineMedium# %d:%d %%*" line col))

(fn formatted-filetype [hlgroup]
  (local filetype (or vim.bo.filetype (vim.fn.expand "%:e" false)))
  (string.format "%%#%s# %s %%*" hlgroup filetype))

(fn filename []
  (var name (vim.fn.expand "%:t"))
  (if (= name "") (set name "[No Name]"))
  (string.format "%%#StatusLineMedium# %s %%*" name))

(global StatusLine {})

(set StatusLine.inactive
     (fn []
       (table.concat [(formatted-filetype :StatusLineMode)])))

(local readable-filetypes {:qf true :help true :tsplayground true})

(set StatusLine.active
     (fn []
       (let [mode-str (. (vim.api.nvim_get_mode) :mode)]
         (if (or (= mode-str :t) (= mode-str :nt))
             (table.concat [(mode) "%=" "%=" (file-percentage) (total-lines)])
             (or (. readable-filetypes vim.bo.filetype)
                 (= vim.o.modifiable false))
             (table.concat [(formatted-filetype :StatusLineMode)
                            "%="
                            "%="
                            (file-percentage)
                            (total-lines)])
             (table.concat [(mode)
                            (filename)
                            (full-git)
                            "%="
                            "%="
                            "%S"
                            (lsp-status)
                            (diagnostics-error)
                            (diagnostics-warning)
                            (diagnostics-hint)
                            (diagnostics-info)
                            (lsp-active)
                            (python-env)
                            (cursor-position)
                            (file-percentage)
                            (total-lines)])))))

(set vim.opt.statusline "%!v:lua.StatusLine.active()")

(vim.api.nvim_create_autocmd [:WinEnter :BufEnter :FileType]
                             {:group statusline-augroup
                              :pattern [:NvimTree_1
                                        :NvimTree
                                        :TelescopePrompt
                                        :fzf
                                        :lspinfo
                                        :lazy
                                        :netrw
                                        :mason
                                        :noice
                                        :qf]
                              :callback (fn []
                                          (set vim.opt_local.statusline
                                               "%!v:lua.StatusLine.inactive()"))})
