# GitHub Actions 工作流说明

本目录包含了 opbnb 项目的 GitHub Actions 工作流配置。

## Docker 镜像构建工作流

### 1. build-image.yml
这个工作流用于构建完整的 opbnb 项目镜像并推送到 GitHub Container Registry (GHCR)。

**触发条件：**
- 推送到 `main`、`develop` 或 `feat-*` 分支
- 手动触发 (workflow_dispatch)

**生成的镜像：**
- `ghcr.io/zypher-game/opbnb:latest` (仅在默认分支)
- `ghcr.io/zypher-game/opbnb:<branch-name>`
- `ghcr.io/zypher-game/opbnb:<branch>-<sha>`

### 2. build-components.yml
这个工作流用于构建各个组件的独立镜像并推送到 GHCR。

**触发条件：**
- 推送到 `main`、`develop` 分支
- 手动触发，可以指定自定义镜像标签

**生成的镜像：**
- `ghcr.io/zypher-game/op-node`
- `ghcr.io/zypher-game/op-batcher`
- `ghcr.io/zypher-game/op-proposer`
- `ghcr.io/zypher-game/op-bootnode`

每个镜像都会有以下标签：
- `latest` (仅在默认分支)
- `<branch-name>`
- `<git-sha>` 或自定义标签

## 与 zytron-optimism 的对比

这些工作流参考了 `zytron-optimism` 项目的 CI 配置：

1. **build-image.yml** 类似于 `zytron-optimism/img.yaml`，用于构建主项目镜像
2. **build-components.yml** 类似于 `zytron-optimism/release-docker-canary.yml`，用于构建各个组件

## 使用说明

### 自动构建
当代码推送到指定分支时，工作流会自动运行并构建镜像。

### 手动触发
可以在 GitHub Actions 页面手动触发工作流：
1. 进入 Actions 页面
2. 选择对应的工作流
3. 点击 "Run workflow"
4. 对于 `build-components.yml`，可以指定自定义镜像标签

### 权限要求
工作流需要以下权限：
- `contents: read` - 读取仓库内容
- `packages: write` - 推送到 GHCR

这些权限通过 `GITHUB_TOKEN` 自动提供。

## 镜像缓存
所有工作流都启用了 GitHub Actions 缓存，可以加速后续构建。 