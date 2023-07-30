#!/bin/sh

current=$(sudo sops -d --extract '["u2f_mappings"]' $PRJ_ROOT/secrets/groups/homestation.yaml)

if [ "$current" == "null" ]; then
  pamu2fcfg -u $USER -N | \
  xargs -0 -I {} echo -E "sudo sops --set '[\"u2f_mappings\"] \"{}\"' $PRJ_ROOT/secrets/groups/homestation.yaml" | \
  xargs -0 -I {} sh -c {}
elif grep -q "^$USER" <<< $current; then
  new=$(pamu2fcfg -n -N)
  echo $current | sed "s|$USER:.*|&$new|" | sed 's/$/\\n/' | tr -d '\n' | \
  xargs -0 -I {} echo -E "sudo sops --set '[\"u2f_mappings\"] \"{}\"' $PRJ_ROOT/secrets/groups/homestation.yaml" | \
  xargs -0 -I {} sh -c {}
else
  echo -e "$current\n$(pamu2fcfg -u $USER -N)" | sed 's/$/\\n/' | tr -d '\n' | \
  xargs -0 -I {} echo -E "sudo sops --set '[\"u2f_mappings\"] \"{}\"' $PRJ_ROOT/secrets/groups/homestation.yaml" | \
  xargs -0 -I {} sh -c {}
fi
