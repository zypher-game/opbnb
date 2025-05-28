# GitHub Actions 工作流说明

本目录包含了 opbnb 项目的 GitHub Actions 工作流配置。

## Docker 镜像构建工作流

### 1. build-image.yml - 统一镜像构建
这个工作流使用根目录的 Dockerfile 构建包含所有组件的统一镜像并推送到 GitHub Container Registry (GHCR)。

**触发条件：**
- 推送到 `main`、`develop` 或 `feat-*` 分支
- 手动触发 (workflow_dispatch)

**生成的镜像：**
- `ghcr.io/zypher-game/opbnb:latest` (仅在默认分支)
- `ghcr.io/zypher-game/opbnb:<branch-name>`
- `ghcr.io/zypher-game/opbnb:<branch>-<sha>`

**镜像包含的组件：**
- op-node
- op-batcher  
- op-proposer

### 2. build-components.yml - 手动统一构建
这个工作流提供手动触发的统一镜像构建，支持更多自定义选项。

**触发条件：**
- 仅手动触发 (workflow_dispatch)
- 可以指定自定义镜像标签
- 可以选择是否推送到注册表

**特性：**
- 支持自定义镜像标签
- 可以选择仅构建不推送（用于测试）
- 使用相同的根目录 Dockerfile

## 统一镜像架构

现在 opbnb 项目使用统一的 Docker 镜像架构：

- **单一镜像**: 所有组件都打包在一个镜像中
- **多个二进制文件**: 镜像包含 op-node、op-batcher、op-proposer 三个可执行文件
- **灵活部署**: 可以通过不同的启动命令运行不同的组件

### 使用方式

```bash
# 运行 op-node
docker run ghcr.io/zypher-game/opbnb:latest ./op-node [args]

# 运行 op-batcher  
docker run ghcr.io/zypher-game/opbnb:latest ./op-batcher [args]

# 运行 op-proposer
docker run ghcr.io/zypher-game/opbnb:latest ./op-proposer [args]
```

## 与 zytron-optimism 的对比

这些工作流参考了 `zytron-optimism` 项目的 CI 配置，但采用了统一镜像的方式：

1. **build-image.yml** 类似于 `zytron-optimism/img.yaml`，但构建统一镜像
2. **build-components.yml** 提供手动构建选项，替代了原来的多组件构建

## Dockerfile 架构

### 根目录 Dockerfile (已验证)
- 使用 `golang:1.22-bookworm` 作为构建基础镜像
- 支持多平台构建 (linux/amd64, linux/arm64)
- 直接使用 `go build` 命令构建各个组件
- 避免了交叉编译工具链下载的问题

### 组件 Dockerfile (已修复但不再使用)
为了兼容性，我们保留了各个组件的 Dockerfile 并修复了构建问题：
- `op-node/Dockerfile`
- `op-batcher/Dockerfile` 
- `op-proposer/Dockerfile`
- `op-bootnode/Dockerfile`

**修复内容：**
1. 移除了对 ARM64 交叉编译工具链的下载依赖
2. 直接使用 `go build` 命令而不是 `make` 命令
3. 在构建时正确设置 Git 信息和版本号

## 使用说明

### 自动构建
当代码推送到指定分支时，`build-image.yml` 工作流会自动运行并构建统一镜像。

### 手动触发
可以在 GitHub Actions 页面手动触发工作流：

#### build-image.yml
1. 进入 Actions 页面
2. 选择 "Building Images" 工作流
3. 点击 "Run workflow"

#### build-components.yml  
1. 进入 Actions 页面
2. 选择 "Build Unified Image (Alternative)" 工作流
3. 点击 "Run workflow"
4. 可以指定：
   - 自定义镜像标签
   - 是否推送到注册表

### 权限要求
工作流需要以下权限：
- `contents: read` - 读取仓库内容
- `packages: write` - 推送到 GHCR

这些权限通过 `GITHUB_TOKEN` 自动提供。

## 镜像缓存
所有工作流都启用了 GitHub Actions 缓存，可以加速后续构建。

## 故障排除

如果遇到构建错误，请检查：
1. 根目录 Dockerfile 语法是否正确
2. 依赖的文件和目录是否存在
3. Go 模块是否能正确下载
4. 构建环境是否有足够的资源

## 迁移说明

从单独组件镜像迁移到统一镜像：

**之前：**
```bash
docker run ghcr.io/zypher-game/op-node:latest
docker run ghcr.io/zypher-game/op-batcher:latest  
docker run ghcr.io/zypher-game/op-proposer:latest
```

**现在：**
```bash
docker run ghcr.io/zypher-game/opbnb:latest ./op-node
docker run ghcr.io/zypher-game/opbnb:latest ./op-batcher
docker run ghcr.io/zypher-game/opbnb:latest ./op-proposer
``` 