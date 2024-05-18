{ config, lib, ... }: let
  acmeDirectory = config.security.acme.certs."lineaire.moe".directory;
in
  {
  services.nginx.virtualHosts."lineaire.moe" = {
    http2 = false;
    enableACME = true;
    forceSSL = true;
  };
  security.acme.certs."lineaire.moe" = {
    email = "lineaire-moe@lahfa.xyz";
  };
  systemd.services.ergochat.serviceConfig.ReadOnlyPaths = [
    acmeDirectory
  ];

  systemd.services.ergochat.serviceConfig.SupplementaryGroups = [ "nginx" ];

  services.ergochat = {
    enable = true;
    settings = {
      network.name = "Lineaire";
      logging = [ {
        method = "stderr";
        level = "info";
        type = "* -userinput -useroutput";
      } ];
      server = {
        name = "lineaire.moe";
        listeners = lib.mkForce {
          "[::1]:6667" = { }; # (loopback ipv6, localhost-only)
          ":6697" = {
            tls = {
              cert = "${acmeDirectory}/fullchain.pem";
              key = "${acmeDirectory}/key.pem";
            };
            proxy = false;
            min-tls-version = "1.2";
          };
          ":6698" = {
            tls = {
              cert = "${acmeDirectory}/fullchain.pem";
              key = "${acmeDirectory}/key.pem";
            };
            min-tls-version = "1.2";
            proxy = true;
          };
        };
        casemapping = "precis";
        enforce-utf8 = true;
        lookup-hostnames = false; # true
        forward-confirm-hostnames = true;
        check-ident = false;
        motd = ./irc.lineaire.motd;
        relaymsg = {
          enable = true;
          separators = "/";
          available-to-chanops = true;
        };
        proxy-allowed-from = [ "localhost" "2001:bc8:38ee:99::1" ];
        ip-cloaking = {
          enabled = true;
          netname = "lineaire";
          cidr-len-ipv4 = 24;
          cidr-len-ipv6 = 32;
        };
        max-sendq = "1M";
        ip-limits = {
          count = false;
          throttle = false;
        };
      };
      oper-classes = {
        chat-moderator = {
          title = "Chat Moderator";
          capabilities = [
            "kill"
            "ban"
            "nofakelag"
            "relaymsg"
            "vhosts"
            "sajoin"
            "samode"
            "snomasks"
            "roleplay"
          ];
        };
        server-admin = {
          title = "Server Admin";
          extends = "chat-moderator";
          capabilities =
            [ "rehash" "accreg" "chanreg" "history" "defcon" "massmessage" ];
        };
      };
      opers = {
        raito = {
          class = "server-admin";
          hidden = false;
          whois-line = "wants a better governance for NixOS";
          certfp = "7778f2fb6162d029a69b634141e40a9711d8b11a23594c5c99e2089c1d663014";
          auto = true;
        };
      };
      languages = {
        enabled = false;
        default = "en";
        # TODO: add languages
      };
      datastore = {
        autoupgrade = true;
        path = "/var/lib/ergo/ircd.db";
      };
      accounts = {
        authentication-enabled = true;
        registration = {
          enabled = true;
          allow-before-connect = true;
          throttling = {
            enabled = true;
            duration = "10m";
            max-attempts = 30;
          };
          bcrypt-cost = 4;
          email-verification.enabled = false;
        };
        multiclient = {
          enabled = true;
          allowed-by-default = true;
          always-on = "opt-in";
          auto-away = "opt-out";
        };
      };
      channels = {
        default-modes = "+ntC";
        registration = { enabled = true; };
      };
      limits = {
        nicklen = 32;
        identlen = 20;
        channellen = 64;
        awaylen = 390;
        kicklen = 390;
        topiclen = 390;
        chan-list-modes = 60;
        whowas-entries = 100;
        monitor-entries = 100;

        multiline = {
          max-bytes = 4096;
          max-lines = 10;
        };
      };
      history = {
        enabled = true;
        channel-length = 2048;
        client-length = 256;
        autoresize-window = "3d";
        autoreplay-on-join = 0;
        chathistory-maxmessages = 1000;
        znc-maxmessages = 2048;
        restrictions = {
          expire-time = "1w";
          query-cutoff = "none";
          grace-period = "1h";
        };
        retention = {
          allow-individual-delete = true;
          enable-account-indexing = false;
        };
        tagmsg-storage = {
          default = false;
          whitelist = [ "+draft/react" "+react" ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 6697 6698 ];
}
