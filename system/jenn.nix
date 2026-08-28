{ pkgs, ... }:
{
  users.mutableUsers = false;

  users.users.jenn = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Jennifer Dean";
    hashedPassword = "$y$j9T$FzwI/9azYTGWGbnqdj1C51$vu6Ldwo1ymn7HQiPw6MV/lQubbt8nRJ7gSXM/LEn0w3";
  };
}
