{ ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    configure = {
      customRC = ''
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smartindent
        set rnu
        let g:transparent_enabled = v:true
      '';
    };
  };
}
