{
  description = "Logout dialog w/ desktop entry";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    rofi = "${pkgs.rofi}/bin/rofi";
    logout = pkgs.writeShellScript "logout" ''
      options=(
        "🪵 Logout"
        "🔒 Lock"
        "🌙 Suspend"
        "🧸 Hibernate"
        "🐤 Restart"
        "🪓 Shutdown"
      )

      choice=$(\
        printf '%s\n' "''${options[@]}" | \
        ${rofi} \
          -dmenu \
          -theme-str 'entry { placeholder: "Logout"; }' \
          -i \
      )

      choiceText="''${choice:2}"

      case "$choiceText" in
        Logout)    loginctl terminate-user $USER;;
        Lock)      swaylock;;
        Suspend)   systemctl suspend;;
        Hibernate) systemctl hibernate;;
        Restart)   systemctl reboot;;
        Shutdown)  systemctl poweroff;;
      esac
    '';
  in {
    packages.x86_64-linux.logout = pkgs.runCommand "logout" {} ''
      mkdir -p $out/bin
      ln -s ${logout} $out/bin/logout

      mkdir -p $out/share/applications
      tee $out/share/applications/logout.desktop << EOF
      [Desktop Entry]
      Version=1.0
      Name=Logout
      GenericName=Logout options
      Terminal=false
      Type=Application
      Exec=$out/bin/logout
      EOF
    '';

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.logout;
  };
}
