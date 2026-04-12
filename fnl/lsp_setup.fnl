(fn key [lhs rhs opts bufnr]
  (let [mode :n]
    (let [key-opts (or (and (= (type opts) :string) {:desc opts}) opts)]
      (set key-opts.buffer bufnr)
      (vim.keymap.set mode lhs rhs key-opts))))

(fn on-attach [client bufnr]
  (if (client:supports_method :textDocument/codeAction)
      (key :gca "<cmd>FzfLua lsp_code_actions<CR>" "vim.lsp.buf.code_action()"
           bufnr))
  (if (client:supports_method :textDocument/references)
      (key :grr "<cmd>FzfLua lsp_references<CR>" "vim.lsp.buf.references()"
           bufnr))
  (if (client:supports_method :textDocument/implementation)
      (key :gri "<cmd>FzfLua lsp_implementations<CR>"
           "vim.lsp.buf.implementation()" bufnr))
  (if (client:supports_method :textDocument/typeDefinition)
      (key :grt "<cmd>FzfLua lsp_typedefs<CR>" "vim.lsp.buf.type_definition()"
           bufnr))
  (if (client:supports_method :textDocument/definition)
      (key :gd "<cmd>FzfLua lsp_definitions<CR>" "vim.lsp.buf.definition()"
           bufnr))
  (if (client:supports_method :textDocument/declaration)
      (key :gD "<cmd>FzfLua lsp_declarations<CR>" "vim.lsp.buf.declaration()"
           bufnr)))

(vim.api.nvim_create_autocmd [:LspAttach]
                             {:desc "Configure LSP keymaps"
                              :callback (fn [args]
                                          (let [client (vim.lsp.get_client_by_id args.data.client_id)]
                                            (if client
                                                (on-attach client args.buf))))})

(vim.lsp.enable (icollect [_ file (ipairs (vim.api.nvim_get_runtime_file :lsp/*.lua
                                                                         true))]
                  (vim.fn.fnamemodify file ":t:r")))

(local diagnostic_icons {:ERROR "  "
                         :WARN "  "
                         :HINT "  "
                         :INFO "  "})

(vim.diagnostic.config {:status {:format {:vim.diagnostic.severity.ERROR diagnostic_icons.ERROR
                                          :vim.diagnostic.severity.WARN diagnostic_icons.WARN
                                          :vim.diagnostic.severity.INFO diagnostic_icons.INFO
                                          :vim.diagnostic.severity.HINT diagnostic_icons.HINT}}
                        :virtual_text {:prefix ""
                                       :spacing 2
                                       :format (fn [diagnostic]
                                                 (local sources
                                                        {"Lua Diagnostics." :lua
                                                         "Lua Syntax Check." :lua})
                                                 (var msg
                                                      (. diagnostic_icons
                                                         (. vim.diagnostic.severity
                                                            diagnostic.severity)))
                                                 (when (. diagnostic :source)
                                                   (set msg
                                                        (or (string.format "%s %s"
                                                                           msg
                                                                           (. sources
                                                                              diagnostic.source))
                                                            (diagnostic.source))))
                                                 (when (. diagnostic :code)
                                                   (set msg
                                                        (string.format "%s[%s]"
                                                                       msg
                                                                       diagnostic.code)))
                                                 (.. msg " "))}
                        :float {:source :if_many
                                :prefix (fn [diagnostic]
                                          (local level
                                                 (. vim.diagnostic.severity
                                                    diagnostic.severity))
                                          (local prefix
                                                 (string.format " %s "
                                                                diagnostic_icons.level))
                                          (values prefix
                                                  (.. :Diagnostic
                                                      (string.gsub level "^%l"
                                                                   string.upper))))}
                        :signs false})
