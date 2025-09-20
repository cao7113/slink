# Issues

## bcrypt_elixir

```
==> bcrypt_elixir
mkdir -p "/Users/rj/dev/elab/slink/_build/dev/lib/bcrypt_elixir/priv"
cc -g -O3 -Wall -Wno-format-truncation -I"/Users/rj/.asdf/installs/erlang/27.3.4/erts-15.2.7/include" -Ic_src -fPIC -shared -dynamiclib -undefined dynamic_lookup c_src/bcrypt_nif.c c_src/blowfish.c -o "/Users/rj/dev/elab/slink/_build/dev/lib/bcrypt_elixir/priv/bcrypt_nif.so"
You have not agreed to the Xcode license agreements. Please run 'sudo xcodebuild -license' from within a Terminal window to review and agree to the Xcode and Apple SDKs license.
make: *** [Makefile:33: _lib_name] Error 69
could not compile dependency :bcrypt_elixir, "mix compile" failed. Errors may have been logged above. You can recompile this dependency with "mix deps.compile bcrypt_elixir --force", update it with "mix deps.update bcrypt_elixir" or clean it with "mix deps.clean bcrypt_elixir"
==> slink
** (Mix) Could not compile with "make" (exit status: 2).
You need to have gcc and make installed. Try running the
commands "gcc --version" and / or "make --version". If these programs
are not installed, you will be prompted to install them.
```

新更新Mac系统后遇到，解决办法：

打开Xcode，同意相关软件安装即可，不用等Xcode更新完！
