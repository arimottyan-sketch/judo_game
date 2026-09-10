# Judo Throw Prototype

敵を「攻撃して削る」のではなく、掴んで投げ、地形や他の敵を利用して攻略する2D横スクロールアクションの最小プロトタイプです。

## 現在のバージョン

Prototype v0.1

現時点ではグラフィックを図形だけにして、投げ操作そのものの手触りを検証します。

## 操作

| 入力 | 操作 |
| --- | --- |
| `A / D` または `← / →` | 移動 |
| `Space` | ジャンプ |
| `J` | 掴む / 離す |
| `K + 方向` | 投げ |
| `R` | リセット |

主人公が右向きで敵を正面から掴んだ場合：

- `← + K` : 巴投
- `→ + K` : 大外刈
- `↓ + K` : 背負投

敵を背後から掴んだ場合：

- `K` : 裏投（方向不問）

## 現在実装済み

- 左右移動
- 低めのジャンプ
- 掴み / 離し
- 敵の前後判定
- 大外刈
- 背負投
- 巴投
- 裏投
- 投げ後の重力・着地

## 次に実装する予定

- 崩し（押す / 引く）
- よろめき・汗・踏ん張り復帰
- 投げ失敗時の反撃
- 主人公HP
- 穴への落下
- 太っちょ兵
- 突撃兵
- 敵同士の衝突

## Godotでローカル実行

Godot 4.7.xでこのフォルダの `project.godot` を開き、プロジェクトを実行してください。

## GitHub Pagesへの自動公開

`.github/workflows/deploy-pages.yml` が入っています。

GitHubで一度だけ以下を設定します。

1. Repository の `Settings` を開く
2. 左メニューの `Pages` を開く
3. `Build and deployment` → `Source` を `GitHub Actions` にする
4. `main` ブランチへpushする

その後は、`main`へ更新をpushするたびにGitHub ActionsがGodot 4.7.2を取得し、Web版を自動exportしてGitHub Pagesへ公開します。

公開URLは通常、次の形式です。

`https://YOUR-USERNAME.github.io/REPOSITORY-NAME/`

## ライセンス

ゲーム本体のライセンスは、正式公開前に決定します。
Godot EngineはMIT Licenseで提供されています。


## v0.3
Throw-feel pass: unique trajectories/spin, launch burst, motion trails, impact rings/dust, camera shake, and short hit-stop.


## v0.3.3
Debug-stable version: fixed camera, two guaranteed enemy spawns, simplified scene logic.
