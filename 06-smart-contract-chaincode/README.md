06-smart-contract-chaincode实现["应用程序与智能合约，链码"](https://github.com/stephenwu2020/fabric-step-by-step#%E5%BA%94%E7%94%A8%E7%A8%8B%E5%BA%8F%E4%B8%8E%E6%99%BA%E8%83%BD%E5%90%88%E7%BA%A6%E9%93%BE%E7%A0%81)这一节的内容。

在上一节的基础上，网络添加了A1, S5等元素：
* A1，企业R1的应用程序。
* S5，智能合约。

chaincode.sh实现了智能合约打包，安装，背书，调用等相关命令。
原有network.sh的功能，以及channel.sh，chaincode.sh共同整合到builder.sh。

执行程序：
* ./builder.sh start
* ./builder.sh end

**实际上，这一节添加了企业R2的节点peer2，否则智能合约无法得到充分授权**
