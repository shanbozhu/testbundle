#!/bin/sh
# 用法
# ./request.sh "https://mbd.baidu.com/suggest?empty_field=10001&ctl=his&action=list&cfrom=1005640h&from=1005640h&fv=11.18.0.0&network=1_0&osbranch=i3&osname=baiduboxapp&puid=_u2Kt_OQv8SlmqqqB&service=bdbox&sid=5928_9608-3079_8164-1820_4395-5682_8786-5583_8566-5534_8296-5748_8984-2361_6009-97_1-2371_6034-5601_8529-2638_6758-5649_8688-5463_8044-5950_9760-5481_8115-3024_7985-2360_6008-5907_9533-2864_7471-5882_9422-2779_7214-5897_9484-5957_9812-5644_8666-2866_7475-5483_8131-2865_7473-2363_6013&st=0&ua=828_1792_iphone_4.17.0.5_0&uid=4C8D97B2A6BAC77F7D221FBD60F1FEBDC82EC6151OHMDKBQQCM&ut=iPhone11%2C8_12.1.2&zid=d46DE-y4sxPNFtFGFaa15u-ycaQ2ujDprib0lUUMQGs2MjhjJN-4M9Bzf9BLP98qpIs0FMnrmus3YsmBAYYtnAQ"

# 用法一:
# curl -X POST "http://10.12.193.191:8349/pushapi/task/unicast" -d "id=25284939&cuids=[\"45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH\"]&product_id=1"

# 用法二:
# curl -X POST "http://10.12.193.191:8349/pushapi/task/unicast" \
# -d "id=25284939" \
# -d "cuids=[\"45D34CA04432AE7FB8F806F7483DB2F06B58F8588FMMDBHJSRH\"]" \
# -d "product_id=1"

curl -X POST "$1" -H @./header -d @./form
