# 迁移到统一镜像指南

本文档说明如何从原有的 `zytron-optimism` 镜像迁移到新的 `opbnb` 统一镜像。

## 主要变化

### 1. 镜像名称变更

**之前：**
```yaml
op-node:
  image: ghcr.io/zypher-game/zytron-optimism:feat-da-530ae63-1722483938624

op-batcher:
  image: ghcr.io/zypher-game/zytron-optimism:feat-da-530ae63-1722483938624

op-proposer:
  image: ghcr.io/zypher-game/zytron-optimism:feat-da-530ae63-1722483938624
```

**现在：**
```yaml
op-node:
  image: ghcr.io/zypher-game/opbnb:latest

op-batcher:
  image: ghcr.io/zypher-game/opbnb:latest

op-proposer:
  image: ghcr.io/zypher-game/opbnb:latest
```

### 2. 命令格式保持不变

统一镜像中的命令格式与原来相同：
```yaml
command: ["./op-node"]
command: ["./op-batcher"]
command: ["./op-proposer"]
```

### 3. 环境变量完全兼容

所有环境变量配置保持不变，无需修改。

## 迁移步骤

### 步骤 1: 更新 docker-compose.yml

只需要将镜像名称从：
```yaml
image: ghcr.io/zypher-game/zytron-optimism:feat-da-530ae63-1722483938624
```

更改为：
```yaml
image: ghcr.io/zypher-game/opbnb:latest
```

### 步骤 2: 验证配置

使用提供的 `docker-compose.production.yml` 作为参考，确保所有配置正确。

### 步骤 3: 重新部署

```bash
# 停止现有服务
docker-compose down

# 拉取新镜像
docker-compose pull

# 启动服务
docker-compose up -d
```

## 配置文件对比

### 原配置 (你提供的)
- 使用 `ghcr.io/zypher-game/zytron-optimism:feat-da-530ae63-1722483938624`
- 容器名称：`zytron-op-node`, `zytron-op-batcher`, `zytron-op-proposer`

### 新配置 (推荐)
- 使用 `ghcr.io/zypher-game/opbnb:latest`
- 容器名称：`opbnb-node`, `opbnb-batcher`, `opbnb-proposer`

## 兼容性说明

✅ **完全兼容的部分：**
- 所有环境变量
- 端口映射
- 卷挂载
- 健康检查
- 依赖关系
- 命令格式

⚠️ **需要注意的部分：**
- 容器名称变更（如果有其他服务依赖容器名称）
- 镜像标签策略（建议使用具体版本而不是 `latest`）

## 版本标签策略

### 推荐使用具体版本标签：

```yaml
# 使用分支+SHA标签（推荐）
image: ghcr.io/zypher-game/opbnb:main-abc1234

# 使用latest标签（开发环境）
image: ghcr.io/zypher-game/opbnb:latest

# 使用分支标签
image: ghcr.io/zypher-game/opbnb:main
```

## 验证迁移

迁移完成后，验证服务是否正常运行：

```bash
# 检查服务状态
docker-compose ps

# 检查日志
docker-compose logs op-node
docker-compose logs op-batcher
docker-compose logs op-proposer

# 检查健康状态
docker-compose exec op-node curl -s 127.0.0.1:9545
```

## 回滚计划

如果需要回滚到原镜像：

```bash
# 停止服务
docker-compose down

# 修改 docker-compose.yml 恢复原镜像名称
# image: ghcr.io/zypher-game/zytron-optimism:feat-da-530ae63-1722483938624

# 重新启动
docker-compose up -d
```

## 优势

使用新的统一镜像的优势：

1. **统一管理**: 所有组件使用同一个镜像，便于版本管理
2. **自动构建**: 通过 CI/CD 自动构建和发布
3. **多平台支持**: 支持 AMD64 和 ARM64 架构
4. **缓存优化**: 使用 GitHub Actions 缓存加速构建
5. **标签规范**: 提供多种标签策略满足不同需求