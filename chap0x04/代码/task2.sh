#!/usr/bin/env bash

function helps(){
	echo "usage:[options][]"
	echo "options:"
	echo "-a          统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比"
	echo "-b          统计不同场上位置的球员数量、百分比"
	echo "-c          名字最长的球员是谁？名字最短的球员是谁？"
	echo "-d          年龄最大的球员是谁？年龄最小的球员是谁？"
	echo "-h          查看帮助信息"
}


function age_status()
#统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
{
	total=0
	younger_20=0
	older_30=0
	bt_20_30=0
	ages=$(awk -F "\t" '{ print $6 }' worldcupplayerinfo.tsv)
	for age in $ages;
	do
		if  [ "$age" != "Age" ] ;then
			total=`expr $total + 1`
			if  [ $age -lt 20 ] ;then
				younger_20=`expr $younger_20 + 1`
			elif  [ $age -gt 30 ] ;then
				older_30=`expr $older_30 + 1`
			elif  [ $age -ge 20 ] &&  [ $age -le 30 ] ;then
				bt_20_30=`expr $bt_20_30 + 1`
			fi
		fi
	done

	per20=`awk 'BEGIN{printf "%.3f\n",('${younger_20}'/'$total')*100}'`
	per2030=`awk 'BEGIN{printf "%.3f\n",('${bt_20_30}'/'$total')*100}'`
	per30=`awk 'BEGIN{printf "%.3f\n",('${older_30}'/'$total')*100}'`

	echo "20岁以下的球员有 $younger_20 个，占比： $per20%"
	echo "20-30岁的球员有 $bt_20_30 个，占比：$per2030%"
	echo "30岁以上的球员有$older_30 个，占比： $per30%"
}

function position_status()
{
	c=`awk -F '\t' '{print $5}' worldcupplayerinfo.tsv |sort -r|uniq -c|awk '{print $1}'`
	p=`awk -F '\t' '{print $5}' ./worldcupplayerinfo.tsv|sort -r|uniq -c|awk '{print $2}'`
	sum=0
	count=($c)
	position=($p)
	for i in $c ;do
		sum=$(($sum+$i))
	done

	n=${#count[@]}
	for((i=1;i<n;i++));
	do
		cc=${count[i]}
		p=`awk 'BEGIN{printf "%f\n",('${cc}'/'$((sum-1))')*100}'`
		echo  "位于${position[i]}场上的球员有${cc}个，占比：${p}%"
	done

}

function name_length()
{
	name=$(awk -F "\t" '{ print length($9) }' worldcupplayerinfo.tsv) 
	longest=0
	shortest=999
	for i in $name;
	do
		if [ "$i" != "Player" ];then
		if [ $longest -lt $i ];then
			longest=$i
		fi
		if [ $shortest -gt $i ];then
			shortest=$i
		fi
	fi
	done

	longest_name=$(awk -F '\t' '{if (length($9)=='$longest'){print $9}}' worldcupplayerinfo.tsv)
	echo "名字最长的球员是："
	echo "$longest_name"
	shortest_name=$(awk -F '\t' '{if (length($9)=='$shortest'){print $9}}' worldcupplayerinfo.tsv)
	echo "名字最短的球员是："
	echo $shortest_name
}

function age_sort()
{
	age=$(awk -F "\t" '{ print $6 }' worldcupplayerinfo.tsv)
	max=0
	min=999
	for i in $age;
	do
		if [[ "$i" != "Age" ]];then
		if [[ $i -lt $min ]];then
			min=$i
		fi
		if [[ $i -gt $max ]];then
			max=$i
		fi
	fi
	done

	min_name=$(awk -F '\t' '{if($6=='$min') {print $9}}' worldcupplayerinfo.tsv)
	echo "最小年龄是$min,年龄最小的队员是:"
	echo "$min_name"
	max_name=$(awk -F '\t' '{if($6=='$max') {print $9}}' worldcupplayerinfo.tsv)
	echo "最大年龄是$max,年龄最大的队员是:"
	echo "$max_name"
	
}

while [ "$1" != "" ]; do
	case $1 in
		-a ) age_status
			exit
			;;
		-b ) position_status
			exit
			;;
		-c ) name_length
			exit
			;;
		-d ) age_sort
			exit
			;;
		-h  ) helps
			exit
			;;
	esac
done
