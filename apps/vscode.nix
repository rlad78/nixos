{ config, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    vscode
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
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
