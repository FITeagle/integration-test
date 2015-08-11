FROM maven:3-jdk-8

RUN apt-get -y update && apt-get -y install git curl screen && apt-get -y clean
WORKDIR /opt/fiteagle

RUN mkdir -p /root/.m2
VOLUME /root/.m2

RUN mkdir -p $HOME/.fiteagle && curl -fsSL https://raw.githubusercontent.com/FITeagle/integration-test/master/conf/MotorGarage.properties -o $HOME/.fiteagle/MotorGarage.properties
CMD curl -fsSL https://raw.githubusercontent.com/FITeagle/bootstrap/master/fiteagle.sh | bash -s init deployFT2 deployFT2sfa testFT2sfa
#CMD curl -fsSL https://raw.githubusercontent.com/FITeagle/bootstrap/master/fiteagle.sh | bash -s init deployFT2 deployFT2sfa testFT2sfa; \
#	cd /opt/fiteagle/; \
#	git clone --depth=1 https://github.com/FITeagle/integration-test.git; \
#	cd integration-test; ./runJfed_local.sh

