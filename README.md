# aws-ecs-autostart-autostop

ECS サービスで、アクセスの無いときはタスクを停止し、アクセスがあったときにタスクを開始する実験。

```sh
terraform init
terraform apply
```

ELB の DNS 名にアクセスすると `Please just a moment. Now starting environment.` と表示され、しばらく待つと自動的にアプリの画面（nginx の welcome page）が表示されます。

## メモ

1つの ELB を使いまわす場合リスナールールの priority を重複しないように生成するのが課題。
また、リスナールールの次の制限を超えるとダメ。

- 100 total rules per Application Load Balancer
- 5 condition values per rule
- 5 wildcards per rule
- 5 weighted target groups per rule
