# mahan

本项目收集了 CI 自动化构建、Jenkins 配置与服务器运维相关的脚本，以及一些测试文件。

## 仓库用途

本仓库用于学习 git 操作：分支、提交、合并、Pull Request 以及配套的 CI 检查都在这里练习。仓库里的脚本和测试文件是练习用的素材，保留下来是为了有内容可以改，不打算作为正式项目长期维护。

本仓库不用于生产。这些脚本是历史流程的存档，只在原来的内网 Jenkins 环境里用过，搬到别的机器上既跑不通也有实际风险，需要重新审查改造并在隔离环境里验证，不要直接接到线上环境执行。

## 这个代码库是什么

这里存放的是围绕 AnyBackup 产品持续集成流程沉淀下来的运维脚本，不是一个可以直接部署或安装的产品：仓库内没有依赖清单、没有服务源码，也没有脚本所调用的 Jenkins 任务定义。脚本的主要工作是：通过 Jenkins 命令行触发客户端与服务端安装包的构建，把构建产物分发到测试节点完成部署和冒烟测试，同时维护构建归档目录（监控磁盘占用、按保留数量清理旧包），以及批量调整 Jenkins 任务的配置。

仓库另有一部分示例与占位文件（`test.py`、`test.rb`、`index.html`），用于验证仓库自身的检查流程。

## 目录结构

| 路径 | 说明 |
| --- | --- |
| `Foundation_script/` | 脚本主体：Linux Shell 脚本、Windows 批处理与 Windows 命令参数示例 |
| `git_install.sh` | 在基于 yum 的机器上从源码编译安装 Git 2.10.2 |
| `test.py` | 最小 Python 示例：一个 `add()` 函数加一条断言，可直接 `python test.py` 运行 |
| `test.rb` | 占位文件，内容只是若干行数字与字母文本，没有实际的 Ruby 逻辑 |
| `index.html` | 占位文件，内容是几行文本，不是完整网页 |
| `.github/workflows/ci.yml` | GitHub Actions 工作流，见「CI 检查」一节 |

## Foundation_script 中的脚本

| 文件 | 作用 |
| --- | --- |
| `CI_Auto_Build_PKG_BRANCH.sh` | 先下载 `jenkins-cli.jar` 与 `js.jar`，再用 Jenkins CLI 依次触发 `I_P_CLIENT_ALL`、`I_P_SERVER_ALL`、`I_P_CINDERCLIENT`、`I_P_H3CloudOSClient` 四个构建任务，最后触发 `I_P_D_AB_PDT`。要换分支或换产品，改脚本顶部的 `SVN`、`APP_PLATFORM`、`LANG`、`ABPREFIX`、`PKG_TYPE` 等变量 |
| `I_P_D_AB_PDT.sh` | 部署与验收环节：触发服务端部署任务，按 `MY_PKG_APPTYPE` 决定是否重启节点并等待节点上线，再触发 Windows 与 Linux 客户端部署任务、`AT_D_Client_Linux` 客户端测试任务以及 `HAT_5R_SMOKE_RUN_PDT` 冒烟任务，最后从 FTP 归档目录拉取服务端与 Windows、Linux 客户端安装包，并把包名里的 `-LASTEST.` 改成 `-SMOKEOKPDT.` 标记冒烟通过 |
| `Jenkins_Auto_Config.sh` | 批量调整 Jenkins 任务配置：从 SVN 取出视图配置，遍历 `_AB_DEV` 与 `_AB_XIAOJI` 两个视图下的任务，下载各自的 `config.xml` 并留一份带时间戳的备份，再用 `modify_xml` 给 `SVN`、`WKSP` 选项参数追加取值。写回 Jenkins 由 `post_xml` 完成，但它在两个配置函数里被注释掉了，脚本末尾也注释掉了 `config_DEV` 与 `config_XIAOJI`，所以默认只下载、备份并修改本地副本，不会写回 Jenkins |
| `Ftp_Monitor.sh` | 用 `df -h` 检查挂载点的已用比例，超过 98% 时打印告警并退出，当前检查 `/` 与 `/mnt/jenkinsftp/ci-jobs/AB/package` 两处 |
| `Ftp_auto_cleanup.sh` | 递归清理 FTP 归档目录（`basecore`、`client`、`server`、`package/AnyBackup`），每个目录保留最新 40 个文件，更早的删除。目录由第一个参数传入。脚本开头的注释标明它因 FTP 权限与安全考虑已被停用，需要手工拷贝到归档目录所在路径下执行。该文件的中文注释是 GBK 编码，用 UTF-8 打开会显示为乱码 |
| `test.sh` | 与 `Ftp_auto_cleanup.sh` 是同一套清理逻辑，面向另一批归档目录（`package/AnyBackupClient`、`package/AnyBackupServer`、`service`、`module`），保留数量是 50 |
| `auto_PE.bat` | Windows 批处理：从 FTP 下载客户端包，解压后写入 PE 镜像中的产品目录，再删掉镜像里不需要的驱动目录与 `.pdb`、`.lib` 调试文件、更新 `VersionDetails`，最后用 WimTool 重新打包 WIM、用 UltraISO 生成 PE 镜像 ISO。`PLATFORM` 为 `ALL` 时依次生成 i386 与 x64、中英文共四个包。脚本依赖 `E:\EISOOPEMaker` 这个固定目录以及 WimTool、UltraISO、WinRAR |
| `Windows打签名包命令.txt` | 在 Windows 上打签名包前需要设置的环境变量示例（`SVN`、`NEED_CLIENT`、`PKG`、`PKG_TYPE`、`WORKSPACE`、`LANG`、`APP_PLATFORM` 等） |

## CI 检查

`.github/workflows/ci.yml` 在推送到 `master`、针对 `master` 的 Pull Request 以及手动触发时运行，包含两个任务：

- **Python 检查**：用 `python -m compileall -q .` 编译仓库内所有 `.py` 文件，再执行 `python test.py`。
- **Shell 脚本语法检查**：对仓库内所有 `.sh` 文件执行 `bash -n`，找不到任何 `.sh` 文件时视为失败。

本地可以先跑同样的命令，不用等 CI：

```bash
python -m compileall -q .
python test.py
find . -path ./.git -prune -o -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
```

## 使用这些脚本前需要注意

- **环境是写死的。** Jenkins、FTP 归档、SVN 与测试节点的地址都直接写在脚本里，换环境必须先替换。脚本里还留有账号口令，而本仓库是公开仓库，继续保留或分享这些脚本之前，建议先把凭据改成环境变量或凭据管理，并清理历史。
- **这些脚本会真的改东西。** `Jenkins_Auto_Config.sh` 用 `sed -i` 修改任务配置，`Ftp_auto_cleanup.sh` 和 `test.sh` 会删除归档文件，`git_install.sh` 会先 `yum remove git` 再写 `/etc/bashrc`。它们没有参数校验，也没有失败回滚，建议先在隔离环境里跑一遍。
- **流程无法在仓库内复现。** 脚本调用的 Jenkins 任务、SVN 分支和产品源码都不在这个仓库里，所以这里的脚本只能作为流程存档和参考，不能单独跑通。
