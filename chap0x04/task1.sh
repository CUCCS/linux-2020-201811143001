#!/usr/bin/env bash

function help()
{
	echo "usage:"

	echo "-q [quality_num][dir]		对jpeg格式图片进行图片质量压缩"
	echo "-r [percent][dir]		对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率"
	echo "-w [watermark_text][dir]	批量添加自定义文本水印"
	echo "-p [prefix_text][dir]		统一添加文件名前缀"
	echo "-s [suffix_text][dir]		统一添加文件名后缀"
	echo "-c [dir]			将png/svg图片统一转换为jpg格式图片"
	echo "-h				帮助文档"
}

function jpeg_quality_compress()
#对jpeg格式图片进行图片质量压缩
{
	quality_num=${1}
	dir=${2}
	
	jpeg_files=($(find "${dir}" -regex '.*\.jpg'))
	for jpeg_file in "${jpeg_files[@]}";
	do
		file_name=${jpeg_file%.*}
		file_tail=${jpeg_file##*.}
		convert ${jpeg_file} -quality ${quality_num} $file_name'_quality.'$file_tail
		echo $jpeg_file 'is compressed into' $file_name'_quality.'$file_tail  
	done
}

function keep_ratio_compress()
#对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率
{
	percent=${1}
	dir=${2}
	jps_files=($(find "${dir}" -regex '.*\.jpg\|.*\.svg\|.*\.png'))

	for jps_file in "${jps_files[@]}";
	do
		file_name=${jps_file%.*}
		file_tail=${jps_file##*.}
		convert ${jps_file} -resize ${percent}'%x'${percent}'%' $file_name'_'$percent'%.'$file_tail
		echo ${jps_file} 'is compressed into' $file_name'_'$percent'%.'$file_tail  
	done

}

function add_watermark()
##对图片批量添加自定义文本水印
{
	watermark_text=${1}
	dir=${2}
	all_files=($(find "${dir}" -regex '.*\.jpg\|.*\.svg\|.*\.png\|.*\.jpeg'))
	for all_file in "${all_files[@]}";
	do
		file_name=${all_file%.*}
		file_tail=${all_file##*.}
	convert ${all_file} -gravity south -fill black -pointsize 16 -draw "text 5,5 '$watermark_text'" $file_name'_watermarked.'$file_tail
	echo ${all_file} 'is added watermark into' $file_name'_watermarked.'$file_tail
done
}

function rename_add_prefix()
#统一添加文件名前缀
{
	prefix=${1}
	dir=${2}
	files=($(find "${dir}" -regex '.*\.jpg\|.*\.svg\|.*\.png\|.*\.jpeg'))
	for file in "${files[@]}";
	do
		file_dir=${file%/*}
		file_name=${file%.*}
		file_tail=${file##*.}
		file_sname=${file_name##*/}
		mv $file $file_dir'/'$prefix$file_sname'.'$file_tail
		echo "prefix ia added"
	done
}

function rename_add_suffix()
#统一添加文件名后缀
{
	suffix=${1}
	dir=${2}
	files=($(find "${dir}" -regex '.*\.jpg\|.*\.svg\|.*\.png\|.*\.jpeg'))
	for file in "${files[@]}";
	do
		file_name=${file%.*}
		file_tail=${file##*.}
		mv $file $file_name$suffix'.'$file_tail
		echo "suffix is added"
	done
}

function transfer_format()
#将png/svg图片统一转换为jpg格式图片
{
	dir=${1}
	files=($(find "$dir" -regex  '.*\.png\|.*svg'))
	for file in "${files[@]}";
	do
		convert $file "${file%.*}.jpg"
		echo "tranfer to jpg finished"
	done
}


while [ "$1" != "" ];do
       case "$1" in
	       "-q")
		       jpeg_quality_compress $2 $3
		       exit 0
		       ;;
	       "-r")
		       keep_ratio_compress $2 $3
		       exit 0
		       ;;
	       "-w")
		       add_watermark $2 $3
		       exit 0
		       ;;
	       "-p")
		       rename_add_prefix $2 $3
		       exit 0
		       ;;
	       "-s")
		       rename_add_suffix $2 $3
		       exit 0
		       ;;
	       "-c")
		       transfer_format $2
		       exit 0
		       ;;
	       "-h")
		       help
		       exit 0
		       ;;
       esac
done
