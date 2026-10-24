# Beeper Desktop Flake

> [!WARNING]
> I don't really use Beeper anymore, so if something breaks I probably won't fix it. PRs are very much welcome

## Packages

```nix
beeper.packages.x86_64-linux.default        # Same as stable
beeper.packages.x86_64-linux.beeper.stable  # The Normal Client
beeper.packages.x86_64-linux.beeper.nightly # The Nightly Client
beeper.packages.x86_64-linux.beeper.beta    # Also The Nightly Client?
```

### Regarding Beta

I get this error when running the beta build. If anyone wants to fix this, feel free cause I probably won't

```stdout
Error: /nix/store/pviwkc46bz31drcy0f99c5zh5a1dnagh-beeper-0.90.1130.90.113-ab95d01-extracted/resources/app/node_modules/keytar/build/Release/keytar.node: invalid ELF header
    at process.func [as dlopen] (node:electron/js2c/node_init:2:2214)
    at Module._extensions..node (node:internal/modules/cjs/loader:1470:18)
    at Object.func [as .node] (node:electron/js2c/node_init:2:2214)
    at Module.load (node:internal/modules/cjs/loader:1215:32)
    at Module._load (node:internal/modules/cjs/loader:1031:12)
    at c._load (node:electron/js2c/node_init:2:13801)
    at Module.require (node:internal/modules/cjs/loader:1240:19)
    at require (/nix/store/pviwkc46bz31drcy0f99c5zh5a1dnagh-beeper-0.90.1130.90.113-ab95d01-extracted/resources/app/build/main/223.js:2:624840)
    at 895 (/nix/store/pviwkc46bz31drcy0f99c5zh5a1dnagh-beeper-0.90.1130.90.113-ab95d01-extracted/resources/app/node_modules/keytar/index.js:1:100)
    at __nccwpck_require__ (/nix/store/pviwkc46bz31drcy0f99c5zh5a1dnagh-beeper-0.90.1130.90.113-ab95d01-extracted/resources/app/node_modules/keytar/index.js:1:919)
    ```

### Regarding Darwin

I have no clue how to build stuff for Darwin, and I don't really wanna spend a bunch of money on a mac just to find out how. If you know how and want to contribute, be my guest

## Structure

- [`update.nu`](./update.nu) - Script used to update info
- [`manifest.toml`](./manifest.toml) - Holds info about packages
- [`default.nix`](./default.nix) - Builds all of the packages
