# dotfiles

**管理配置文件, 初始化 Linux.**

## 🤔 如何使用

先搞定 git 和 gh, 不然没法使用这个仓库.

```bash
sudo dnf install gh git -y
gh auth login
```

然后 clone 仓库到本地 (建议: `~/dotfiles`), 执行:

```bash
sudo ./bootstrap.sh
```

脚本会给配置文件创建软链接, 安装服务和软件.

> 因为使用了 stow --adopt, 本地配置会全部变成软链接 (**此时可能更新仓库**, 若本地有个默认配置记得 `git checkout` 恢复). 后续只要维护本地仓库就可以了.

## 🥺 如何维护

- **配置**: 将新增的配置文件按需放置到仓库的 `home` 或 `system`.
- **服务**: 在 `bootstrap.sh` 中维护.
- **软件**: 在 `bootstrap.sh` 中维护.
