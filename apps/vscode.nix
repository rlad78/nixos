{ config, pkgs, machine, nix-vscode-extensions, ... }:
let
  extensions = nix-vscode-extensions.extensions.${machine.system};
in
{
  users.users.richard.packages = with pkgs; [
    # vscode
    (vscode-with-extensions.override {
      vscodeExtensions = with extensions.vscode-marketplace; [
        ms-python.python
        aaron-bond.better-comments
        codezombiech.gitignore
        mathematic.vscode-pdf
        mechatroner.rainbow-csv
        ms-python.black-formatter
        ms-python.isort
        ms-python.vscode-pylance
        njpwerner.autodocstring
        piotrpalarz.vscode-gitignore-generator
        tamasfe.even-better-toml
        teabyii.ayu
      ];
    })
  ];
}
