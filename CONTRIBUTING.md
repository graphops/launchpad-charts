# Contributing to *Launchpad Charts*

Hello! :wave: and thank you for considering investing your time in contributing to Launchpad Charts! As an open source project, it depends on a strong community to flourish, and we welcome any type of contribution (not just code) that aligns with our [Code of Conduct](/CODE_OF_CONDUCT.md).

Some of the ways to contribute:
- **Community:** by hanging with our community at ![Discord](https://avatars.githubusercontent.com/u/1965106?s=12&v=4) [Discord *(The Graph)*](https://discord.com/channels/438038660412342282/1029379955307585568), even if just to let us know you're using some of our *Charts* we would appreciate to hear from you. We don't bite, promise!
- **Opening Issues:** by being a user and taking the time to report issues (or feature requests) you've ran into. Please see the [Opening Issues](/CONTRIBUTING.md#opening-issues) section below on how to do just that.
- **Code:** by channeling your skills and knowledge to craft valuable pull requests (PRs). We wholeheartedly welcome your contributions. Please see the [Contributing Code](/CONTRIBUTING.md#contributing-code) section below on how to do just that.

# Opening Issues

To ensure a consistent and efficient response to your issues, we have created two issue templates that will provide guidance and streamline the process. When creating a new issue in the repository, you will be presented with the option to choose from these templates. This approach aims to enhance clarity and facilitate the information gathering process for a faster resolution.

# Contributing Code

## Requirements

To contribute code, there's a few requirements you need to go through first:

### yarn

This repo is setup for Yarn [zero-installs](https://v3.yarnpkg.com/features/zero-installs), and advises the usage of [Corepack](https://github.com/nodejs/corepack), so make sure you've enabled corepack on your system:
```
corepack enable
```

Our Git hooks system and some of our dependencies for tasks such as code generating or generating documentation are being managed by [*husky*](https://github.com/typicode/husky), so that will be required and as such you should run the prepare script to enable husky: 
```
corepack yarn prepare
```

### helm-docs

Our charts documentation is generated with `helm-docs` and that is part of a git commit hook, as such for you to be able to commit [*helm-docs*](https://github.com/norwoodj/helm-docs#Installation) must be available

### For MacOS users only

#### Upgrade `bash` version

Please note that due to licensing restrictions, Apple ships macOS with GNU Bash v3.2, which is an outdated version dating back to 2007. To ensure compatibility and access to the latest features, we recommend installing a more recent version of bash. You can easily accomplish this by using Homebrew:

> brew install bash

#### Upgrade `grep` version

Although macOS includes a BSD-based grep utility, it's worth noting that the shipped version is outdated and lacks support for certain newer options, such as -P for Perl regular expression pattern search. To overcome this limitation, you have the option to install a more recent version of grep using Homebrew:

> brew install grep

After installing the newer version, please be aware that it is accessed using the command `ggrep` instead of the default `grep`. This naming distinction is in place to avoid conflicts with the preinstalled macOS `grep` utility.

## Clone

Once you have successfully fulfilled the previous requirements in your operating system, the next logical step is to clone this repository and initialize the yarn packages using the following command:

> yarn install

You're all set up and ready to go! Continue reading for conventions and a concise overview of the repository layout and implementation details.

## Commit messages and pull requests

We follow [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/).

In brief, each commit message consists of a header, with optional body and footer:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

`<type>` must be one of the following:
- feat: A new feature
- fix: A bug fix
- docs: Documentation only changes
- style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- refactor: A code change that neither fixes a bug nor adds a feature
- perf: A code change that improves performance
- test: Adding missing tests
- chore: Changes to the build process or auxiliary tools and libraries such as documentation generation
- revert: If the commit reverts a previous commit, contains the header of the reverted commit.

Make sure to include an exclamation mark after the commit type and scope if there is a breaking change.

`<scope>` optional and could be anything that specifies the place of the commit change, e.g. solver, [filename], tests, lib, ... we are not very restrictive on the scope. The scope should just be lowercase and if possible contain of a single word.

`<description>` contains succinct description of the change with imperative, present tense. don't capitalize first letter, and no dot (.) at the end.

`<body>` include the motivation for the change, use the imperative, present tense

`<footer>` contain any information about Breaking Changes and reference GitHub issues that this commit closes

Commits in a pull request should be structured in such a way that each commit consists of a small logical step towards the overall goal of the pull request. Your pull request should make it as easy as possible for the reviewer to follow each change you made. For example, it is a good idea to separate simple mechanical changes like renaming a method that touches many files from logic changes. Your pull request should not be structured into commits according to how you implemented your feature, often indicated by commit messages like 'Fix problem' or 'Cleanup'. Flex a bit, and make the world think that you implemented your feature perfectly, in small logical steps, in one sitting without ever having to touch up something you did earlier in the pull request. (In reality, that means you'll use `git rebase -i` a lot).

Please do not merge the remote branch into yours as you develop your pull request; instead, rebase your branch on top of the latest remote if your pull request branch is long-lived.

## Release process

### Development and Canary releases

You should do your development work on a separate branch like `feat/example` or `fix/some-bug`. To trigger a workflow and produce a chart build out of your branch, you can push a tag that follows the pattern `<chart>-<version>-canary.N` where N is an 
integer number that you should increment sequentially. After pushing such a tag, GitHub workflows will create a chart pre-release and add it to the helm repository available at `https://graphops.github.io/launchpad-charts/canary`.
*Note*: with canary pre-releases, the chart's version that may be present on the chart's metadata in `Chart.yaml` will be overridden by the version specified in the tag, and you shouldn't update that value until wishing to release a stable version.

### Stable releases

We do continuous integration on the main branch and canary releases (with a pre-release suffix of `-canary.X`) are automatically made on a commit-by-commit basis depending on which chart the commit impacts. The versioning of the canary releases produced on commit is always the next patch version since the last stable release, and a pre-release suffix that gets incremented starting on `-canary.1`.

If the chart's version information (on `Chart.yaml`) gets incremented to a stable higher version (a semantic version without `-canary.N`), then a stable draft release will be produced. As such, you should only change the chart's version when intending to produce a stable release.

The stable releases are produced as a draft *GitHub Release* with release notes. Upon review and adjustment of the generated release notes, the draft releases need to be manually published.

The usual flow is then:
- create a branch and push canary tags to it as needed
- merge a PR to main, a new canary release will be created automatically then, and on every following commit
- (...do final tests and fix whatever may come up)
- decide the next version number
- merge a PR updating the version in `Chart.yaml` to [chart]-[version]
- a new draft stable release is produced
- review the draft release and publish it
