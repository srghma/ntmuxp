# ntmuxp

![alt text](https://raw.githubusercontent.com/srghma/ntmuxp/master/docs/screenshot.png)

Example usage

With `test.tmuxp.nix` (file that should compile to json using `--strict --eval yourfile.tmuxp.nix --json`)

```nix
let
  pkgs = import <nixpkgs> {};
in

with pkgs;

{
  session_name = "2-pane-synchronized";
  windows = [
    {
      window_name = "Two synchronized panes";
      panes = [
        "ssh server1"
        "ssh server2"
      ];

      options_after= {
        synchronize-panes = true;
      };
    }
  ];
}
```

```sh
ntmuxp load test.tmuxp.nix
```

will compile nix file to json, output it to /tmp/filenamePROCNUM-random.json, and run command `tmuxp load /tmp/filenamePROCNUM-random.json`
