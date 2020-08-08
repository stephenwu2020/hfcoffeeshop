04-creating-a-channel实现["为联盟建立通道"](https://github.com/stephenwu2020/fabric-step-by-step#%E4%B8%BA%E8%81%94%E7%9B%9F%E5%BB%BA%E7%AB%8B%E9%80%9A%E9%81%93)这一节的内容。

在上一节的基础上，网络添加了通道配置CC1，通道C1等元素：
* CC1，通道的配置，定义在configtx.yaml的Profiles之下。
* C1，根据配置CC1建立的通道。

**docker-compose.yml文件定义了cli节点，cli预装了创建通道的工具，下文通道，智能合约相关的命令，都会通过cli发送请求，peer节点或者order节点处理请求的方式运作。**

### 执行流程

1. ./network.sh crypto 生成CA
1. ./network.sh genesis 生成系统通道的创世块
1. ./network.sh channeltx 生成通道C1的交易数据
1. ./network.sh up 启动网络
1. ./network.sh channel 创建通道C1，生成通道C1的创世块
1. ./network.sh down 关闭网络
1. ./network.sh clear 清空生成文件

**channeltx命令生成创建通道的交易./channel-artifacts/c1.tx**

**channel命令，将创建通道tx发送到order执行，返回channel.block，为通道的创世块。**

**Hyperledger Fabric的通道相对于bitcoin,ethereum的链，所以每个通道都有对应的创世块。**