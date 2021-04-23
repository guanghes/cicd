#!/bin/bash
source ./currentDeployment
newTag=$1
if [[ $currentDeployment == "green" ]]
then
  source ./blue
  ssh opc@$host docker login -u="guanghes" -p="XXXXXXXX" && docker pull guanghes/th3-server:$newTag && docker run -d -p $port:8080 --name blue guanghes/th3-server:$newTag
  oci lb backend update --load-balancer-id ocid1.loadbalancer.oc1.phx.aaaaaaaarcshxid33k67rmj5bm6eqlkjqrgjdcwrdlfqap6pn3lfw7hsjutq \
    --backend-set-name th3servers --weight 1 --backup false --drain false --backend-name $host:$port --offline false
    
  source ./green
  oci lb backend update --load-balancer-id ocid1.loadbalancer.oc1.phx.aaaaaaaarcshxid33k67rmj5bm6eqlkjqrgjdcwrdlfqap6pn3lfw7hsjutq \
    --backend-set-name th3servers --weight 1 --backup false --drain false --backend-name $host:$port --offline true
  ssh opc@$host docker stop green && docker rm green
  echo "blue" > ./currentDeployment
  
else
  source ./green
  ssh opc@$host docker login -u="guanghes" -p="XXXXXXXX" && docker pull guanghes/th3-server:$newTag && docker run -d -p $port:8080 --name green guanghes/th3-server:$newTag
  oci lb backend update --load-balancer-id ocid1.loadbalancer.oc1.phx.aaaaaaaarcshxid33k67rmj5bm6eqlkjqrgjdcwrdlfqap6pn3lfw7hsjutq \
    --backend-set-name th3servers --weight 1 --backup false --drain false --backend-name $host:$port --offline false
    
  source ./blue
  oci lb backend update --load-balancer-id ocid1.loadbalancer.oc1.phx.aaaaaaaarcshxid33k67rmj5bm6eqlkjqrgjdcwrdlfqap6pn3lfw7hsjutq \
    --backend-set-name th3servers --weight 1 --backup false --drain false --backend-name $host:$port --offline true
  ssh opc@$host docker stop blue && docker rm blue
  echo "green" > ./currentDeployment
fi
