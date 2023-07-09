{
  pkgs,
  ...
} : {
  config.programs.git = {
      enable = true;
      userName = "Mikilio";
      userEmail = "official.mikilio+dev@gmail.com";
      delta.enable = true;
      signing = {
        signByDefault = true;
        key = "962C29E85C5026E104466143BA6CE4D7F95B81A9";
      };
  };
}
