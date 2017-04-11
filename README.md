# paddle-openmpi
Run paddle distributed trainning on openmpi clusters

## Requirements
This toy requires a kubernetes cluster to do the below.

## Start a mpi cluster on kubernetes
```bash
kubectl create -f head.yaml
kubectl create -f mpi-nodes.yaml
# check the pods
kubectl get po -o wide
```

## Find out the mpi node ips
```bash
kubectl get po -o wide | grep nodes | awk '{print $6}' > machines
```

Then copy the `machines` file to head node(same as ssh in to head node)

## Run

You need to ssh into the head node in order to submit a job

```bash
ssh -i 
```

Copy all program to each node:

```bash
cat machines | xargs -i scp start_mpi_train.sh trainer_config.lr.py dataprovider_bow.py {}:/home/tutorial
```

Prepare trainning data:

```bash
cd data
OUT_DIR=$PWD/input SPLIT_COUNT=3 sh get_data.sh
# copy splited data to each node:
scp -r input/0/data [node1]:~
scp -r input/1/data [node1]:~
scp -r input/2/data [node1]:~
```

Submit the job to mpi cluster:

```bash

mpirun -x PYTHONHOME=/usr/local -hostfile machines -n 3  /home/tutorial/start_mpi_train.sh
```

