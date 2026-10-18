# RigNvim

Go・Python・Rust・C/C++・Web・Terraform の開発と、日本語・Markdown の執筆用 Neovim 設定です。

## 導入

### 必要なもの

- Neovim 0.12 以降
- Git、tree-sitter CLI 0.26.1 以降、C コンパイラ（パーサーのビルド用）
- ripgrep（全文検索）、fd（ファイル検索）
- Nerd Font（ターミナルのフォントに設定）
- Node.js / npm、Go（言語サーバーの導入・実行用）
- Deno（日本語入力を使う場合）
- 初回のプラグイン・パーサー・言語サーバー取得用のネットワーク接続

macOS では Homebrew と Command Line Tools を用意し、必要なツールを導入します。

```sh
xcode-select --install
brew install neovim tree-sitter-cli ripgrep fd node go deno
brew install --cask font-hack-nerd-font
```

Command Line Tools が未導入の場合は、インストール完了後に次へ進んでください。
[dotfiles](https://github.com/runharu0662/dotfiles) の `install.sh` から導入した場合は、設定の配置と上記ツールの導入は済んでいます。

### 設定を配置する

単体で導入する場合は、設定を `~/.config/RigNvim` に配置します。既存の同名ディレクトリがある場合は先に退避してください。

```sh
git clone --branch web https://github.com/runharu0662/RigNvim.git ~/.config/RigNvim
NVIM_APPNAME=RigNvim nvim
```

普段の `nvim` でも使うには、シェル設定（Zsh は `~/.zshrc`、Bash は `~/.bashrc`）に次を追加して、ターミナルを開き直します。dotfiles から導入した場合は設定済みです。

```sh
export NVIM_APPNAME=RigNvim
```

### 初回起動

1. `:Lazy` でプラグインのインストール完了を確認します。
2. パーサーの取得が完了したら、ファイルを開き直します。
3. コードファイルを開くと、設定済みの言語サーバーの未導入分が自動インストールされます。`:Mason` で進捗を確認し、完了後にファイルを開き直します。
4. Copilot を使う場合は `:Copilot auth` で認証し、`:Copilot status` で確認します。

### 整形・言語ツールを追加する

必要に応じて `:Mason` から `goimports`、`prettier`、`shfmt`、`stylua` などを導入します。`gofmt` は Go、`terraform fmt` は Terraform CLI に含まれます。
Web プロジェクトの Prettier / ESLint は、そのプロジェクトの devDependencies に追加してください。

Python の仮想環境は有効化してから Neovim を起動するか、プロジェクトの Pyright 設定で指定します。
Rust は Rust toolchain と rustfmt が必要です。C/C++ は `compile_commands.json` を用意すると include やコンパイルオプションを解決できます。
Docker 内の依存はホストの LSP から自動では参照されません。Go などのバージョンはプロジェクトの環境に合わせてください。

## 基本の使い方

プロジェクトのディレクトリで `nvim` を起動します。

```sh
cd /path/to/project
nvim
```

Space → f → f でファイル検索、Space → f → g で全文検索、Space → e でファイルツリーを開きます。
保存は Space → w、手動整形は Space → n です。ビルド・テストなどのコマンドはターミナルから実行します。

コードは保存時に利用可能な整形ツールで整形されます。Go は goimports があれば import 整理も行います。
Markdown は保存時の自動整形を行いません。整形したいときに Space → n を使います。
ESLint の一括修正は `:LspEslintFixAll` またはコードアクションから実行します。

## 対応言語とツール

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

## インデント

このリポジトリにも `.editorconfig` を配置しています。基本は2スペース、Python・Rustは4スペース、Go・Makefileはタブです。Luaは既存の `.stylua.toml` に合わせてタブ（表示幅4）を指定しています。

入力時のインデントはプロジェクトの `.editorconfig` を優先します。指定がない場合は Web 系・Markdown・Terraform/HCL はスペース2つ、Go・Make はタブ、それ以外はスペース4つです。
`.prettierrc` や `.stylua.toml` だけでは入力時の幅は連動しないため、入力と整形を揃えるには `.editorconfig` にも同じインデント規則を指定してください。変更後はファイルを開き直すと反映されます。

プロジェクトのルート（`package.json` などと同じ場所）に `.editorconfig` を作成します。以下は基本を2スペース、Python・Rustを4スペース、Go・Makefileをタブにする例です。既存の設定がある場合は、そのプロジェクトの規則に合わせてください。

```ini
root = true

[*]
indent_style = space
indent_size = 2

[*.py]
indent_size = 4

[*.rs]
indent_size = 4

[*.go]
indent_style = tab
indent_size = tab
tab_width = 4

[Makefile]
indent_style = tab
indent_size = tab
tab_width = 4
```

Prettier を使う場合は、`.prettierrc` のインデント設定も揃えます。

```json
{
  "tabWidth": 2,
  "useTabs": false
}
```

## カスタムキーマップ

`<leader>` は Space、`<C-x>` は Ctrl + x です。たとえば `<leader>ff` は Space → f → f の順に押します。
以下はこの構成で追加・変更しているキーマップです。モードの指定がないものはノーマルモードで使います。

### ファイル・ウィンドウ・検索

| キー | 操作 |
|---|---|
| `<leader>w` | 保存（ノーマル・ビジュアル） |
| `<leader>q` | 現在のウィンドウを閉じる（ノーマル・ビジュアル） |
| `<leader>Q` | 全バッファを保存して終了（ノーマル・ビジュアル） |
| `<leader>v` | 右側に縦分割 |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | 左 / 下 / 上 / 右のウィンドウへ移動 |
| `<leader>bc` | 現在のバッファを閉じる |
| `<leader>e` | Neo-tree の表示を切り替える |
| `l` / `h` | Neo-tree 内でファイル・ノードを開く / ノードを閉じる |
| `<leader>ff` | ファイル検索 |
| `<leader>fg` | プロジェクト内の全文検索 |
| `<leader>fb` | バッファ検索 |
| `<leader>fh` | ヘルプ検索 |
| `<leader>fn` | 通知履歴を検索 |
| `<leader>,` | スタート画面を開く |
| `<leader>?` | 現在のバッファのローカルキーマップを表示 |
| `<leader>i` | FIFO inbox を開く（`:VimboxOpen`） |

### コード・診断・Git・ジャンプ

| キー | 操作 |
|---|---|
| `<leader>n` | 手動整形（整形先を一つ選択。Markdown も対象） |
| `<leader>rn` | LSP でシンボル名を変更 |
| `<leader>ca` | LSP のコードアクション |
| `gd` / `gr` | 定義 / 参照へ移動（LSP 接続時、既存の割り当てがなければ追加） |
| `<leader>cd` | カーソル行の診断をポップアップ表示 |
| `<leader>fd` | ワークスペースの診断を検索 |
| `<leader>cl` | 現在のバッファの診断一覧を開く |
| `<leader>ud` | カーソル行の下の診断詳細表示を切り替える |
| `<leader>ci` | 言語サーバーの導入・接続状況を表示 |
| `<leader>gd` | カーソル位置の Git 差分を部分表示 |
| `<leader>gl` | 現在のバッファと Git index を比較 |
| `<leader>hw` | 単語へ Hop ジャンプ |
| `<leader>hl` | 行へ Hop ジャンプ |
| `<leader>hc` | 1文字を指定して Hop ジャンプ |
| `<leader>hp` | パターンを指定して Hop ジャンプ |

Go / TS の import 整理は `:OrganizeImports`（該当 LSP 接続時）、ESLint の一括修正は `:LspEslintFixAll` またはコードアクションから実行できます。

### 補完・Copilot・日本語入力

| キー | モード・条件 | 操作 |
|---|---|---|
| `<C-p>` / `<C-n>` | 挿入・補完メニュー表示中 | 前 / 次の補完候補 |
| `<CR>` | 挿入・補完メニュー表示中 | 選択済みの候補を確定 |
| `<Tab>` | 挿入・補完メニュー表示中 | 候補を確定（未選択なら先頭候補） |
| `<leader>lt` | ノーマル | Copilot の有効・無効を切り替える |
| `<C-l>` | 挿入・Copilot 提案表示中 | 提案全体を採用 |
| `<C-;>` | 挿入・Copilot 提案表示中 | 提案を単語単位で採用 |
| `<C-'>` | 挿入・Copilot 提案表示中 | 提案を行単位で採用 |
| `<C-x>` | 挿入・Copilot 提案表示中 | 提案を閉じる |
| `<C-j>` | 挿入・コマンドライン（skkeleton 導入時） | 日本語入力を切り替える |
| `<C-n>` / `<C-p>` | skkeleton 変換中 | 次 / 前の変換候補 |
| `<C-y>` / `<C-e>` | skkeleton 変換中 | 確定 / キャンセル |

nvim-cmp は Markdown と skkeleton の日本語入力中には無効です。

### Markdown・スタート画面

| キー | 条件 | 操作 |
|---|---|---|
| `<leader>pc` | カーソルが `[[リンク]]` 上 | 同じディレクトリに `.md` を新規作成して開く |
| `<leader>po` | カーソルが `[[リンク]]` 上 | 同じディレクトリの既存 `.md` を開く |
| `<leader>pi` | `pngpaste` と Vault の設定が必要 | クリップボード画像を保存し、Markdown リンクを挿入 |
| `j` / `k` | Markdown・ノーマル / ビジュアル | 表示行で上下移動（回数指定時はファイルの行単位） |
| `f` / `i` / `t` / `r` | スタート画面 | ファイル検索 / 新規ファイル / 日付付き一時ファイル / 最近のファイル |
| `g` / `l` / `h` / `q` | スタート画面 | 全文検索 / Lazy / ヘルスチェック / 終了 |
| `s` | スタート画面 | RigNvim の GitHub リポジトリを既定のブラウザで開く |

## 日本語入力

Deno を導入して Neovim を再起動すると、挿入・コマンドラインモードの `<C-j>` で skkeleton を切り替えられます。
変換中は `<C-n>` / `<C-p>` で候補移動、`<C-y>` で確定、`<C-e>` でキャンセルします。SKK 辞書は同梱されています。

別の辞書を使う場合は `init.lua` に指定します。

```lua
vim.g.skk_dictionary_path = vim.fn.expand("~/path/to/SKK-JISYO.L")
```

## Markdown・画像貼り付け

Markdown は画面幅で折り返して表示します。表示の折り返しでファイルに改行は挿入されません。
nvim-cmp は無効、Copilot の提案は有効です。Copilot は `<leader>lt` で切り替えられます。
`[[リンク]]` 上で `<leader>pc` を押すと同じディレクトリに `.md` を作成し、`<leader>po` で既存のファイルを開けます。

画像貼り付けは macOS の `pngpaste` を使います。

```sh
brew install pngpaste
```

`init.lua` の保存先を自分の Vault に変更してください。

```lua
vim.g.obsidian_vault_path = vim.fn.expand("~/Documents/MyVault")
```

画像をクリップボードへコピーして `<leader>pi` を押すと、Vault の `screen_shots/` に保存し、現在行の次に Markdown の画像リンクを挿入します。

## Inbox

`<leader>i` で [Vimbox](https://github.com/runharu0662/vimbox) を開きます。入力欄で Enter を押して項目を追加し、Tab で一覧へ移動します。
一覧の `d` で先頭の項目を処理済みにします。

## 困ったとき

| 症状 | 確認・操作 |
|---|---|
| ハイライトやインデントが効かない | `tree-sitter --version` を確認し、パーサー取得後にファイルを開き直す |
| 補完・診断が出ない | `<leader>ci`（`:LanguageStatus`）で `missing` / `installed, not attached` / `attached` を確認する |
| 言語サーバーの導入に失敗する | `:Mason` でエラーを確認し、`:LspInstall gopls` などで再試行する |
| 整形できない | `:Mason` とプロジェクトの整形ツール導入状況を確認し、`<leader>n` を実行する |
| 日本語入力を切り替えられない | `deno --version` と `:Lazy` の skkeleton / denops.vim を確認し、再起動する |
| アイコンが崩れる | ターミナルのフォントを Nerd Font に設定する |
| 起動時にエラーが出る | `:messages` と `:checkhealth` を確認する |

診断は `]d` / `[d` で移動し、`<leader>cd` で詳細を表示できます。`<leader>fd` はワークスペース、`<leader>cl` は現在のバッファの診断一覧です。

## 更新

設定ディレクトリで実行します。ローカル変更がある場合は先にコミットまたは退避してください。

```sh
cd ~/.config/RigNvim
git pull --ff-only
```

Neovim を再起動し、`:Lazy sync` でプラグインを更新します。dotfiles から導入した場合は、dotfiles 側の更新手順を使ってください。

変更履歴は [CHANGELOG.md](CHANGELOG.md)、開発者向けの検証手順は [docs/development.md](docs/development.md) を参照してください。
