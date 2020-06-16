
    artifactory.santanderbr.corp/docker-base/cloudera-client-6.1-ctm-client-9:1.0.0.SNAPSHOT


Tutorial - Building a docker container for batch applications
https://docs.bmc.com/docs/automation-api/9/tutorial-building-a-docker-container-for-batch-applications-784081199.html

#Abrir portas no firewall do gcp
6GB e 2CPUS

cd && mkdir controlm && cd controlm && sudo su
yum install docker wget git -y
gpasswd -a $USER docker && systemctl restart docker
docker network create controlm-net

wget https://controlm-appdev.s3-us-west-2.amazonaws.com/release/v9.20.10/controlm-workbench-9.20.10.xz \
&& cat controlm-workbench-9.20.10.xz | docker load

# Run Workbench
docker run --name=workbench \
-dt --hostname=workbench  \
-p 8443:8443 -p 7005:7005 \
--network controlm-net \
controlm-workbench:9.20.10

https://$public-ip-gcp:8443/automation-api/swagger-ui.html

git clone https://github.com/controlm/automation-api-quickstart.git

cd automation-api-quickstart/102-build-docker-containers-for-batch-application/centos7-agent/

# Build Agent-ControlM
SRC_DIR=.
CONTROLM_DOCKER_NET=controlm-net
CONTROLM_HOST=workbench
CTM_USER=workbench
CTM_PASSWORD=workbench
sudo docker build --tag=agent-controlm \
--network=$CONTROLM_DOCKER_NET \
--build-arg CTMHOST=$CONTROLM_HOST \
--build-arg USER=$CTM_USER \
--build-arg PASSWORD=$CTM_PASSWORD $SRC_DIR

# Run Agent-ControlM
CTM_SERVER=workbench
CTM_HOSTGROUP=containers
CTM_AGENT_PORT=2369
sudo docker run --name=agent-controlm \
  --net $CONTROLM_DOCKER_NET \
  -e CTM_SERVER=$CTM_SERVER \
  -e CTM_HOSTGROUP=$CTM_HOSTGROUP \
  -e CTM_AGENT_PORT=$CTM_AGENT_PORT -dt agent-controlm

vim ../JobsRunOnDockerSample.json
docker cp ../JobsRunOnDockerSample.json agent-controlm:/tmp
sudo docker exec -it agent-controlm ctm run /tmp/JobsRunOnDockerSample.json
{
  "runId": "d3621fee-0fe0-4636-ba97-acbed437bbb1",
  "statusURI": "https://workbench:8443/automation-api/run/status/d3621fee-0fe0-4636-ba97-acbed437bbb1",
  "monitorPageURI": "https://workbench:8443/SelfService#Workbench:runid=d3621fee-0fe0-4636-ba97-acbed437bbb1&title=JobsRunOnDockerSample.json"
}

# Esta com erro, nao sei se esta certo.
sudo docker run -it agent-controlm ctm config server:agents::get workbench
