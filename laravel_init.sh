#!/bin/bash
basepath=$(cd `dirname $0`; pwd)
shfile=$basepath"/"$0
which "composer" >/dev/null
if [ $? -eq 0 ]; then
	echo "修改镜像"
	composer config -g repo.packagist composer https://packagist.laravel-china.org >/dev/null
	echo "初始化开始"
	composer install >/dev/null
	if [ $? -eq 0 ]; then
		if [ ! -f ".env.example" ]; then
			echo ".env.example不存在"
		else
			echo "复制.env.example 成 .env"
			cp .env.example .env
			echo "生成app-key"
			php artisan key:generate 
			echo "生成crontab"
			read -p "请输入crontab用户:" crontab
			echo "* * * * * php $basepath/artisan schedule:run >> /dev/null 2>&1"
			echo "/var/spool/cron/$crontab"
			grep "* * * * * php $basepath/artisan schedule:run >> /dev/null 2>&1" "/var/spool/cron/$crontab" > /dev/null
			if [ $? -eq 0 ]; then
				echo "crontab已存在"
			else
				if [ ! $crontab ]; then
					echo "crontab输入为空"
				else
					file="/var/spool/cron/$crontab"
					echo "* * * * * php $basepath/artisan schedule:run >> /dev/null 2>&1" >"$file"
				fi
			fi
			echo "初始化成功"
			rm -rf $shfile
		fi
	else
		if [ ! -f "composer.json" ]; then
			echo "composer.json不存在"
		else
			echo "error $?"
		fi
	fi
else
	echo "install composer"
	curl -sS https://getcomposer.org/installer | php >/dev/null
	echo "mv composer"
	mv composer.phar /usr/local/bin/composer >/dev/null
	echo "restart"
	sh $shfile
fi

