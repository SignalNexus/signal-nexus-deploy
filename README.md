# Signal Nexus deploy template

English is canonical. The Japanese mirror is [README_JA.md](README_JA.md).

Generate a private repository from this template. The repository deploys one Analytics VM. It does not contain the core source, a venue source tree, or a secret value.

`core-pin` is `76ae64a648b58807c070a644c0b006d755063b9e`. That commit of `SignalNexus/signal-nexus` contains `analytics-deploy.yml` and `venueadd-install.yml`. `.github/workflows/deploy.yml` uses that same commit for the `uses` ref and for `core_sha`. The core tree is `SignalNexus/signal-nexus`.

## Before the first run

1. Replace `config/strategies.yml`. The file in this template is `{}`. It is not a registry. The workflow hashes this file and passes that blob. The reusable workflow reads this repository's file, not a file from the public core.
2. Leave `venueadd/venues.yaml` as `venues: []` until a purchased venue is added. Each added `sha` is 40 hex characters. When the list is not empty, store one fine-grained personal access token as the `VENUEADD_READ_TOKEN` secret. Signal Nexus does not keep that token.
3. Create the Actions variables and secrets named in [deploy/target.env.example](deploy/target.env.example). Set `DEPLOY_ANALYTICS` to `true`. Do not commit the values.

When you move to a newer public core commit, put that commit in `core-pin` and in both places in `deploy.yml`. The pin job stops when they differ.

## Run

Run the `deploy` workflow with `workflow_dispatch`. The workflow passes the variables and secrets into the public reusable workflow. It does not contain a host name.

## Repository access

The workflow accepts one `venueadd_read_token`. The customer stores that value as `VENUEADD_READ_TOKEN`. It is a fine-grained personal access token whose resource owner is the organization that owns the venue repositories, with Contents: Read, for repositories that customer can already read. `venues: []` needs no token.

The customer is an outside collaborator with Read on each purchased repository. A row for a repository the token cannot read fails the fetch, and the host job does not restart. A refund removes the manifest row, runs deploy once, and then removes that Read grant. Removing Read while the row remains fails the next deploy before restart. The installed tree is removed by the green deploy that no longer names it.

## Rollback

Set `core-pin` and both commits in `deploy.yml` back to the last public core commit that deployed successfully. Run `deploy` again. Do not delete the previous `config/strategies.yml` until that run is green.
