# Signal Nexus deploy template

English is canonical. The Japanese mirror is [README_JA.md](README_JA.md).

Generate a private repository from this template. The repository deploys one Analytics VM. It does not contain the core source, a venue source tree, or a secret value.

`core-pin` is `76ae64a648b58807c070a644c0b006d755063b9e`. That commit of `SignalNexus/signal-nexus` contains `analytics-deploy.yml` and `venueadd-install.yml`. `.github/workflows/deploy.yml` uses that same commit for the `uses` ref and for `core_sha`. The core tree is `SignalNexus/signal-nexus`.

## Before the first run

1. Replace `config/strategies.yml`. The file in this template is `{}`. It is not a registry. The workflow hashes this file and passes that blob. The reusable workflow reads this repository's file, not a file from the public core.
2. Leave `venueadd/venues.yaml` as `venues: []` until a purchased venue is added. Each added `sha` is 40 hex characters. Create the `checkout_token` secret when the list is not empty.
3. Create the Actions variables and secrets named in [deploy/target.env.example](deploy/target.env.example). Set `DEPLOY_ANALYTICS` to `true`. Do not commit the values.

When you move to a newer public core commit, put that commit in `core-pin` and in both places in `deploy.yml`. The pin job stops when they differ.

## Run

Run the `deploy` workflow with `workflow_dispatch`. The workflow passes the variables and secrets into the public reusable workflow. It does not contain a host name.

## Deploy key

The workflow accepts one `checkout_token`. `venues: []` needs no token. Do not add a purchased venue to `venues.yaml` until the workflow takes one deploy key per row. A refund removes that key. If the row remains, fetch fails and the host job does not restart.

## Rollback

Set `core-pin` and both commits in `deploy.yml` back to the last public core commit that deployed successfully. Run `deploy` again. Do not delete the previous `config/strategies.yml` until that run is green.
