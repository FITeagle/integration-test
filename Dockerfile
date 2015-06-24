FROM java:8-jre

RUN apt-get -y update && apt-get -y install git curl screen unzip libxml2-utils && apt-get -y clean
WORKDIR /opt/fiteagle

COPY . /opt/fiteagle/

CMD cd /opt/fiteagle/; ./acceptanceTest.sh

