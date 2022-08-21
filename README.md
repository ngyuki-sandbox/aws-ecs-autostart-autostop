# aws-ecs-autostart-autostop

ECS サービスで、アクセスの無いときはタスクを停止し、アクセスがあったときにタスクを開始する実験。

```sh
terraform init
terraform apply
```

ELB の DNS 名にアクセスすると `Please just a moment. Now starting environment.` と表示され、しばらく待つと自動的にアプリの画面（nginx の welcome page）が表示されます。
