# Signal Nexus deploy テンプレート

このファイルは日本語の写しです。正本は [README.md](README.md) です。

このテンプレートからプライベートなリポジトリを作ります。そのリポジトリが、一つの Analytics VM を配備します。コアのソース、会場のソース、秘密の値は入りません。

`core-pin` は `76ae64a648b58807c070a644c0b006d755063b9e` です。`SignalNexus/signal-nexus` のその commit に、`analytics-deploy.yml` と `venueadd-install.yml` があります。`.github/workflows/deploy.yml` は、`uses` の ref と `core_sha` に同じ commit を使います。コアのツリーは `SignalNexus/signal-nexus` です。

## 最初の実行の前

1. `config/strategies.yml` を置き換えます。テンプレートのファイルは `{}` です。registry ではありません。workflow はこのファイルの blob を計算して渡します。reusable workflow が読むのは、このリポジトリのファイルです。公開コアのファイルではありません。
2. 購入した会場を足すまで、`venueadd/venues.yaml` は `venues: []` のままです。足す `sha` は 16 進 40 文字です。一覧が空でないときは、`checkout_token` の secret を作ります。
3. [deploy/target.env.example](deploy/target.env.example) の変数と secret を Actions に作ります。`DEPLOY_ANALYTICS` は `true` です。値は commit しません。

新しい公開コアの commit に移すときは、その commit を `core-pin` と `deploy.yml` の二か所に書きます。一致しないときは、pin の確認で止まります。

## 実行

`deploy` workflow を `workflow_dispatch` で実行します。変数と secret は、公開の reusable workflow へ渡します。workflow にホスト名はありません。

## Deploy Key

workflow が受けるのは、一つの `checkout_token` です。`venues: []` に token は要りません。workflow が行ごとの Deploy Key を受けるまで、購入した会場は `venues.yaml` に足しません。返金では、その鍵を外します。行が残ると取得が失敗し、ホスト job は再起動しません。

## Rollback

`core-pin` と `deploy.yml` の二つの commit を、最後に配備が成功した公開コアの commit へ戻します。`deploy` を再実行します。その実行が成功するまで、以前の `config/strategies.yml` は消しません。
