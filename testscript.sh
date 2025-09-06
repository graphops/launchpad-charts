#!/bin/bash
set -e
chart_file="charts/firehose-ethereum/Chart.yaml"

# Check if dependencies section exists using yq
if yq e 'has("dependencies")' "${chart_file}" | grep -q "true"; then
  echo "Dependencies found in Chart.yaml, processing repositories..."
  
  # Get dependency count
  dep_count=$(yq e '.dependencies | length' "${chart_file}")
  echo "Found $dep_count dependencies in Chart.yaml"
  
  # Process each dependency and extract repositories
  ADDED_REPOS=()
  
  for i in $(seq 0 $((dep_count-1))); do
    # Extract the repository URL for this dependency
    dep_name=$(yq e ".dependencies[$i].name" "${chart_file}")
    repo_url=$(yq e ".dependencies[$i].repository" "${chart_file}")
    
    # Skip if no repository is specified or if it's null
    if [ -z "$repo_url" ] || [ "$repo_url" = "null" ]; then
      echo "No repository specified for dependency: $dep_name"
      continue
    fi
    
    # Skip if already added
    if [[ " ${ADDED_REPOS[*]} " =~ " ${repo_url} " ]]; then
      echo "Repository already added: $repo_url"
      continue
    fi
    
    # Extract a sensible name from the URL
    repo_name=$(echo "$repo_url" | sed -E 's/https?:\/\///' | sed -E 's/[^a-zA-Z0-9]/-/g' | cut -c1-20)
    echo "Adding repository for $dep_name: $repo_name → $repo_url"
    
    if ! helm repo add "$repo_name" "$repo_url" 2>/dev/null; then
      echo "Warning: Failed to add repository $repo_url, but continuing..."
    else
      ADDED_REPOS+=("$repo_url")
    fi
  done
  
  if [ ${#ADDED_REPOS[@]} -gt 0 ]; then
    echo "Updating Helm repositories..."
    helm repo update
    echo "Repository setup complete (${#ADDED_REPOS[@]} repositories added)"
  else
    echo "No repositories were added"
  fi
  
  echo "Building dependencies..."
  helm dep build "charts/firehose-ethereum" --skip-refresh
  echo "Dependencies built"
else
  echo "No dependencies section found in Chart.yaml, skipping repository setup"
fi

echo "Packaging chart..."
helm package "charts/firehose-ethereum"
echo "Chart packaging complete"
