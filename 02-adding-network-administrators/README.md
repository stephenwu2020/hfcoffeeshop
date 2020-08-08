02-adding-network-administrators实现["添加网络管理员"](https://github.com/stephenwu2020/fabric-step-by-step#%E6%B7%BB%E5%8A%A0%E7%BD%91%E7%BB%9C%E7%AE%A1%E7%90%86%E5%91%98)这一节的内容。

在上一节的基础上，网络添加了CA1, R1等元素：
* CA1，企业R1的认证文件，在crypto-config.yaml中，定义在PeerOrgs之下，命名CA1.
* R1，企业1，是逻辑上的企业的概念，对应认证机构CA1，定义在configtx.yaml的Organizations之下，命名R1.

**通过configtx.yaml，Profiles，NC4中的Organizations字段，把R1添加为管理员。**