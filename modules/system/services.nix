{
  pkgs,
  ...
}:
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  services.httpd = {
    enable = true;
    enablePHP = true;
    adminAddr = "admin@localhost";

    virtualHosts."localhost" = {
      documentRoot = "/var/www/html";

      locations."/adminer/index.php" = {
        alias = "${pkgs.adminer}/adminer.php";
      };
    };

    extraConfig = ''
      <Directory "/var/www/html">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require ip 127.0.0.1 ::1
      </Directory>
    '';
  };
}
