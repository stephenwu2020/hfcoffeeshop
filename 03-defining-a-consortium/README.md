03-defining-a-consortium实现["定义联盟"](https://github.com/stephenwu2020/fabric-step-by-step#%E5%AE%9A%E4%B9%89%E8%81%94%E7%9B%9F)这一节的内容。

在上一节的基础上，网络添加了CA2, R2, X1等元素：
* CA2，企业R2的认证文件，在crypto-config.yaml中，定义在PeerOrgs之下，命名CA2.
* R2，企业2，是逻辑上的企业的概念，对应认证机构CA2，定义在configtx.yaml的Organizations之下，命名R2.
* X1，联盟1，R1和R2是联盟X1的成员。联盟内部成员互相交易，实现共同的目标。

**在configtx.yaml的网络配置文件NC4的Consortiums之下，配置了联盟X1，成员R1，R2**