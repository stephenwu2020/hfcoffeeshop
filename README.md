# 从0开始搭建Fabric网络:准备
## 从咖啡馆说起
小明经营一家咖啡馆已有2年时间了。他的咖啡味道独特，花样丰富，深受客户喜爱。随着业务的发展，小明正着手配套相应的软件应用，提高运营效率。经过3天3夜的艰苦探索，决定使用当前最火的技术--区块链，打造自个的咖啡帝国。
## 技术选材
小明打开Google的页面，输入“区块链”，排在首位的是比特币。然而比特币为电子支付而生，不适合他的咖啡馆，于是打开了Ethereum的官网。 多年的商海浮沉磨练了小明的大脑，一个绝妙的Smart Contract已跃然涌现脑海。小明正打算部署Etherem，忽然又打住了。他在想，未来咖啡馆做大了，如何隐藏商业机密不被泄漏，如何分配分店的权限呢？最后，经过深思熟虑，小明认为Hyperledger Fabric的技术，是最适合咖啡馆的，一切就这么定了。
## 环境搭建
跟着[Fabric的指导网站](https://hyperledger-fabric.readthedocs.io/en/master/prereqs.html)走，小明安装了git,curl,docker, docker compose等等软件，创建了[Github Reposity](https://github.com/stephenwu2020/hfcoffeeshop).
## Fabric镜像、工具软件部署
小明为咖啡馆网络创建了Github Reposity，仓库名字就叫[hfcoffeeshop](https://github.com/stephenwu2020/hfcoffeeshop)。为了方便拉取Fabric镜像，以及配置网络需要用到的软件，小明配置了简单的Makefile，在项目的根目录下执行：
```
make
```
将会调用`bootstrap.sh`，拉取镜像、下载bin软件，之后，项目根目录会产生两个文件夹: bin和config。执行：
```
docker images
```
确认fabric的镜像已经拉取：
```
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
hyperledger/fabric-tools     2.2                 5eb2356665e7        4 weeks ago         519MB
hyperledger/fabric-tools     2.2.0               5eb2356665e7        4 weeks ago         519MB
hyperledger/fabric-tools     latest              5eb2356665e7        4 weeks ago         519MB
hyperledger/fabric-peer      2.2                 760f304a3282        4 weeks ago         54.9MB
hyperledger/fabric-peer      2.2.0               760f304a3282        4 weeks ago         54.9MB
hyperledger/fabric-peer      latest              760f304a3282        4 weeks ago         54.9MB
hyperledger/fabric-orderer   2.2                 5fb8e97da88d        4 weeks ago         38.4MB
hyperledger/fabric-orderer   2.2.0               5fb8e97da88d        4 weeks ago         38.4MB
hyperledger/fabric-orderer   latest              5fb8e97da88d        4 weeks ago         38.4MB
hyperledger/fabric-ccenv     2.2                 aac435a5d3f1        4 weeks ago         586MB
hyperledger/fabric-ccenv     2.2.0               aac435a5d3f1        4 weeks ago         586MB
hyperledger/fabric-ccenv     latest              aac435a5d3f1        4 weeks ago         586MB
hyperledger/fabric-baseos    2.2                 aa2bdf8013af        4 weeks ago         6.85MB
hyperledger/fabric-baseos    2.2.0               aa2bdf8013af        4 weeks ago         6.85MB
hyperledger/fabric-baseos    latest              aa2bdf8013af        4 weeks ago         6.85MB
hyperledger/fabric-nodeenv   2.2                 ab88fe4d29dd        5 weeks ago         293MB
hyperledger/fabric-nodeenv   2.2.0               ab88fe4d29dd        5 weeks ago         293MB
hyperledger/fabric-nodeenv   latest              ab88fe4d29dd        5 weeks ago         293MB
hyperledger/fabric-javaenv   2.2                 56c30f316b23        5 weeks ago         504MB
hyperledger/fabric-javaenv   2.2.0               56c30f316b23        5 weeks ago         504MB
hyperledger/fabric-javaenv   latest              56c30f316b23        5 weeks ago         504MB
hyperledger/fabric-ca        1.4                 743a758fae29        2 months ago        154MB
hyperledger/fabric-ca        1.4.7               743a758fae29        2 months ago        154MB
hyperledger/fabric-ca        latest              743a758fae29        2 months ago        154MB
```
注：
- 大陆地区执行`bootstrap.sh`及docker镜像的拉取，可能会遇到网络问题。
- 源码地址: [hfcoffeeshop](https://github.com/stephenwu2020/hfcoffeeshop)

# 从0开始搭建Fabric网络:Orderer
##  创建网络
Fabric网络的重中之重是orderer节点。交易是如何在Fabric网络处理的呢？假设客户要买一杯咖啡，首先，在peer节点创建交易信息，随后发送给orderer节点，orderer把多个交易打包成区块，再把区块发送给peer节点，写入ledger中。
为此，小明决定先创建只有一个orderer节点的网络，并且打了一份配置草稿：
- 网络名称: `coffeeshop.com`
- orderer名称: `orderer.coffeesop.com`
- orderer类型： EtcdRaft
- orderer数量：1

## 现在进入正式编码环节
第一、Fabric中，所有的资源都必须认证，我们首先创建orderer的证书文件：
1. 创建文件夹： 01-creating-the-network
2. 进入文件夹，创建文件：crypto-config.yaml，添加以下内容：
   ```
   OrdererOrgs:
    - Name: Orderer
      Domain: coffeeshop.com
      EnableNodeOUs: true
      Specs:
        - Hostname: orderer
          SANS:
            - localhost
   ```
3. 执行创建证书的指令:
   ```
   ./network.sh crypto
   ```
   证书文件存放在organizations目录下

第二、定义网络的组织形式，创建文件configtx.yaml，这里大部分内容是默认配置，有几点需要解释:
1. Orderer的配置，指定类型etcdraft，配置tls证书的路径：
    ```
    Orderer: &OrdererDefaults
        OrdererType: etcdraft

        EtcdRaft:
            Consenters:
            - Host: orderer.coffeeshop.com
              Port: 7050
              ClientTLSCert: ./organizations/ordererOrganizations/coffeeshop.com/orderers/orderer.coffeeshop.com/tls/server.crt
              ServerTLSCert: ./organizations/ordererOrganizations/coffeeshop.com/orderers/orderer.coffeeshop.com/tls/server.crt
        Addresses:
            - orderer.coffeeshop.com:7050
        ......
    ```
2. 全局通道的配置：
    ```
    Profiles:
        Genesis:
            <<: *ChannelDefaults
            Orderer:
                <<: *OrdererDefaults
                Organizations:
                    - *Orderer
                Capabilities:
                    <<: *OrdererCapabilities
            Consortiums:
                SampleConsortium:
                    Organizations:
    ```
3. Fabric的创世块就是依据此文件产生的。执行创建创世块的指令: 
   ```
   ./network.sh genesis
   ```
   创世块存放路径为: ./system-genesis-block/genesis.block 

第三、编写orderer的容器文件: docker-compose.yml:
```
version: '2'

networks:
  basic:

services:
  orderer.coffeeshop.com:
    container_name: orderer.coffeeshop.com
    image: hyperledger/fabric-orderer:$IMAGE_TAG
    environment:
      - FABRIC_LOGGING_SPEC=info
      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
      - ORDERER_GENERAL_BOOTSTRAPMETHOD=file
      - ORDERER_GENERAL_BOOTSTRAPFILE=/etc/hyperledger/configtx/genesis.block
      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      - ORDERER_GENERAL_LOCALMSPDIR=/etc/hyperledger/msp/orderer/msp
        # enabled TLS
      - ORDERER_GENERAL_TLS_ENABLED=true
      - ORDERER_GENERAL_TLS_PRIVATEKEY=/etc/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_TLS_CERTIFICATE=/etc/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_TLS_ROOTCAS=[/etc/hyperledger/orderer/tls/ca.crt]
      - ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR=1
      - ORDERER_KAFKA_VERBOSE=true
      - ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=/etc/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=/etc/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_CLUSTER_ROOTCAS=[/etc/hyperledger/orderer/tls/ca.crt]
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/orderer
    command: orderer
    ports:
      - 7050:7050
    volumes:
        - ./system-genesis-block/:/etc/hyperledger/configtx
        - ./organizations/ordererOrganizations/coffeeshop.com/orderers/orderer.coffeeshop.com/:/etc/hyperledger/msp/orderer
        - ./organizations/ordererOrganizations/coffeeshop.com/orderers/orderer.coffeeshop.com/msp:/etc/hyperledger/orderer/msp
        - ./organizations/ordererOrganizations/coffeeshop.com/orderers/orderer.coffeeshop.com/tls/:/etc/hyperledger/orderer/tls

    networks:
      - basic
```
执行启动网络的指令:
```
./network.sh up
```
此时orderer节点已经启动，执行 docker ps 可以看到orderer的运行状态：
```
CONTAINER ID        IMAGE                              COMMAND             CREATED             STATUS              PORTS                    NAMES
df23933ad957        hyperledger/fabric-orderer:2.2.0   "orderer"           4 seconds ago       Up 2 seconds        0.0.0.0:7050->7050/tcp   orderer.coffeeshop.com
```
咖啡馆网络的启动工作就大功告成了

## 网络示意图
![orderer](/book/fabric/coffee01.png)

## 命令讲解
./networks.sh每一个命令相对应一个操作：
- 创建证书: ./network.sh crypto
- 创建创世块: ./network.sh genesis
- 启动网络: ./network.sh up
- 关闭网络： ./network.sh down
- 清理目录：./network.sh clear
- 启动网络一步到位： ./network.sh custom

注：
- 这一节的所有文件存放在[01-creating-the-network](https://github.com/stephenwu2020/hfcoffeeshop/tree/master/01-creating-the-network)目录

# 从0开始搭建Fabric网络:管理
## 添加管理组织
小明的咖啡馆网络已经启动了，然而当前并不能做什么。Orderer就像企业的管理层，他们成天策划方案，但具体落实的，是底层的员工。在Fabric中扮演这个角色的是Peer节点。
经过一番大脑风暴，小明打好了第一个Peer节点草稿：
- peer名称：`ming.coffeeshop.com`
- peer权限：管理权限
- peer数量：1

## 现在开始编写peer节点配置
第一，创建目录 02-adding-network-administrators，并且进入该目录：
```
mkdir 02-adding-network-administrators
cd 02-adding-network-administrators
```

第二，在crypto-config.yaml配置peer信息：
```
PeerOrgs:
  - Name: Ming
    Domain: ming.coffeeshop.com
    EnableNodeOUs: true
    Template:
      Count: 1
    Users:
      Count: 2
```

第三，在configtx.yaml配置peer的组织信息:
```
    - &Ming
        Name: Ming
        ID: MingMSP
        MSPDir: ./organizations/peerOrganizations/ming.coffeeshop.com/msp
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('MingMSP.admin', 'MingMSP.peer', 'MingMSP.client')"
            Writers:
                Type: Signature
                Rule: "OR('MingMSP.admin', 'MingMSP.client')"
            Admins:
                Type: Signature
                Rule: "OR('MingMSP.admin')"
            Endorsement:
                Type: Signature
                Rule: "OR('MingMSP.peer')"
```
同时，将peer设置为网络组织：
```
Profiles:
    Genesis:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *Orderer
                - *Ming
            Capabilities:
                <<: *OrdererCapabilities
        Consortiums:
            SampleConsortium:
                Organizations:
```
第四，启动网络:
```
./network.sh custom
```

## 网络示意图
![admin](/book/fabric/coffee02.png)

注:
- 在这一节中，重点是配置peer节点，相应组织Ming添加为网络管理组织，而peer节点的容器尚未启动
- 本节的源码位于[02-adding-network-administrators](https://github.com/stephenwu2020/hfcoffeeshop/tree/master/02-adding-network-administrators)

# 从0开始搭建Fabric网络:联盟
## 定义联盟
要理解联盟，得搞清楚Fabric与链的关系。Fabric管理网络如何运行，谁可以加入，谁是管理员，但成员之间的生意，fabric是不管的。成员之间是如何做生意的呢？首先，成员自发成立一个联盟，或者说集团，邀请其他成员加入。同一个联盟的成员之间互相交易，交易的数据被记录在区块之中。这个联盟就是一条链。同一个成员可以加入多个联盟，每个联盟可以组织多个成员，这样就形成了各种各种的链。
小明的咖啡馆网络运行后，要开始真正的生意，必须有组织成立联盟，加入联盟。本节的任务非常简单：把企业Ming加入联盟。

第一，创建目录 03-defining-a-consortium，并且进入该目录
```
mkdir 03-defining-a-consortium
cd 03-defining-a-consortium
```

第二，在configtx.yaml中，定义联盟X1，定一个Ming为X1的成员:
```
        Consortiums:
            SampleConsortium:
                Organizations:
            X1:
                Organizations:
                    - *Ming
```
## 网络示意图
![consortium](/book/fabric/coffee03.png)
注：
- 本节源码位于: [03-defining-a-consortium](https://github.com/stephenwu2020/hfcoffeeshop/tree/master/03-defining-a-consortium)

# 从0开始搭建Fabric网络:Channel
## 定义channel
上一节，小明定义了一个联盟X1，并且把企业Ming加入至联盟中。Channel与联盟，其实是同一个东西的不同表现。联盟在Fabric技术上的实现就是channel。企业之间结成联盟，在技术上就是指企业对应的peer节点加入同一个channel。

## 现在开始添加channel
第一，创建目录04-creating-a-channel, 进入该目录：
```
mkdir 04-creating-a-channel
cd 04-creating-a-channel
```

第二，在configtx.yaml中定义channel
```
    CC1:
        Consortium: X1
        <<: *ChannelDefaults
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - *Ming
            Capabilities:
                <<: *ApplicationCapabilities
```
第三，在docker-compose.yaml中定义cli容器，用于创建channel
```
  cli:
    container_name: cli
    image: hyperledger/fabric-tools:$IMAGE_TAG
    tty: true
    stdin_open: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      #- FABRIC_LOGGING_SPEC=DEBUG
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_ID=cli
      - CORE_PEER_ADDRESS=ming.coffeeshop.com:7051
      - CORE_PEER_LOCALMSPID=MingMSP
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/tls/ca.crt
      - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/users/Admin@ming.coffeeshop.com/msp
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: /bin/bash
    volumes:
        - /var/run/:/host/var/run/
        - ./organizations:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
        - ./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
    depends_on:
      - orderer.coffeeshop.com
    networks:
      - basic
```
第四，启动网络:
```
./network.sh custom
```
## 检查docker容器状态
```
docker ps
CONTAINER ID        IMAGE                              COMMAND             CREATED             STATUS              PORTS                    NAMES
e04af9c615ad        hyperledger/fabric-tools:2.2.0     "/bin/bash"         5 minutes ago       Up 5 minutes                                 cli
9fccfa81938a        hyperledger/fabric-orderer:2.2.0   "orderer"           5 minutes ago       Up 5 minutes        0.0.0.0:7050->7050/tcp   orderer.coffeeshop.com
```
## 网络示意图
![consortium](/book/fabric/coffee04.png)

## 解释命令
执行./network.sh custom过程中，分别执行了下列的命令：
- clear： 清空上一次创建的网络
- crypto： 创建证书文件
- genesis： 创建创世块
- up：启动docker容器(orderer和cli)
- createChanTx: 这是本节新加的命令，用于创建交易数据./channel-artifacts/c1.tx
- createChan: 这是本节新加的命令，用于创建区块数据./channel-artifacts/c1.block

注：
- 本节源码位于：[04-creating-a-channel](https://github.com/stephenwu2020/hfcoffeeshop/tree/master/04-creating-a-channel)

# 从0开始搭建Fabric网络:Peer
## 记录区块的Peer
Peer的主要任务有：
- 接受客户请求，创建交易
- 发送交易至orderer
- 接收orderer的区块
- 将区块写入本地数据库

## 现在开始部署Peer节点
第一，创建目录05-peers-and-ledgers，进入该目录
```
mkdir 05-peers-and-ledgers
cd 05-peers-and-ledgers
```
第二，修改configtx.yaml，为企业Ming定义anchor peer:
```
        AnchorPeers:
            # AnchorPeers defines the location of peers which can be used
            # for cross org gossip communication.  Note, this value is only
            # encoded in the genesis block in the Application section context
            - Host: peer0.ming.coffeeshop.com
              Port: 7051
```
第三，为企业Ming添加peer的容器，修改docker-compose.yaml:
```
  peer0.ming.coffeeshop.com:
    container_name: peer0.ming.coffeeshop.com
    image: hyperledger/fabric-peer:$IMAGE_TAG
    environment:
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_test
      - FABRIC_LOGGING_SPEC=info
      # peer env
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
      # Peer specific variabes
      - CORE_PEER_ID=peer0.ming.coffeeshop.com
      - CORE_PEER_ADDRESS=peer0.ming.coffeeshop.com:7051
      - CORE_PEER_LISTENADDRESS=0.0.0.0:7051
      - CORE_PEER_CHAINCODEADDRESS=peer0.ming.coffeeshop.com:7052
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.ming.coffeeshop.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.ming.coffeeshop.com:7051
      - CORE_PEER_LOCALMSPID=MingMSP

    working_dir: /opt/gopath/src/github.com/hyperledger/fabric
    command: peer node start
    ports:
      - 7051:7051
    volumes:
        - /var/run/:/host/var/run/
        - ./system-genesis-block:/etc/hyperledger/configtx
        - ./organizations/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/msp:/etc/hyperledger/fabric/msp
        - ./organizations/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/tls:/etc/hyperledger/fabric/tls
        - ./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
        - ./organizations:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
    networks:
      - basic
```
第四，启动网络:
```
./network.sh custom
```
## 检查docker容器状态
```
docker ps
CONTAINER ID        IMAGE                              COMMAND             CREATED             STATUS              PORTS                    NAMES
b87e39044118        hyperledger/fabric-tools:2.2.0     "/bin/bash"         45 seconds ago      Up 44 seconds                                cli
733c894838be        hyperledger/fabric-peer:2.2.0      "peer node start"   47 seconds ago      Up 44 seconds       0.0.0.0:7051->7051/tcp   peer0.ming.coffeeshop.com
8ad4281a376c        hyperledger/fabric-orderer:2.2.0   "orderer"           47 seconds ago      Up 45 seconds       0.0.0.0:7050->7050/tcp   orderer.coffeeshop.com
```

## 网络示意图
![consortium](/book/fabric/coffee05.png)

## 命令解释
执行./network.sh custom启动网络，其中新增的命令是:
- joinChan: 将peer加入channel
- setAnchor：设置企业Ming的anchor peer为`peer0.ming.coffeeshop.com`
- listChan: 查看当前channel的信息

注：
- 本节源码位于:[05-peers-and-ledgers](https://github.com/stephenwu2020/hfcoffeeshop/tree/master/05-peers-and-ledgers)

# 从0开始搭建Fabric网络:链码
Fabric的商业逻辑通过chaincode，即链码来实现。链码的作用，简单来说，就是操作Fabric的数据库，修改变量的值，同时给Fabric之外的应用程序提供操作接口。

## 现在开始为我们的咖啡馆网络部署链码

第一，创建目录06-smart-contract-chaincode，并且进入该目录
```
mkdir 06-smart-contract-chaincode
cd 06-smart-contract-chaincode
```

第二，此前网络已经成型，配置文件无需修改

第三，链码的操作相对来说比较复杂，因此修改了shell脚本的逻辑，新增的`builder.sh`大致思路如下：
1. 操作分割为三个模块：网络操作，channel操作，chaincode操作，对应./scripts下的三个文件
2. 网络相关操作：./builder.sh network
3. channel相关操作：./builder.sh channel
4. chaincode相关操作：./builder.sh chaincode
   
由于网络操作，channel操作已经在前面介绍，这里快速启动网络，创建channel，加入channel：
```
./builder.sh network custom
./builder.sh channel custom
```

第四，下面集中讲解chaincode的操作:
1.  我们将要部署的链码位于根目录下的./chaincode/abstore/go
2.  执行打包指令，会在./pkg目录下生成mycc.tar.gz包：
    ```
    ./builder.sh chaincode package
    ```
3. 执行安装指令：
    ```
    ./builder.sh chaincode install
    ```
4. 执行approve指令，可以理解为，这个代码我审核了，我支持它运行：
    ```
    ./builder.sh chaincode approve
    ```
5. 执行commit指令
    ```
    ./builder.sh chaincode commit
    ```
6. 执行invoke指令，进行实例化：
    ```
    ./builder.sh chaincode invoke
    ```
7. 执行query指令，查询：
    ```
    ./builder.sh chaincode query
    ```
熟悉上述操作之后，将他们合并成custom指令，免得一句一句从新打

## 查看容器的状态
```
CONTAINER ID        IMAGE                                                                                                                                                                       COMMAND                  CREATED             STATUS              PORTS                    NAMES
ef2e285c572a        dev-peer0.ming.coffeeshop.com-abstore_1-bf43a0391f5bac984beb7e55751e7f33432c517800406c12b6a2fd789480fe95-79103ebc9b8d25cd59dfd065e96be85d38c4f6332047cc67349cabdcd3fc0c23   "chaincode -peer.add…"   7 minutes ago       Up 7 minutes                                 dev-peer0.ming.coffeeshop.com-abstore_1-bf43a0391f5bac984beb7e55751e7f33432c517800406c12b6a2fd789480fe95
41ec607e9883        hyperledger/fabric-tools:2.2.0                                                                                                                                              "/bin/bash"              15 minutes ago      Up 15 minutes                                cli
49d5ecbf55bd        hyperledger/fabric-orderer:2.2.0                                                                                                                                            "orderer"                15 minutes ago      Up 15 minutes       0.0.0.0:7050->7050/tcp   orderer.coffeeshop.com
70ff2d210d98        hyperledger/fabric-peer:2.2.0                                                                                                                                               "peer node start"        15 minutes ago      Up 15 minutes       0.0.0.0:7051->7051/tcp   peer0.ming.coffeeshop.com
```
发现多了一个容器，以dev-peer0.ming.coffeeshop.com开头，这个是链码执行的容器
好了，链码部署成功！

## 网络示意图
![consortium](/book/fabric/coffee06.png)

注
- 本节源码位于:[06-smart-contract-chaincode](https://github.com/stephenwu2020/hfcoffeeshop/tree/master/06-smart-contract-chaincode)