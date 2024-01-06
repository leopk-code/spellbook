# Subprojects POC

I'd recommend cloning this repo in a separate location and creating a new dbt profile (with a new schema name) in your `profiles.yml` file. I created a profile named `spellbook-poc-tokens`, copied my existing dev profile and changed the schema to `dbt_poc_tokens`. 
```
cd tokens/
dbt deps
dbt run --profiles-dir ~/.dbt --profile spellbook-poc-tokens
```

The tokens subproject contains the following models. This set of models is defined by `dbt -q ls -s +tokens_erc20 +tokens_native --resource-type model --output path`

```
models/aave/aave_v3_tokens.sql
models/ovm/optimism/ovm_optimism_l2_token_factory.sql
models/the_granary/optimism/the_granary_optimism_tokens.sql
models/tokens/arbitrum/tokens_arbitrum_erc20.sql
models/tokens/avalanche_c/tokens_avalanche_c_erc20.sql
models/tokens/base/tokens_base_erc20.sql
models/tokens/bnb/tokens_bnb_bep20.sql
models/tokens/celo/tokens_celo_erc20.sql
models/tokens/tokens_erc20.sql
models/tokens/ethereum/tokens_ethereum_erc20.sql
models/tokens/fantom/tokens_fantom_erc20.sql
models/tokens/gnosis/tokens_gnosis_erc20.sql
models/tokens/tokens_native.sql
models/tokens/optimism/tokens_optimism_erc20.sql
models/tokens/optimism/tokens_optimism_erc20_bridged_mapping.sql
models/tokens/optimism/tokens_optimism_erc20_curated.sql
models/tokens/optimism/tokens_optimism_erc20_generated.sql
models/tokens/optimism/tokens_optimism_erc20_transfer_source.sql
models/tokens/polygon/tokens_polygon_erc20.sql
models/tokens/zksync/tokens_zksync_erc20.sql
models/tokens/zora/tokens_zora_erc20.sql
models/yearn/optimism/yearn_optimism_vaults.sql
```

I moved those files to the target dir with this command:

```
dbt -q ls -s +tokens_erc20 +tokens_native --resource-type model --output path | xargs -I {} rsync --relative {} tokens/models/
```


## Notes

Generate source definitions for token subproject:
```
cd tokens
./generate_sources.sh 
```
This will dump all sources to terminal output. I just copied it, and manually reformated the output so it would fit into one file.












