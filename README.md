# RigNvim: Go・Python・Rust・C/C++・Web・Cloud / IaC・日本語執筆用 Neovim

設定バージョン: **v0.1.1**（変更履歴は `CHANGELOG.md`）。

`web` は `simple` の日本語・Markdown 設定を基に、開発機能を追加し、重複する連携とUIを整理した構成です。
`full` は従来の全部入り構成、`cpp` は競技プログラミング構成です。

Neovim は編集・検索・LSP・整形・lint・Git 差分・記事執筆を担当します。
build / test / terraform plan・apply / AWS CLI / Docker / kubectl は WezTerm + Zsh で実行します。
ターミナル操作は WezTerm に集約しています。

## 言語と担当ツール

| 対象 | LSP / diagnostics | 整形 |
|---|---|---|
| Python | Pyright（型チェック basic）、Ruff（構文・lint） | Ruff LSP |
| Rust | rust-analyzer | rust-analyzer（rustfmt が必要） |
| C / C++ | clangd | clangd（clang-format） |
| Go / go.mod / go.sum / go.work | gopls | Go は goimports → gofmt → gopls の優先順、mod / sum は対応する LSP 機能のみ |
| TypeScript / JavaScript / TSX / JSX | ts_ls、ESLint LSP | Prettier、未導入なら対応する LSP |
| HTML / CSS | html / cssls | Prettier、未導入なら対応する LSP |
| JSON / JSONC | jsonls | Prettier、未導入なら jsonls |
| YAML | yamlls | Prettier、未導入なら対応する LSP |
| Terraform / tfvars | terraformls、tflint の言語サーバー | terraform fmt（バッファ内容を標準入力で整形）→ terraformls |
| HCL | Treesitter の構文ハイライト | 一般 HCL に Terraform 整形を強制しない |
| Dockerfile | dockerls | 対応する LSP |
| shell | bashls | shfmt、未導入なら対応する LSP |
| Markdown | Treesitter、日本語入力、記事用コマンド | 明示操作時のみ Prettier |
| 設定用 Lua | lua_ls | StyLua、未導入なら対応する LSP |

LSP はプロジェクト内の `node_modules/.bin` → Mason / PATH の実行ファイルを探します。
設定済みの LSP は `ensure_installed` に登録し、ファイルを開いて Mason 連携が読み込まれると未導入分を自動インストールします。導入完了後はファイルを開き直してください。
LSP の起動はこの構成で管理するため、Mason 側の `automatic_enable` は無効です。
Prettier はプロジェクトの実行ファイルと設定を優先します。
ESLint はプロジェクトの ESLint 設定に従って診断・コードアクションを提供し、整形役にはしません。
`eslint_d` や none-ls の ESLint ソースは重ねて登録していません。

対応言語のサーバー・整形ツールの優先順・Treesitter parser は `lua/config/languages.lua` にまとめています。
Python の仮想環境は有効化してから Neovim を起動するか、プロジェクトの Pyright 設定で指定してください。
Rust は Rust toolchain と rustfmt が必要です。C/C++ はプロジェクトの `compile_commands.json` があると include やコンパイルオプションを正しく解決できます。

## 診断の表示

構文・型・lint の診断は LSP が担当します。Treesitter はハイライト担当で、サーバー未導入では診断は出ません。
`:LanguageStatus`（`<leader>ci`）で現在の言語に対応するサーバーの `missing` / `installed, not attached` / `attached` を確認できます。
自動導入の進捗は `:Mason` で確認できます。導入完了後にファイルを開き直してください。失敗時は表示された `:LspInstall` で再試行できます。
LSP 子プロセスには英語のロケールを渡し、TypeScript の locale も `en` を指定しています。各ツールやルール独自のメッセージは翻訳しません。

- エラー・警告を重要度順に表示し、下線とアイコンで強調します。
- 診断表示は挿入モードを抜けたときに更新します（保存不要）。
- カーソル行の診断は行の下に全文表示し、行末への重複表示は無効にしています。`<leader>ud` で切り替えます。
- `<leader>cd` で診断元付きの詳細ウィンドウを開きます。
- `<leader>fd` で受信済みのワークスペース診断を検索、`<leader>cl` で現在のバッファの診断一覧を開きます。
- 標準の `]d` / `[d` で次／前の診断に移動できます。

## 開発ツールの導入

