{ config, ... }:
{
  programs.zen-browser.profiles.default.settings = {
    pinsForce = true;
    pinsForceAction = "demote";
    pins =
      let
        containers = config.programs.zen-browser.profiles."default".containers;
        spaces = config.programs.zen-browser.profiles."default".spaces;
      in
      {
        # Essentials
        "Tasks" = {
          id = "c49882ec-97d5-4efd-862e-dd57d35c0ba6";
          url = "https://ticktick.com/webapp/#q/today/tasks";
          position = 101;
          isEssential = true;
          container = containers.Personal.id;
        };
        "WhatsApp" = {
          id = "60bf7c20-bf2c-4e23-8e97-56adf603b83e";
          url = "https://web.whatsapp.com";
          position = 102;
          isEssential = true;
          container = containers.Personal.id;
        };
        "Linkwarden" = {
          id = "8dce7866-aa57-4c74-91bc-f29e8122f4fe";
          url = "http://amphora:3000";
          position = 103;
          isEssential = true;
          container = containers.Personal.id;
        };
        "Excalidraw" = {
          id = "acc6f6c0-fa29-4475-b728-7334c20d7311";
          url = "https://excalidraw.com";
          position = 104;
          isEssential = true;
        };

        # Pins
        "Roadmap" = {
          id = "f3af5c62-68d4-4a72-96c1-4124ce5c5f5c";
          url = "https://roadmap.sh";
          title = "Roadmap";
          editedTitle = true;
          position = 201;
          container = containers.Personal.id;
          workspace = spaces.Study.id;
        };
        "Boot.dev" = {
          id = "d5957941-4055-43a1-9a2f-2f7283a66f3a";
          url = "https://boot.dev";
          title = "Roadmap";
          editedTitle = true;
          position = 202;
          container = containers.Personal.id;
          workspace = spaces.Study.id;
        };
        "Classroom" = {
          id = "0b0792f7-a571-4764-b8fc-59bfb3b3ba21";
          url = "https://classroom.google.com";
          title = "Classroom";
          editedTitle = true;
          position = 401;
          container = containers.Personal.id;
          workspace = spaces.School.id;
        };
        "NotebookLM" = {
          id = "552eb24a-488f-4646-ac09-0d1b6683fdb9";
          url = "https://notebooklm.google.com";
          title = "NotebookLM";
          editedTitle = true;
          position = 402;
          container = containers.Personal.id;
          workspace = spaces.School.id;
        };
      };
  };
}
