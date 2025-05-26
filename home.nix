{ config, pkgs, ... }:
{
  home.username = "richard";
  home.homeDirectory = "/home/richard";

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    clearDefaultKeybinds = true;
    settings = {
      background-opacity = 0.9;
      keybind = [
        "super+enter=new_split:right"
        "super+ctrl+enter=new_split:left"
        "super+shift+enter=new_split:down"
        "super+ctrl+shift+enter=new_split:up"

        "super+right_bracket=goto_split:next"
        "super+left_bracket=goto_split:previous"
        # "super+k=goto_split:up"
        # "super+j=goto_split:down"
        # "super+h=goto_split:left"
        # "super+l=goto_split:right"

        "super+shift+k=resize_split:up,10"
        "super+shift+j=resize_split:down,10"
        "super+shift+h=resize_split:left,10"
        "super+shift+l=resize_split:right,10"
        "super+shift+e=equalize_splits"
        "super+alt+enter=toggle_split_zoom"

        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_tab"
        "ctrl+shift+right=next_tab"
        "ctrl+shift+left=previous_tab"
        "ctrl+shift+tab=previous_tab"
        "ctrl+shift+n=new_window"
        "ctrl+shift+f=toggle_fullscreen"
        "ctrl+shift+d=toggle_window_decorations"

        "super+r=reset"
        
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+a=select_all"
        "shift+up=adjust_selection:up"
        "shift+down=adjust_selection:down"
        "shift+right=adjust_selection:right"
        "shift+left=adjust_selection:left"
        "shift+home=scroll_to_top"
        "shift+end=scroll_to_bottom"
        "shift+insert=paste_from_selection"
        "shift+page_up=scroll_page_up"
        "shift+page_down=scroll_page_down"

        "ctrl+minus=decrease_font_size:1" 
        "ctrl+equal=increase_font_size:1"
        "ctrl+zero=reset_font_size"
      ];
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
