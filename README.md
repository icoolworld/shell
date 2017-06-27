# 关于本仓库

本仓库中，记录了一些常用的shell脚本，用于webserver的服务安装，线上代码发布推送等。各脚本都是编译安装，可以自行定义编译参数。

## 一键安装nginx服务：
```
sh install_nginx/install_nginx.sh
```

> nginx启动脚本

```
cp install_nginx/nginx.server /etc/init.d/nginx
chmod +x /etc/init.d/nginx
/etc/init.d/nginx start
```

## 一键安装php服务：
```
sh install_php/install_php.sh
```

> php启动脚本

```
cp install_php/php-fpm.server /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
/etc/init.d/php-fpm start
```

## 一键安装mysql服务：
```
sh install_mysql/install_mysql.sh
```

> mysql启动脚本

```
cp install_mysql/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
/etc/init.d/mysql start
```

## 一键安装redis服务：
```
sh install_redis/install_redis.sh
```

> redis启动脚本

```
cp install_redis/redis_6379.server /etc/init.d/redis_6379
chmod +x /etc/init.d/redis_6379
/etc/init.d/redis_6379 start
```

## 一键安装memcached服务：
```
sh install_memcached/install_memcached.sh
```

> memcached启动脚本

```
cp install_memcached/memcached.server /etc/init.d/memcached
chmod +x /etc/init.d/memcached
/etc/init.d/memcached start
```

## 发布git代码至线上服务器

> 需要自行配置git仓库地址

```
sh git_publish_code_to_online.sh
```

## 其他说明

mysqld_multi.sh为多实例管理脚本
