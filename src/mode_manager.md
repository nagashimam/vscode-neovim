<!-- markdownlint-disable-file MD030 -->

# mode_manager.md(優先度 2)

## neovim

import しているが、使用されていない

## vscode

### [commands](https://code.visualstudio.com/api/references/vscode-api#commands)

-   `commands.executeCommand("setContext", "neovim.recording", false)`

setContext で VSCode の拡張機能が使うオプション値の設定を行っている。第 2 引数がオプション名、第 3 引数がオプションの設
定値。69 行目、79 行目も同様。

-   `commands.executeCommand("vscode-neovim.escape")`

vscode-neovim.escape というコマンドを実行している。処理の中身は`src/typing_manager.ts`で定義されているので、そちらに記載
