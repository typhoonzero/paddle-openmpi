#!/bin/bash

WORLD_SIZE=${OMPI_COMM_WORLD_SIZE}
WORLD_RANK=${OMPI_COMM_WORLD_RANK}

env

# start pserver
nohup paddle pserver --port=7164 --ports_num=2 --ports_num_for_sparse=2 --nics=eth0 --comment=paddle_cluster_openmpi --num_gradient_servers=3 &

# start trainer
paddle train --nics=eth0 --port=7164 --ports_num=2 --comment=paddle_cluster_trainer --trainer_id=$WORLD_RANK --save_dir=./output \
--config=trainer_config.lr.py \
--use_gpu=0 \
--local=0 \
--saving_period=1 \
--num_passes=10 \
--log_period=50 \
--dot_period=10 \
--ports_num=2 \
--ports_num_for_sparse=2 \
--pservers=10.1.97.4,10.1.13.6,10.1.83.5

# kill background pservers
ps -ef | grep pserver | awk '{print $2}' | xargs kill
