  set -xe
  tags=()
  declare -A release_streams=()
  for chart_dir in charts/erigon; do
    chart_name=$(echo ${chart_dir} | cut -d '/' -f 2)
  
    latest_version="$(git -c 'versionsort.suffix=-' tag --sort 'version:refname' --list "$chart_name-*" | grep -Ev '.*-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+-.*' | tail -n1)"
    next_patch=""

    if [ -z "$latest_version" ]; then
      latest_version="$(git -c 'versionsort.suffix=-' tag --sort 'version:refname' --list "$chart_name-*" | tail -n1 | sed 's/-canary\.[0-9]*//')"
      next_patch="$(echo ${latest_version} | sed 's/.*-\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/')"
    fi

    if [ -z "$latest_version" ]; then
      latest_version="0.0.0"
    fi

    if [ -z "$next_patch" ]; then
      next_patch="$(echo "$latest_version" | sed -E 's/(.*-)?([[:digit:]]+).([[:digit:]]+).([[:digit:]]+)/echo \2.\3.$((\4 + 1))/e')"
    fi

    last_pre_tag="$(git -c 'versionsort.suffix=-' tag --sort 'version:refname' --list "$chart_name-$next_patch-*" | tail -n1)"

    if [ -z "$last_pre_tag" ]; then
      index=1
    else
      index=$(echo "$last_pre_tag" | sed -E 's/(.*-)?[[:digit:]]+.[[:digit:]]+.[[:digit:]]+-canary.([[:digit:]]+)(#.*)?/echo $((\2 + 1))/e')
    fi
    next_tag="$chart_name-$next_patch-canary.$index"
  
    tags+=("$next_tag")
    #git tag -a "$next_tag" -m "Release $next_tag"
  
    release_streams["canary"]=1
  done
  
  echo "release-tags<<EOF" 
  echo "$(jq -Rc '. / " "' <<< ${tags[*]})" 
  echo "EOF"
  
  echo "release-streams<<EOF"
  echo "$(jq -Rc '. / " "' <<< ${!release_streams[@]})"
  echo "EOF"