Treesitter は `main` の新 API を使うため、Neovim 0.12 以降と tree-sitter CLI 0.26.1 以降が必要です。macOS では dotfiles の Brewfile から導入します。初回起動時にパーサーを非同期で取得し、完了後にファイルを開き直すとハイライトとインデントが有効になります。

Neovim の組み込み LSP・snippet API を使います。アプリの実行・ビルド・テスト環境は Docker 側で管理します。
ホストには解析・ツール導入用の Go と Node.js/npm を dotfiles の Brewfile で導入します。LSP は Mason で管理し、Homebrew や npm のグローバルインストールでは重複導入しません。
`gopls` は導入時と解析時にホストの `go` を使い、Node 系 LSP は npm で導入し Node.js で動きます。`go version`・`node --version`・`npm --version` で確認してください。
Docker 内の依存や toolchain はホストの LSP から自動では参照されません。Go はプロジェクトの `go.mod` / `go.work` に従ってホストにもモジュール・ビルドキャッシュを作る場合があります。ホストと Docker の Go バージョンはプロジェクトに合わせて管理してください。Brewfile はバージョン固定ではありません。
formatter は必要に応じて `:Mason` から導入してください。

`lua/config/languages.lua` の `servers` を自動導入リストとして使います。`gopls`、Pyright、Ruff、ESLint、tflint など、設定済みの言語サーバーをまとめて導入します。失敗した場合は `:Mason` で原因を確認し、`:LspInstall gopls` などで再試行できます。Go・Node.js の導入だけでは Rust などの toolchain は揃いません。

formatter / lint は `:Mason` で `goimports`、`prettier`、`shfmt`、`stylua`、`tflint` を選べます。
`gofmt` は Go、`terraform` は Terraform CLI の導入で提供されます。
Web プロジェクトの Prettier / ESLint はプロジェクト側の devDependencies に置く運用を優先してください。
検索の `rg` / `fd` は Zsh の PATH に導入します。Mason の `ensure_installed` に設定しても汎用 CLI は導入されないため、その誤設定を除去しました。
`setup_apt.sh` は Ubuntu の基本導入用で、各言語の runtime は一括導入しません。

## キー操作と保存時の動作

`<leader>` は Space です。基本のマッピングは保持し、コードアクションは組み込み LSP に統一しています。

| 操作 | キー / コマンド |
|---|---|
| ファイルツリー | `<leader>e` |
| ファイル / 全文 / バッファ / ヘルプ検索 | `<leader>ff` / `fg` / `fb` / `fh` |
| 整形 | `<leader>n`（整形先を一つだけ選択） |
| rename / code action | `<leader>rn` / `ca` |
| カーソル行の診断 | `<leader>cd`（明示操作で表示） |
| definition / references | `gd` / `gr`（LSP 接続時、既存の割り当てがなければ追加） |
| Go / TS の import 整理 | `:OrganizeImports`（該当 LSP 接続時） |
| ESLint の修正 | `:LspEslintFixAll` または既存の code action |
| Git 差分の部分表示 / index と比較 | `<leader>gd` / `gl`（新規追加） |
| Copilot の切り替え | `<leader>lt` |
| FIFO inbox を開く | `<leader>i`（`:VimboxOpen`） |

