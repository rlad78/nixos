{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtmp = {
        enable = false;
        package = with pkgs.stable; swtpm;
      };
    };
    spiceUSBRedirection.enable = true;
  };
  users.users.richard.extraGroups = [ "libvirtd" ];
  services.spice-vdagentd.enable = true;
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    winboat
  ];
}