![spellbook-logo@10x](https://user-images.githubusercontent.com/2520869/200791687-76f1bc4f-05d0-4384-a753-e3b5da0e7a4a.png#gh-light-mode-only)
![spellbook-logo-negative_10x](https://user-images.githubusercontent.com/2520869/200865128-426354af-8059-494d-83f7-46947aae271c.png#gh-dark-mode-only)

Welcome to [Spellbook](https://youtu.be/o7p0BNt7NHs). Cast a magical incantation to tame the blockchain.

## TL;DR
- Are you building something new? **Please make sure to open a Draft PR**, so we minimize duplicated work, and other wizards can help you if you need
- Don't know where to start? The docs below will guide you, but as a summary:
  - Want to make an incremental improvement to one of our spells? (add a new project, fix a bug you found), simply open a PR with your changes. 
    - Follow the guide for [Submitting a PR](), [Setting up your dev environment]() and [Using dbt to write spells]() if you find yourself lost.
    - Not sure how to start? Follow the walkthrough [here](https://dune.com/docs/spellbook/).
    - Make sure to open a draft PR if you will work on your spell for longer than a few days, to avoid duplicated work
  - Do you want to get started building spells and you don't know what to build? Check [Issues]() to see what the community needs.
  - Check the Discussions section to see what problems the community is trying to solve (i.e. non-incremental changes) or propose your own!
- Have questions? Head over to #spellbook on our [discord](https://discord.com/channels/757637422384283659/999683200563564655) and the community will be happy to help out!
- Like with most OSS projects, your contributions to Spellbook are your own IP, you can find more details in the [Contributor License Agreement](https://github.com/duneanalytics/spellbook/blob/main/CLA.md)


## Table of Contents

- [Introduction](#introduction)
- [How to contribute](#ways-to-contribute-to-spellbook)
  - [Submitting a PR](#submitting-a-pr)
  - [Testing your Spell](#testing-your-spell)
  - [Connecting with other wizards](#connecting-with-other-wizards)
- [Setting up your dev environment](#setting-up-your-local-dev-environment)
- [Using dbt to write spells](#how-to-use-dbt-to-create-spells)


## Introduction

Spellbook is Dune's interpretation layer, built for and by the community.

Spellbook is a [dbt](https://docs.getdbt.com/docs/introduction) project. Each model is a simple SQL query with minor syntactic sugar (meant to capture dependencies and help build the resulting tables), and does a small part of the task of turning raw and decoded records into interpretable blockchain data.

Spellbook is built for and by the community, you are welcome to close any gaps that you find by sending a PR, creating issues to propose small changes or track bugs, or participate in discussions to help steer the future of this project.

## Ways to contribute to Spellbook

- **Build** spells - if you want to write code, simply clone the repo, write your code, and open a PR
  - If you already know what to build, there's no red tape to skip around, simply open a PR when you're ready. We advice opening draft PRs early, so we avoid duplication of efforts and you can get help from other wizards
  - If you don't know where to start, check out Issues for ideas. We're always looking for help fixing small bugs or implementing spells for small projects
- **Flag** gaps in spellbook - have you found a bug, or is there a project missing from one of the sectors that you'd like to add? You can create an [issue](https://github.com/duneanalytics/spellbook/issues) and bring other wizards to your aid.
  - **Bugs**: Found a record on a Spell that doesn't reflect chain data correctly? Please make sure you link to a block explorer showing the expected value, and a dune query showing the wrong value. If there's multiple records affected, any sense of scale (how many rows, affected USD volume) will also be very helpful.
- **Propose** changes to spellbook - [Discussions](https://github.com/duneanalytics/spellbook/discussions) are where we bring up, challenge and develop ideas to continue building spellbook. If you want to make a major change to a spell (e.g. major overhaul to a sector, launching a new sector, designing a new organic volume filter, etc.).

### Submitting a PR
Want to get right to work? Follow the guide [here](https://dune.com/docs/spellbook/?h=7+steps+adding+a+spell) to get started.

### Testing your spell
You don't need a complex local setup to test spells against Dune's engine. Once you send a PR, our CI pipeline will run and test it, and, if the job finishes successfully, you'll be able to query the data your PR created directly from dune.com.

Simply write a query like you would for any of our live tables, and use the test schema to fetch the tables your PR created.

`test_schema.git_{{commit_hash}}_{{table_name}}` 

You can find the exact names easily by looking at the logs from the `dbt slim ci` action, under `dbt run initial model(s)`.

Please note: the test tables built in the CI pipeline will exist for ~24 hours. If your table doesn't exist, trigger the pipeline to run again and recreate the test table.

### Connecting with other wizards

We use Discord to connect with our community. Head over to spellbook channel on [Dune's Discord](https://discord.gg/dunecom) for questions or to ask for help with a particular PR. We encourage you to learn by doing, and leverage our vibrant community to help you get going.


## Setting up your Local Dev Environment

### Prerequisites

- Fork this repo and clone your fork locally. See Github's [guide](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) on contributing to projects.
- We default to use unix (LF) line endings, windows users please set: `git config --global core.autocrlf true`. [more info](https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings)
- python 3.9 installed. Our recommendation is to follow the [Hitchhiker's Guide to Python](https://docs.python-guide.org/starting/installation/)
- [pip](https://pip.pypa.io/en/stable/installation/) installed
- [pipenv](https://pypi.org/project/pipenv/) installed
- paths for both pip and pipenv are set (this should happen automatically but sometimes does not). If you run into issues like "pipenv: command not found", try troubleshooting with the pip or pipenv documentation.

### Initial Installation

You can watch the video version of this if you scroll down a bit.

Navigate to the spellbook repo within your CLI (Command line interface).

```console
cd user\directory\github\spellbook
# Change this to wherever spellbook is stored locally on your machine.
```

Using the pipfile located in the spellbook repo, run the below install command to create a pipenv.

```console
pipenv install
```

If the install fails, one likely reason is our script looks for a static python version and the likelihood of an error for a wrong python version is pretty high. If that error occurs, check your python version with:

```console
python --version
```

Now use any text editor program to change the python version in the pipfile within the spellbook directory to your python version. You need to have at least python 3.9.
If you have changed the python version in the pipfile, run `pipenv install` again.

You are now ready to activate this project's virtual environment. Run the following command to enter the environment:

```console
pipenv shell
```

You have now created a virtual environment for this project. You can read more about virtual environments [here](https://realpython.com/pipenv-guide/).

To pull the dbt project dependencies run:

```console
dbt deps
```

Ensure you are in Spellbook root directory, then run the following command:

```console
dbt compile
```

Spellbook root directory includes a `profiles.yml` file, which helps tell dbt how to run commands. The profile is located in the root directory [here](https://github.com/duneanalytics/spellbook/blob/main/profiles.yml). This should never need modified, unless done intentionally by the Dune team.  
Due to the `profiles.yml` file being stored in the root directory, this is why users **must** be in the root directory on the command line to run `dbt compile`.

dbt compile will compile the JINJA and SQL templated SQL into plain SQL which can be executed in the Dune UI. Your spellbook directory now has a folder named `target` containing plain SQL versions of all models in Dune. If you have made changes to the repo before completing all these actions, you can now be certain that at least the compile process works correctly, if there are big errors the compile process will not complete.
If you haven't made changes to the directory beforehand, you can now start adding, editing, or deleting files within the repository.
Afterwards, simply run `dbt compile` again once you are finished with your work in the directory and test the plain language sql queries on dune.com.

### Coming back

If you have done this installation on your machine once, to get back into dbt, simply navigate to the spellbook repo, run `pipenv shell`, and you can run `dbt compile` again.

### What did I just do?

You now have the ability to compile your dbt model statements and test statements into plain SQL. This allows you to test those queries on the usual dune.com environment and should therefore lead to a better experience while developing spells. Running the queries will immediately give you feedback on typos, logical errors, or mismatches.
This in turn will help us deploy these spells faster and avoid any potential mistakes.

## How to use dbt to create spells

There are a couple of new concepts to consider when making spells in dbt. The most common ones wizards will encounter are refs, sources, freshness, and tests.

In the body of each query, tables are referred to either as refs, ex `{{ ref('1inch_ethereum') }}` or sources, ex `{{ source('ethereum', 'traces') }}`. Refs refer to other dbt models and they should refer to the file name like `1inch_ethereum.sql`, even if the model itself is aliased. Sources refer to "raw" data or tables/views not generated by dbt. Using refs and sources allows us to automatically build dependency trees.

Sources and models are defined in schema.yml files where tests and other attributes are defined.

The best practice is to add tests unique and non_null tests to the primary key for every new model. Similarly, a freshness check should be added to every new source (although we will try not to re-test freshness if the source is used elsewhere).

Adding descriptions to tables and columns will help people find and use your tables.

```yaml
models:
  - name: 1inch_ethereum
    description: "Trades on 1inch, a DEX aggregator"
    columns:
      - name: tx_hash
        description: "Table primary key: a transaction hash (tx_hash) is a unique identifier for a transaction."
        tests:
          - unique
          - not_null

  sources:
  - name: ethereum
    freshness:
      warn_after: { count: 12, period: hour }
      error_after: { count: 24, period: hour }
    tables:
      - name: traces
        loaded_at_field: block_time
```

See links to more docs on dbt below.

### Generating and serving documentation:

To generate documentation and view it as a website, run the following commands:

- `dbt docs generate`
- `dbt docs serve`
  You must have set up dbt with `dbt init` but you don't need database credentials to run these commands.

See [dbt docs documentation](https://docs.getdbt.com/docs/building-a-dbt-project/documentation) for more information on
how to contribute to documentation.

As a preview, you can do [things](https://docs.getdbt.com/reference/resource-properties/description) like:

- Write simple one or many line descriptions of models or columns.
- Write longer descriptions as code blocks using markdown.
- Link to other models in your descriptions.
- Add images / project logos from the repo into descriptions.
- Use HTML in your description.

### DBT Resources:

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://getdbt.com/community/join-the-community/) on Slack for live discussions and support
- Find [dbt events](https://getdbt.com/events/) near you
- Check out [the blog](https://getdbt.com/blog/) for the latest news on dbt's development and best practices