[Vimbox](https://github.com/runharu0662/vimbox)は思いつきを順番に処理するinboxです。`:VimboxOpen`で入力欄を開き、Enterで追加、Tabで一覧へ移動します。一覧の`d`で先頭の項目を処理済みにします。データは`stdpath("data")/vimbox_queue.json`へ保存されます。

コード保存時は formatter を一つ選んで同期整形します。Go では goimports があれば import 整理も行います。
ESLint の fix-all は保存時に強制しません。
Markdown は保存時の自動整形を行わず、記事の改行・空白を保持します。
整形ツールがなくても保存はできます。明示的な整形操作で利用可能な整形先がない場合は通知します。

## 日本語入力

- skkeleton で日本語入力を使うには [Deno](https://deno.com/) が必要です。macOS では `brew install deno` でインストールし、`deno --version` で PATH から実行できることを確認します。
- `dictionaries/SKK-JISYO.L` を同梱しています。設定リポジトリをコピーすれば、環境ごとの辞書配置は不要です。
- 挿入・コマンドラインモードの `<C-j>` で skkeleton を切り替えます。
- 変換中は `<C-n>` / `<C-p>` で候補移動、`<C-y>` で確定、`<C-e>` でキャンセルします。
- 別の辞書を使う場合だけ、`init.lua` で `vim.g.skk_dictionary_path` を指定します。標準の辞書パスは設定ファイルの位置から解決するため、作業ディレクトリや `NVIM_APPNAME` に依存しません。
- 同梱版は公式配布の辞書のみです。個人の固有名詞・学習結果を含む辞書はリポジトリ外に保存し、Git に登録しません。
- Deno／denops の実行依存は別途必要です。初回の依存取得にはネットワーク接続が必要です。

Deno がない環境では skkeleton は読み込まれず、挿入・コマンドラインモードの `<C-j>` も設定されません。インストール後は Neovim を再起動し、`:Lazy` で skkeleton と denops.vim のインストール完了を確認してください。辞書がない場合は初回使用時に通知します。

## Markdown

- Markdown で skkeleton の日本語入力（`<C-j>`）を使う場合は、上記「日本語入力」の手順で Deno をインストールしてください。Markdown の編集自体に Deno は不要です。
- 画面幅で折り返します。自動折り返しでファイルに改行は挿入しません。
- `j` / `k` は表示行単位、回数指定時はファイルの行単位で移動します。
- Markdown では nvim-cmp と Copilot の自動補完を無効にしています。
- `<leader>pc` は `[[リンク]]` のファイル作成、`<leader>po` はリンクを開きます。
- `<leader>pi` の画像貼り付けには `pngpaste` と `vim.g.obsidian_vault_path` の設定が必要です。


## プラグインの整理

編集・検索・LSP・整形・Git・日本語入力を中心に構成しています。

| 対象 | 方針 | 理由 |
|---|---|---|
| none-ls.nvim | 維持 | formatter を明示登録し、保存時と手動操作で使う |
| mason-null-ls.nvim | 削除 | 自動導入・自動登録を使っていない。導入は `:Mason` で行う |
| fidget.nvim | 削除 | LSP 進捗表示は Noice に統一 |
| lspsaga.nvim | 削除 | コードアクションは組み込み LSP、診断は `<leader>cd` で表示 |
| toggleterm.nvim | 削除 | CLI 操作は WezTerm に集約。`tf` / `tv` / `th` は廃止 |
| nvim-cursorline | 削除 | 標準の `cursorline` で行を強調 |
| CopilotChat.nvim | 削除 | エディタ内チャットと関連キーを整理。Copilot の補完・切り替えは維持 |
| alpha-nvim、ascii.nvim、neoscroll.nvim | 維持 | 開始画面・ロゴ・スクロールの使い心地を維持 |
| hop.nvim | 維持 | `<leader>hw` / `hl` / `hc` / `hp` で明示的にジャンプ |
| indent-blankline.nvim | 維持 | YAML やコードのインデント構造を確認するため |

`f` / `F` / `t` / `T` は Neovim 標準の文字検索に戻しています。行頭・行末には `0` / `$` を使います。
診断の自動ポップアップを廃止し、診断アイコンは `vim.diagnostic.config` に統一しています。
lockfile は削除対象のみ除き、残すプラグインの commit は維持しています。

## 検証

`tests/development.lua` は導入済みプラグインを読み、サーバー・parser の存在、基本のマッピングと標準移動キー、コードアクション・診断操作、整形先の選択、Markdown 保存時の保護を確認します。
ネットワークでプラグインを取得するテストではありません。Go が導入されている場合は、一時ファイルで実際の none-ls 経由の Go 整形も確認します。
通常の init / lazy 起動も、外部取得と Denops worker、parser 導入を止めた環境で確認済みです。外部 LSP との実通信・ESLint / Prettier の実プロジェクト動作・日本語変換・画像貼り付けは未確認です。

```sh
NVIM_APPNAME=nvim-web-test \
XDG_DATA_HOME=/tmp/nvim-web-test/data \
XDG_STATE_HOME=/tmp/nvim-web-test/state \
XDG_CACHE_HOME=/tmp/nvim-web-test/cache \
NVIM_LOG_FILE=/tmp/nvim-web-test.log \
NVIM_TEST_PLUGINS="$HOME/.local/share/RigNvim/lazy" \
nvim --headless --noplugin -u NONE -i NONE \
  '+lua local ok, err = pcall(dofile, "tests/development.lua"); if not ok then print(err); vim.cmd("cquit 1") end' +qa
```

参考: [mason-lspconfig](https://github.com/mason-org/mason-lspconfig.nvim)、[none-ls](https://github.com/nvimtools/none-ls.nvim)、[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)、[skkeleton](https://github.com/vim-skk/skkeleton)。
