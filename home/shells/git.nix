{
  pkgs,
  ...
} : {
  config.programs.git = {
      enable = true;
      userName = "Mikilio";
      userEmail = "official.mikilio+dev@gmail.com";
      delta.enable = true;
      /* signing = { */
      /*   signByDefault = true; */
      /* }; */
  };
}
