# Assets and UI

## Tech

- ≈ tailwindcss v4.x
- 🌼 daisyUI 5.x

## Asset management

- https://hexdocs.pm/phoenix/asset_management.html

## Use bun as asset management tool

- https://github.com/crbelaus/bun
- https://hexdocs.pm/bun/Bun.html
- https://hex.pm/packages/bun

## Tailwind

- https://github.com/phoenixframework/tailwind
- https://github.com/tailwindlabs/tailwindcss
- https://github.com/tailwindlabs/tailwindcss/blob/main/CHANGELOG.md
- https://tailwindcss.com/docs/adding-custom-styles

- https://zed.dev/docs/languages/tailwindcss
- https://tailwindcss.com/docs/editor-setup#zed
- https://daisyui.com/docs/editor/cursor/

## Topbar

- https://github.com/buunguyen/topbar

## Fix Tailwind CSS IntelliSense not works in *.html.heex and *_web/live/xxx_live/index.ex files

Debug by command: Tailwind CSS: Show Output (the language server output by running the Tailwind CSS: Show Output command from the command palette.)

```
Error: The plugin "../vendor/daisyui" does not accept options
Unable to load plugin: ../vendor/heroicons Error: Can't resolve 'tailwindcss/plugin'
```

- https://github.com/tailwindlabs/tailwindcss-intellisense?tab=readme-ov-file#troubleshooting
- https://github.com/tailwindlabs/tailwindcss/issues/17794

原因： phoenix项目使用tailwindcss cli进行安装，不依赖nodejs和npm等，但
https://github.com/tailwindlabs/tailwindcss-intellisense 项目是个js项目，运行依赖本地的js环境，所以解析时就出错了

解决办法：
在assets/目录下使用 bun add tailwindcss@v4.1.3(要保持和phoenix项目中使用了相同的版本)，这样 tailwindcss-intellisense 插件就能找到相关的依赖和插件了
目前可正常使用,保持关注！

Todo：
更好的方法是引导插件使用phoenix使用的命令行版本的tailwindcss，似乎不容易办到

## bun deploy

```
 > [builder 15/18] RUN mix assets.deploy:
1.381 1 | let parts = [process.platform, process.arch];
1.381 2 | if (process.platform === 'linux') {
1.381 3 |   const { MUSL, familySync } = require('detect-libc');
1.381 4 |   const family = familySync();
1.381                      ^
1.381 TypeError: familySync is not a function. (In 'familySync()', 'familySync' is undefined)
1.381       at /app/assets/node_modules/lightningcss/node/index.js:4:18
1.381       at unknown:11:43
1.381       at spawnSync (unknown:1:1)
1.381       at spawnSync (node:child_process:226:22)
1.381       at /app/assets/node_modules/detect-libc/lib/detect-libc.js:55:7
1.381       at anonymous (unknown:1:1)
1.381       at /app/assets/node_modules/@parcel/watcher/index.js:5:11
1.381       at unknown:11:43
1.381
1.381 Bun v1.2.22 (Linux x64)
```