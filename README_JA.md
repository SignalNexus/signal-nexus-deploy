# Signal Nexus deploy テンプレート

このファイルは日本語の写しです。正本は [README.md](README.md) です。

このテンプレートからプライベートなリポジトリを作ります。そのリポジトリが、一つの Analytics VM を配備します。コアのソース、会場のソース、秘密の値は入りません。

`core-pin` は `76ae64a648b58807c070a644c0b006d755063b9e` です。`SignalNexus/signal-nexus` のその commit に、`analytics-deploy.yml` と `venueadd-install.yml` があります。`.github/workflows/deploy.yml` は、`uses` の ref と `core_sha` に同じ commit を使います。コアのツリーは `SignalNexus/signal-nexus` です。

## 最初の実行の前

1. `config/strategies.yml` を置き換えます。テンプレートのファイルは `{}` です。registry ではありません。workflow はこのファイルの blob を計算して渡します。reusable workflow が読むのは、このリポジトリのファイルです。公開コアのファイルではありません。
2. 購入した会場を足すまで、`venueadd/venues.yaml` は `venues: []` のままです。足す `sha` は 16 進 40 文字です。一覧が空でないときは、fine-grained personal access token を一つ、`VENUEADD_READ_TOKEN` の secret として置きます。Signal Nexus はその token を保持しません。
3. [deploy/target.env.example](deploy/target.env.example) の変数と secret を Actions に作ります。`DEPLOY_ANALYTICS` は `true` です。値は commit しません。

新しい公開コアの commit に移すときは、その commit を `core-pin` と `deploy.yml` の二か所に書きます。一致しないときは、pin の確認で止まります。

## 実行

`deploy` workflow を `workflow_dispatch` で実行します。変数と secret は、公開の reusable workflow へ渡します。workflow にホスト名はありません。

## リポジトリのアクセス

workflow が受けるのは、一つの `venueadd_read_token` です。顧客はその値を `VENUEADD_READ_TOKEN` として置きます。これは fine-grained personal access token です。resource owner は会場リポジトリを持つ組織、権限は Contents: Read、範囲はその顧客がすでに読めるリポジトリです。`venues: []` に token は要りません。

顧客は、購入した各リポジトリの Read を持つ outside collaborator です。token が読めないリポジトリの行は取得に失敗し、ホスト job は再起動しません。返金は、manifest の行を外し、deploy を一度実行し、そのあと Read を外します。行が残ったまま Read を外すと、次の deploy は再起動の前に失敗します。導入済みのツリーは、その行を外した成功した deploy が削除します。

## Rollback

`core-pin` と `deploy.yml` の二つの commit を、最後に配備が成功した公開コアの commit へ戻します。`deploy` を再実行します。その実行が成功するまで、以前の `config/strategies.yml` は消しません。
