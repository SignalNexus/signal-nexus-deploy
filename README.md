# Signal Nexus deploy template

English is canonical. The Japanese mirror is [README_JA.md](README_JA.md).

Generate a private repository from this template. The repository deploys one Analytics VM. It does not contain the core source, a venue source tree, or a secret value.

The deployment authority is the [Community Deployment Guide](https://github.com/SignalNexus/signal-nexus/blob/main/docs/COMMUNITY_DEPLOYMENT_GUIDE.md) in `SignalNexus/signal-nexus`.

`core-pin` is `c301cb2f1d76344bb5126dc57efccd704eb74eb3`. That commit of `SignalNexus/signal-nexus` runs `deploy.futures_read` only when `BUILTIN_VENUES` contains `mexc_futures`. `.github/workflows/deploy.yml` uses that same commit for the `uses` ref and for `core_sha`. The core tree is `SignalNexus/signal-nexus`.

## Before the first run

1. Copy each file in `config/examples/` to `config/<name>` without the `.example` suffix. The seven live files are `locale.yml`, `month_target.yml`, `ops_schedule.yml`, `protective_exit.yml`, `strategies.yml`, `strategy_results.yml`, and `venues.yml`. Edit them. An empty file is rejected. `render-build.sh` copies these live files, not the examples.
2. Leave `venueadd/venues.yaml` as `venues: []` until a purchased venue is added. Each added `sha` is 40 hex characters. When the list is not empty, store one fine-grained personal access token as the `VENUEADD_READ_TOKEN` secret. Signal Nexus does not keep that token.
3. Create the Actions variables and secrets named in [deploy/target.env.example](deploy/target.env.example). The guide lists which nine secrets are required for the first run and which names wait. Set `DEPLOY_ANALYTICS` to `true` immediately before that run. Do not commit the values.

The Render build command is `bash render-build.sh && pip install -r .core/requirements.txt`. The start command is `cd .core && uvicorn app.main:app --host 0.0.0.0 --port $PORT`.

When you move to a newer public core commit, put that commit in `core-pin` and in both places in `deploy.yml`. The pin job stops when they differ.

## Run

Wait until the Render service `GET /health` returns `{"status":"ok"}`. Then run the `deploy` workflow with `workflow_dispatch`. The workflow passes each secret by name into the public reusable workflow. It does not contain a host name. `venues: []` does not need `VENUEADD_READ_TOKEN`. `BUILTIN_VENUES=none` does not require MEXC futures secrets.

## Repository access

The workflow accepts one `venueadd_read_token`. The caller stores that value as `VENUEADD_READ_TOKEN`. It is a fine-grained personal access token whose resource owner is the organization that owns the venue repositories, with Contents: Read, for repositories that caller can already read. `venues: []` needs no token.

The caller is an outside collaborator with Read on each purchased repository. A row for a repository the token cannot read fails the fetch, and the host job does not restart. A refund removes the manifest row, runs deploy once, and then removes that Read grant. Removing Read while the row remains fails the next deploy before restart. The installed tree is removed by the green deploy that no longer names it.

## Rollback

Rollback stays on this caller. Set `core-pin` and both commits in `deploy.yml` back to the last public core commit that deployed successfully. Run `deploy` again. Do not delete the previous `config/strategies.yml` until that run is green. A failed first deploy sets `DEPLOY_ANALYTICS` to false and, on a retry, uses a new SSH key and a new database password.
