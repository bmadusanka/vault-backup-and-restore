# vault-backup-and-restore

* This repo consist of a script which can use to backup and restore vault secrets for specific path.
* usually vault is backup through the backend. for example, if you use consul as a backend you can
  backup consul and restore it. but incase if you are migrating to new vault version and you don't
  need everything (users,policies,approle,etc..) to backup and just need to backup secret you can
  use this script.

# Usage

```shell
$ git clone https://github.com/bmadusanka/vault-backup-and-restore.git
```

## Backup

```shell
$ gem install bundler

$ bbundle install

$ ./vault_recovery.rb backup --path=<secret-mount-path> --token=TOKEN --url=URL
```

## Restore

```shell
$ ./vault_recovery.rb restore --file-path=<FILE_PATH> --token=TOKEN --url=URL
```
