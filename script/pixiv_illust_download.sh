#!/usr/bin/env bash

read -p "请输入Pixiv作者ID：" member_id
if [[ `curl -sSL -k https://api.obfs.dev/api/pixiv/\?type\=member_illust\&id\=${member_id} | jq -r .code` = '422' ]]
then
    echo -e "该ID不存在。\n"
    exit 1
elif [[ `curl -sSL -k https://api.obfs.dev/api/pixiv/\?type\=member_illust\&id\=${member_id} | jq -r .illusts` = '[]' ]]
then
    echo -e "该ID不存在。\n"
    exit 1
else
    mkdir ./${member_id}
fi
echo -e "下载中，请稍候……\n"
illust_page=1
while true
do
    if [[ `curl -sSL -k https://api.obfs.dev/api/pixiv/\?type\=member_illust\&id\=${member_id}\&page\=${illust_page} | jq -r .illusts` = '[]' ]]
    then
        break
    else
        curl -sSL -k https://api.obfs.dev/api/pixiv/\?type\=member_illust\&id\=${member_id}\&page\=${illust_page} | jq . | grep -E "\"original_image_url\":|\"original\":" | sed -e "s/\"original_image_url\"://g;s/\"original\"://g;s/\"//g;s/[[:space:]]//g;s/i.pximg.net/i.pixiv.cat/g" >> ./download.txt
        let illust_page++
        continue
    fi
done
cat ./download.txt | sort | uniq | tee ./download.txt &> /dev/null
while read line
do
    while true
    do
        wget -c ${line} -P ./${member_id}
        if [ -f ./${member_id}/`echo ${line} | rev | cut -d "/" -f 1 | rev` ]
        then
            break
        else
            continue
        fi
    done
done < ./download.txt
rm ./download.txt
echo -e "下载完成，共下载了`ls ./${member_id} | wc -l`张图片。"
