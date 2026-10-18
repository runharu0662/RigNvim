# 開発・検証

リポジトリのルートで実行してください。

## 検証手順

`tests/development.lua` は導入済みプラグインを読み、サーバー・parser の存在、基本のマッピングと標準移動キー、コードアクション・診断操作、整形先の選択、Markdown 保存時の保護を確認します。
ネットワークでプラグインを取得するテストではありません。Go が導入されている場合は、一時ファイルで実際の none-ls 経由の Go 整形も確認します。
このテストでは、外部 LSP との実通信、実プロジェクトでの ESLint / Prettier、日本語変換は確認しません。

```sh
RIGNVIM_PROFILE=standard \
NVIM_APPNAME=nvim-web-test \
XDG_DATA_HOME=/tmp/nvim-web-test/data \
XDG_STATE_HOME=/tmp/nvim-web-test/state \
XDG_CACHE_HOME=/tmp/nvim-web-test/cache \
NVIM_LOG_FILE=/tmp/nvim-web-test.log \
NVIM_TEST_PLUGINS="$HOME/.local/share/RigNvim/lazy" \
nvim --headless --noplugin -u NONE -i NONE \
  '+lua local ok, err = pcall(dofile, "tests/development.lua"); if not ok then print(err); vim.cmd("cquit 1") end' +qa
```

