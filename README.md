# faultInjectionLLM  *beta-v1.0*
> faultInjectionLLM 是对任意内核态函数进行错误注入，并基于大模型的推荐注入进行自动化执行系统。底层注入技术依赖于eBPF
> 更多请看此文章https://zhuanlan.zhihu.com/p/2590022381


## 1. 环境安装

- 安装依赖包
```shell
sudo apt install clang libc6-dev-i386 linux-headers-$(uname -r) python3.11-venv tmux
```

- 安装内核编译环境（使用适配faultInjectionLLM的内核可忽略）
```shell
sudo apt install build-essential flex bison dwarves libssl-dev libelf-dev libncurses-dev bc
```

## 2.使用faultInjectionLLM
0. 在仓库根目录创建`.env`文件,并根据实际情况填写。
```yaml
OPENAI_API_KEY=xxxxx
OPENAI_BASE_URL=xxxx
```

1. 启动LLM Server：

    `faultInjectionLLM server` 

2. 添加需要分析的注入点所在源文件（支持手工添加注入点）：

    `faultInjectionLLM add [default | multi | manual] <Absolute-Path-Of-SourceCode-File>`

3. 根据LLM的推荐具体选择注入点以及概率：

    `faultInjectionLLM choose [-i | default]`

4. 验证

    `faultInjectionLLM verify `

5. 生成注入执行程序

    `faultInjectionLLM gen `

6. 执行错误注入程序：

    `faultInjectionLLM tmux [once | progressive]`


## 3. 参数解释
- add 
    - **default**: 默认使用所有的LLM推荐的错误注入点以及错误类型，每个类型被随机触发的概率为5%。
    - **multi**: 使用所有的LLM推荐的错误注入点以及错误类型。
    - **manual**: 手动选择额外的错误注入点以及错误类型，并可以自定义每个概率的触发概率
- choose
    - **-i**: 交互式选择错误注入值以及每个值的概率
    - **default**: 默认（函数的所有错误值都会被触发，都为5%的概率，函数被触发错误的概率为N*0.05,不超过1）

- tmux
    - **once**: 一次性使能所有错误注入点。
    - **progressive**: 每五秒加载一个错误注入点，同时不会覆盖已加载的错误注入点。

## 4.其他使用方法

1. 查看已添加的注入点：

    `faultInjectionLLM list [recommend | select | verified]`

2. 清除历史文件：

    `faultInjectionLLM clean`


## 5.MORE
欢迎使用过程中遇到bug和问题时提交issue。你的意见会使得faultInjectionLLM更加完善！
