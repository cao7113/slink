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

- https://github.com/crbelaus/bun/issues/43
- https://github.com/tailwindlabs/tailwindcss-intellisense?tab=readme-ov-file#troubleshooting
- https://github.com/tailwindlabs/tailwindcss/issues/17794

原因： phoenix项目使用tailwindcss cli进行安装，不依赖nodejs和npm等，但
https://github.com/tailwindlabs/tailwindcss-intellisense 项目是个js项目，运行依赖本地的js环境，所以解析时就出错了

解决办法：
在assets/目录下使用 bun add tailwindcss@v4.1.3(要保持和phoenix项目中使用了相同的版本)，这样 tailwindcss-intellisense 插件就能找到相关的依赖和插件了
目前可正常使用,保持关注！

Todo：
更好的方法是引导插件使用phoenix使用的命令行版本的tailwindcss，似乎不容易办到

统一使用 bun 管理 css 和 js

## bun deploy

search  assets.deploy TypeError: familySync is not a function const { MUSL, familySync } = require('detect-libc') process.platform === 'linux'


项目地址
https://github.com/cao7113/slink
错误 github actions
https://github.com/cao7113/slink/actions/runs/26945027930/job/79495738993


```
#25 [builder 15/18] RUN mix assets.deploy
#25 1.130 1 | let parts = [process.platform, process.arch];
#25 1.130 2 | if (process.platform === 'linux') {
#25 1.130 3 |   const { MUSL, familySync } = require('detect-libc');
#25 1.130 4 |   const family = familySync();
#25 1.130                      ^
#25 1.130 TypeError: familySync is not a function. (In 'familySync()', 'familySync' is undefined)
#25 1.130       at <anonymous> (/app/assets/node_modules/lightningcss/node/index.js:4:18)
#25 1.130 
#25 1.130 Bun v1.3.14 (Linux x64)
#25 1.148 ** (Mix) `mix bun css --minify` exited with 1
#25 ERROR: process "/bin/sh -c mix assets.deploy" did not complete successfully: exit code: 1
------
 > [builder 15/18] RUN mix assets.deploy:
1.130 1 | let parts = [process.platform, process.arch];
1.130 2 | if (process.platform === 'linux') {
1.130 3 |   const { MUSL, familySync } = require('detect-libc');
1.130 4 |   const family = familySync();
1.130                      ^
1.130 TypeError: familySync is not a function. (In 'familySync()', 'familySync' is undefined)
1.130       at <anonymous> (/app/assets/node_modules/lightningcss/node/index.js:4:18)
1.130 
1.130 Bun v1.3.14 (Linux x64)
1.148 ** (Mix) `mix bun css --minify` exited with 1
------
```

后来如何解决的呢？？？

删掉assets/bun.lock 后重新 install就好了。。。。