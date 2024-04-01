# OpenSSL 自签署证书生成

原文地址：<https://wangyan.craft.me/C8Vss6BJmtOGrM>

## 一、准备

克隆项目

```shell
git clone https://code.wangyan.cloud/wangyan/gen-ssl-cert.git /tmp/gen-ssl-cert
```

初始化工作目录

```shell
cd /tmp/gen-ssl-cert
make init
```

分别修改 `ica.cnf` 和 `ca.cnf` 配置文件中的 `Custom Section`单元，自定义服务器域名和IP地址

```shell
[ alt_section ]
DNS.1                   = wangyan.cloud
DNS.2                   = *.wangyan.cloud
IP.1                    = 119.29.17.197
IP.2                    = 101.32.204.113

[crl_section]
URI = http://safe.wangyan.cloud/crl/ica-crl.pem

[ocsp_section]
OCSP;URI = http://ocsp.wangyan.cloud
```

在 `Makefile` 文件中，查找 `subjectAltName` 和 `subj` 部分，自定义服务器域名和IP地址

```shell
-subj "/C=CN/ST=Guangdong/L=Zhuhai/O=Selfsigned/CN=wangyan.cloud" \
-addext "subjectAltName = IP:119.29.17.197,DNS:wangyan.cloud"
```

## 二、自签署 CA 根证书

### 2.1. 创建 `CA KEY`

```shell
make gen-ca-key
```

### 2.2. 创建 CA 请求文件

```shell
make gen-ca-csr
```

### 2.3. 创建 CA 根证书

```shell
# 根据上面请求文件，生成CA证书
make gen-ca-cert
```

### 2.4. 查看 CA 根证书详情（可选）

```shell
make view-ca-cert
```

## 三、自签署中间证书

### 3.1. 创建中间证书`KEY`

```shell
make gen-ica-key
```

### 3.2. 创建中间证书请求文件

```shell
make gen-ica-csr
```

### 3.3. 创建中间证书

```shell
make gen-ica-cert
```

### 3.4. 查看中间证书详情（可选）

```shell
make view-ica-cert
```

### 3.5. 合成中间证书链（可选）

将CA证书与中间证书合并

```shell
make gen-ica-chain
```

## 四、自签署服务器证书

### 4.1. 创建服务器证书`KEY`

```shell
make gen-server-key
```

### 4.2. 创建服务器证书请求文件

修改 `Makefile` 文件 `gen-server-csr` 单元的值

```shell
# 将域名 wangyan.cloud 和 IP 地址改成自己服务器的
openssl req -config ica.cnf \
	-new -sha256 \
    -key ica/private/server-key.pem \
    -subj "/C=CN/ST=Guangdong/L=Zhuhai/O=Selfsigned/CN=wangyan.cloud" \
    -out ica/csr/server-csr.pem \
	-addext "subjectAltName = IP:119.29.17.197,IP:101.32.204.113,DNS:wangyan.cloud,DNS:*.wangyan.cloud"
```

生成证书请求文件

```shell
make gen-server-csr
```

### 4.3. 创建服务器证书

```shell
make gen-server-cert
```

### 4.4. 查看服务器证书详情（可选）

```shell
make view-server-cert
```

### 4.5. 合成完整服务器证书（可选）

```shell
make gen-server-full
```

## 五、自签署客户端证书（可选）

客户端证书与服务器证书生成过程一致，不再展开。

```shell
make gen-client-key
# 同样要修改Makefile 文件 gen-client-csr 单元的值
make gen-client-csr
make gen-client-cert
make view-client-cert
# 创建 PKCS12 证书
make gen-client-pkcs12
```

客户端证书与服务器证书区别体现在用途上，详见 `ica.cnf` 配置文件

```shell
# The Client Certificate
[ usr_cert ]
keyUsage                = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement
extendedKeyUsage        = clientAuth,codeSigning,emailProtection,timeStamping

# The Server Certificate
[ server_cert ]
keyUsage                = digitalSignature, nonRepudiation, keyAgreement
extendedKeyUsage        = serverAuth
```

## 六、吊销证书 CRL（可选）

### 创建证书吊销列表

```shell
make gen-ica-crl
```

### 吊销客户端证

吊销上面生成的客户端证书 `client-cert.crt`

```shell
make gen-ica-revoke-client
```

## 七、OCSP 证书查询（可选）

### 创建OCSP服务器证书

```shell
make gen-ocsp-key
# 修改 Makefile 文件 gen-ocsp-csr 单元的值,自定义域名和IP地址。
make gen-ocsp-csr
make gen-ocsp-cert
```

### 运行OCSP服务器

```shell
make run-ocsp-server
```

### 连接OCSP检查证书状态

```shell
make chk-ocsp-cert
```
