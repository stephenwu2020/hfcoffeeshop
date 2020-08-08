01-creating-the-network实现了["创建网络"](https://github.com/stephenwu2020/fabric-step-by-step#%E5%88%9B%E5%BB%BA%E7%BD%91%E7%BB%9C)这一节的内容。

最基本的网络由这些元素组成：CA4，R4，NC4，O4：
* CA4是企业R4的认证文件，同时是O4的认证机构，因此在crypto-config.yaml中，定义在OrdererOrgs之下，命名CA4。
* R4是企业4，是逻辑上的企业的概念，对应认证机构CA4.
* NC4是网络配置，用于生成系统通道的创世块，定义在configtx.yaml的Profiles模块之下。
* O4是隶属于R4的order节点，对应docker-compose.yml的o4.demo.com

**docker-compose.yml里，ORDERER_GENERAL_TLS_XXX相关字段绑定了节点O4与认证文件CA4的关系，从而绑定了O4与企业R4的关系**

执行工程之前，需要下载相关程序，拉去相关镜像:
1. 执行./download-binary.sh，下载相关程序bin目录
2. 添加bin目录至环境变量
3. ./pull-image.sh，拉去fabric相关docker镜像

启动当前网络的步骤如下：
1. ./network.sh crypto，生成认证相关的文件
1. ./network.sh genesis，生成系统channel的创世块
1. ./network.sh up，启动网络，启动docker节点o4.demo.com
1. ./network.sh down，关闭节点
1. ./network.sh clear，删除生成认证文件和创世块文件

