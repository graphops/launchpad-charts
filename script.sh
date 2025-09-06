#!/bin/bash
set -xe
declare -A update_tags

while IFS=';' read -r ${tagmap}; do
  tag="$(echo "$map" | cut -d ':' -f 1)"
  tag_pointer="$(echo "$map" | cut -d ':' -f 2)"

  if ! (git rev-parse "$tag" >/dev/null 2>&1 && [[ $(git rev-list -n 1 "${tag_pointer") == $(git rev-list -n 1 "${tag})" ]]); then
    update_tags["$tag_pointer"]+="$tag;"
  fi
done

for tag in ${!update_tags[@]}; do
  git checkout $tag

  declare -a new_tags
  IFS=$';' read -ra new_tags <<< "${update_tags[$tag]}"
  for new_tag in ${new_tags[@]}; do
    echo "${new_tag}"
    git tag -a "${new_tag}" -m "Update tag ${new_tag} to point to ${tag}"
  done
  unset new_tags
done

