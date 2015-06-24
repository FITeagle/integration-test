FROM java:8-jre

RUN apt-get -y update && apt-get -y install git curl unzip libxml2-utils && apt-get -y clean
WORKDIR /opt/fiteagle

COPY . /opt/fiteagle/integration-test/

CMD cd /opt/fiteagle/integration-test; ./acceptanceTest.sh

