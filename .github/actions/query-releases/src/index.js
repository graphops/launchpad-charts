const { GitHub, getOctokitOptions } = require("@actions/github/lib/utils");
const { paginateGraphql } = require("@octokit/plugin-paginate-graphql");
const octokit = GitHub.plugin(paginateGraphql);
const core = require('@actions/core');
const artifact = require('@actions/artifact');

const token = core.getInput('token');
const owner = core.getInput('owner');
const repo = core.getInput('repo');

const pagOctokit = new octokit(getOctokitOptions(token))

const fs = require('fs');

async function query() {
  const response = await pagOctokit.graphql.paginate(`
  query paginate($cursor: String, $owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
    releases(
        first: 100
        after: $cursor
        orderBy: {field: CREATED_AT, direction: ASC}
    ) {
        edges {
        node {
            name
            isPrerelease
            isDraft
            description
            createdAt
            releaseAssets(last: 1) {
            nodes {
                createdAt
                name
                size
                downloadUrl
            }
            }
        }
        }
        pageInfo {
        endCursor
        hasNextPage
        }
    }
  }
}`,
{
  owner: owner,
  name: repo
}
);

  console.log(response);

  fs.writeFileSync('releases.json', JSON.stringify(response.repository.releases.edges.map( edge => edge.node)));

  const artifactClient = artifact.create()
  const options = {
    continueOnError: false
  }

  const uploadResponse = await artifactClient.uploadArtifact(
    'releases',
    ['releases.json'],
    '.',
    options
  )
}

query();
