const { GitHub, getOctokitOptions } = require("@actions/github/lib/utils");
const { paginateGraphQL } = require("@octokit/plugin-paginate-graphql");
const core = require("@actions/core");
const fs = require("fs");

// v2 artifact usage
const { DefaultArtifactClient } = require("@actions/artifact");

const token = core.getInput("token");
const owner = core.getInput("owner");
const repo = core.getInput("repo");

// Setup Octokit with paginateGraphQL
const OctokitWithPaginate = GitHub.plugin(paginateGraphQL);
const pagOctokit = new OctokitWithPaginate(getOctokitOptions(token));

async function query() {
  const response = await pagOctokit.graphql.paginate(
    `
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
      }
    `,
    {
      owner,
      name: repo,
    }
  );

  console.log(response);

  // Save results to a local file
  fs.writeFileSync(
    "releases.json",
    JSON.stringify(response.repository.releases.edges.map((edge) => edge.node))
  );

  // Upload using the new artifact lib
  const artifactClient = new DefaultArtifactClient();

  const { digest, id, size } = await artifactClient.uploadArtifact(
    "releases",
    ["./releases.json"],
    ".",
    {
      // optional: retentionDays: 7, etc.
    }
  );
  console.log(`Uploaded artifact with ID ${id} (size: ${size} bytes)`);
}

query();
