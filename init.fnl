(vim.loader.enable)

(fn set-global [table]
  (each [k v (pairs table)]
    (tset vim.g k v)))

(fn set-option [table]
  (each [k v (pairs table)]
    (tset vim.opt k v)))

(fn keymap [modes lhs rhs opts]
  (vim.keymap.set modes lhs rhs opts))

(set-global {:mapleader " "
             :maplocalleader " "
             :loaded_node_provider 0
             :loaded_perl_provider 0
             :loaded_python3_provider 0
             :loaded_ruby_provider 0})

(set-option {:signcolumn :yes
             :laststatus 3
             :scrolloff 8
             :sidescrolloff 8
             :wrap false
             :linebreak true
             :number true
             :relativenumber true
             :tabstop 8
             :softtabstop 4
             :shiftwidth 4
             :expandtab true
             :list true
             :listchars {:tab "» " :trail "·" :nbsp "␣"}
             :fillchars {:eob " "}
             :smartcase true
             :ignorecase true
             :inccommand :split
             :splitright true
             :splitbelow true
             :updatetime 300
             :timeoutlen 300
             :confirm true
             :undofile true
             :swapfile false
             :writebackup false
             :winborder :rounded
             :pumheight 10
             :showcmd false
             :showmode false
             :termguicolors true
             :clipboard :unnamedplus})

(keymap :n :n :nzzzv {:desc "Center search result"})
(keymap :n :N :Nzzzv {:desc "Center previous search result"})
(keymap :n :<C-d> :<C-d>zz {:desc "Center page up"})
(keymap :n :<C-u> :<C-u>zz {:desc "Center page down"})
(keymap :n :<A-j> ":m .+1<cr>==" {:desc "Move line down"})
(keymap :n :<A-k> ":m .-2<cr>==" {:desc "Move line up"})
(keymap :v :<A-j> ":m '>+1<CR>gv=gv" {:desc "Move selection down"})
(keymap :v :<A-k> ":m '<-2<CR>gv=gv" {:desc "Move selection up"})
(keymap :v "<" :<gv {:desc "Indent left"})
(keymap :v ">" :>gv {:desc "Indent right"})

(vim.api.nvim_create_autocmd :TextYankPost
                             {:desc "Highlight selection on yank"
                              :group (vim.api.nvim_create_augroup :highlight-yank
                                                                  {:clear true})
                              :pattern "*"
                              :callback (fn []
                                          (vim.hl.on_yank {:timeout 100
                                                           :visual true}))})

(vim.api.nvim_create_autocmd :FileType
                             {:desc "Disable inserting comments on new line"
                              :group (vim.api.nvim_create_augroup :disable-auto-comments
                                                                  {:clear true})
                              :callback (fn []
                                          (vim.opt_local.formatoptions:remove [:c
                                                                               :r
                                                                               :o]))})

(require :statusline)

(require :lsp_setup)

(vim.pack.add [{:src "https://github.com/oskarnurm/koda.nvim"}
               {:src "https://github.com/atweiden/vim-fennel"}
               {:src "https://github.com/stevearc/conform.nvim"}
               {:src "https://github.com/mfussenegger/nvim-lint"}
               {:src "https://github.com/rafamadriz/friendly-snippets"}
               {:src "https://github.com/saghen/blink.cmp"}
               {:src "https://github.com/ibhagwan/fzf-lua"}
               {:src "https://github.com/lewis6991/gitsigns.nvim"}
               {:src "https://github.com/nvim-mini/mini.surround"}
               {:src "https://github.com/nvim-mini/mini.ai"}
               {:src "https://github.com/MeanderingProgrammer/render-markdown.nvim"}
               {:src "https://github.com/nvim-tree/nvim-web-devicons"}])

(let [color (require :koda)]
  (color.setup {:transparent true})
  (vim.cmd.colorscheme :koda))

(let [conform (require :conform)]
  (conform.setup {:formatters_by_ft {:lua [:stylua]
                                     :fennel [:fnlfmt]
                                     :c [:clang-format]
                                     :cpp [:clang-format]
                                     :python [:ruff_fix
                                              :ruff_format
                                              :ruff_organize_imports]}})
  (keymap :n :<leader>ff
          (lambda []
            (conform.format {:timeout_ms 500 :lsp_format :fallback}))
          {:desc "Format file"}))

(let [lint (require :lint)]
  (set lint.linters_by_ft {:python [:ruff] :c [:clangtidy] :cpp [:clangtidy]}))

(vim.api.nvim_create_autocmd [:BufWritePost :BufReadPost]
                             {:callback (fn []
                                          ((. (require :lint) :try_lint)))})

(let [blink (require :blink.cmp)]
  (blink.setup {:snippets {:preset :default}
                :completion {:list {:selection {:preselect false
                                                :auto_insert true}
                                    :max_items 10}
                             :documentation {:window {:border :rounded}
                                             :auto_show true}
                             :menu {:border :rounded :scrollbar false}}
                :cmdline {:enabled false}
                :sources {:default [:lsp :path :snippets]}
                :signature {:enabled true}}))

(let [fzf (require :fzf-lua)]
  (fzf.setup {:winopts {:height 0.5 :width 0.5 :preview {:hidden true}}
              :oldfiles {:cwd_only true :include_current_session true}
              :defaults {:file_icons true}}))

(keymap :n :<leader>. "<cmd>FzfLua files<cr>" {:desc "Find files"})
(keymap :n "<leader>," "<cmd>FzfLua buffers<cr>" {:desc "Find buffers"})
(keymap :n :<leader>fg "<cmd>FzfLua live_grep<cr>" {:desc :Grep})
(keymap :x :<leader>fg "<cmd>FzfLua grep_visual<cr>" {:desc "Grep line"})
(keymap :n :<leader>fh "<cmd>FzfLua helptags<cr>" {:desc :Helptags})
(keymap :n :<leader>fd "<cmd>FzfLua lsp_document_diagnostics<cr>"
        {:desc "LSP diagnostics"})

(let [gitsigns (require :gitsigns)]
  (gitsigns.setup {:preview_config {:border :rounded}
                   :signcolumn false
                   :numhl true}))

(let [surround (require :mini.surround)]
  (surround.setup {}))

(let [ai (require :mini.ai)]
  (ai.setup {}))

(let [markdown (require :render-markdown)]
  (markdown.setup {:html {:enabled false}
                   :latex {:enabled false}
                   :yaml {:enabled false}}))
