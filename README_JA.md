# Signal Nexus deploy テンプレート

このファイルは日本語の写しです。正本は [README.md](README.md) です。

このテンプレートからプライベートなリポジトリを作ります。そのリポジトリが、一つの Analytics VM を配備します。コアのソース、会場のソース、秘密の値は入りません。

配備の正本は、`SignalNexus/signal-nexus` の [Community Deployment Guide](https://github.com/SignalNexus/signal-nexus/blob/main/docs/COMMUNITY_DEPLOYMENT_GUIDE.md) です。

`core-pin` は `2e3cc5ee445c352d88e65a41a37bf7fdc5aa075d` です。`SignalNexus/signal-nexus` のその commit は、`BUILTIN_VENUES` に `mexc_futures` が含まれるときだけ `deploy.futures_read` を実行します。`.github/workflows/deploy.yml` は、`uses` の ref と `core_sha` に同じ commit を使います。コアのツリーは `SignalNexus/signal-nexus` です。

## 最初の実行の前

1. `config/examples/` の各ファイルを、`.example` を外した `config/<name>` へコピーします。七つの実ファイルは `locale.yml`、`month_target.yml`、`ops_schedule.yml`、`protective_exit.yml`、`strategies.yml`、`strategy_results.yml`、`venues.yml` です。編集します。空のファイルは拒否されます。`render-build.sh` がコピーするのは、これらの実ファイルであり、例ではありません。
2. 購入した会場を足すまで、`venueadd/venues.yaml` は `venues: []` のままです。足す `sha` は 16 進 40 文字です。一覧が空でないときは、fine-grained personal access token を一つ、`VENUEADD_READ_TOKEN` の secret として置きます。Signal Nexus はその token を保持しません。
3. [deploy/target.env.example](deploy/target.env.example) の変数と secret を Actions に作ります。ガイドが、初回に必要な九つと、待つ名前を分けています。`DEPLOY_ANALYTICS` は、その実行の直前に `true` にします。値は commit しません。

Render の build command は `bash render-build.sh && pip install -r .core/requirements.txt` です。start command は `cd .core && uvicorn app.main:app --host 0.0.0.0 --port $PORT` です。

新しい公開コアの commit に移すときは、その commit を `core-pin` と `deploy.yml` の二か所に書きます。一致しないときは、pin の確認で止まります。

## 実行

Render の `GET /health` が `{"status":"ok"}` になるまで待ちます。そのあと `deploy` workflow を `workflow_dispatch` で実行します。各 secret は名前で、公開の reusable workflow へ渡します。workflow にホスト名はありません。`venues: []` に `VENUEADD_READ_TOKEN` は要りません。`BUILTIN_VENUES=none` は MEXC futures の secret を要求しません。

## リポジトリのアクセス

workflow が受けるのは、一つの `venueadd_read_token` です。caller はその値を `VENUEADD_READ_TOKEN` として置きます。これは fine-grained personal access token です。resource owner は会場リポジトリを持つ組織、権限は Contents: Read、範囲はその caller がすでに読めるリポジトリです。`venues: []` に token は要りません。

caller は、購入した各リポジトリの Read を持つ outside collaborator です。token が読めないリポジトリの行は取得に失敗し、ホスト job は再起動しません。返金は、manifest の行を外し、deploy を一度実行し、そのあと Read を外します。行が残ったまま Read を外すと、次の deploy は再起動の前に失敗します。導入済みのツリーは、その行を外した成功した deploy が削除します。

## Rollback

rollback はこの caller に留まります。`core-pin` と `deploy.yml` の二つの commit を、最後に配備が成功した公開コアの commit へ戻します。`deploy` を再実行します。その実行が成功するまで、以前の `config/strategies.yml` は消しません。失敗した初回 deploy は `DEPLOY_ANALYTICS` を false にし、再試行では新しい SSH 鍵と新しい database パスワードを使います。
