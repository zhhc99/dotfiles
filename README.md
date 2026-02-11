# dotfiles

**管理配置文件, 初始化 Linux.**

## 🤔 如何使用

先搞定 git 和 gh.

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

## 💡 Gnome 的 Tray (AppIndicator)

安装包:

```bash
sudo dnf install -y gnome-shell-extension-appindicator
```

注销并重新登录会话, 然后:

```bash
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
```

现在应该能立刻看到应用托盘.

### 解释

Gnome 希望应用统一用它们的方案 (后台应用 + 通知), 这不方便也不切实际. 托盘是现代桌面体验的一部分, 如果希望启用, 就得采用第三方扩展.

扩展可以通过 flatpak 扩展管理器安装, 有的也可以直接用 `dnf` 安装. Gnome 在重新登录会话时才加载通过 `dnf` 安装的扩展, 且默认为禁用状态. 上面的方案解决这个问题.
