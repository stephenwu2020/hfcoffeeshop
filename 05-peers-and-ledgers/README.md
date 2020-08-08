05-peers-and-ledgers实现["节点与账本"](https://github.com/stephenwu2020/fabric-step-by-step#%E8%8A%82%E7%82%B9%E4%B8%8E%E8%B4%A6%E6%9C%AC)这一节的内容。

在上一节的基础上，网络添加了P1和L1的元素：
* P1，节点1，记录账本L1，给应用程序提供访问服务。
* L1，通道C1的账本。

节点与通道相关指令：
* ./network.sh join 节点加入channel
* ./network.sh anchor 设置peer的anchor信息

执行：
* ./network start
* ./network end