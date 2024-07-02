# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "MASA_ROG_NIX_OS_VM";
  networking.networkmanager.enable = true;

  time.timezone = "america/los_angeles";

  # select internationalisation properties.
  i18n.defaultlocale = "en_us.utf-8";

  i18n.extralocalesettings = {
    lc_address = "en_us.utf-8";
    lc_identification = "en_us.utf-8";
    lc_measurement = "en_us.utf-8";
    lc_monetary = "en_us.utf-8";
    lc_name = "en_us.utf-8";
    lc_numeric = "en_us.utf-8";
    lc_paper = "en_us.utf-8";
    lc_telephone = "en_us.utf-8";
    lc_time = "en_us.utf-8";
  };

  # configure keymap in x11
  services.xserver = {
    layout = "us";
    xkbvariant = "";
  };

  # allow unfree packages
  nixpkgs.config.allowunfree = true;

  # list packages installed in system profile. to search, run:
  # $ nix search wget
  environment.systempackages = with pkgs; [
  #  vim # do not forget to add an editor to edit configuration.nix! the nano editor is also installed by default.
     wget
     neovim
     git
     libgcc
     libgccjit
     python3
     rustup
     go
     gopls
     golines
     stylua
  ];

  # some programs need suid wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enablesshsupport = true;
  };

  # list services that you want to enable:

  # open ports in the firewall.
  # networking.firewall.allowedtcpports = [ ... ];
  # networking.firewall.allowedudpports = [ ... ];
  # or disable the firewall altogether.
  # networking.firewall.enable = false;

  # this value determines the nixos release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. it‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  users.users = {
    masa = {
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "~/.ssh/id_ed25519.pub"
      ];
      extraGroups = ["wheel" "networkmanager"];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
