# Pull base image.
FROM ubuntu:14.04

# Install base software packages
RUN apt-get update && \
    apt-get install software-properties-common \
    python-software-properties \
    ca-certificates \
    gnupg2 \
    build-essential \
    wget \
    curl \
    git \
    lftp \
    unzip -y && \
    apt-get clean

# ——————————
# Install Ruby (use `source /etc/profile.d/rvm.sh` to use Ruby)
# ——————————
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.5.1 && gem install bundler"

# ——————————
# Install Java
# ——————————
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# ——————————
# Installs i386 architecture required for running 32 bit Android tools
# ——————————
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

# ——————————
# Installs Android SDK
# ——————————
RUN useradd -u 1000 -M -s /bin/bash android
RUN chown 1000 /opt
USER android

ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
ENV ANDROID_SDK_FILE=sdk-tools-linux-4333796.zip

RUN cd /opt && \
  wget -q https://dl.google.com/android/repository/${ANDROID_SDK_FILE} && \
  unzip -q ${ANDROID_SDK_FILE} -d android-sdk && \
  rm ${ANDROID_SDK_FILE} && \
  yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

RUN $ANDROID_HOME/tools/bin/sdkmanager \
  "platform-tools" \
  "platforms;android-29" \
  "platforms;android-28" \
  "platforms;android-27" \
  "platforms;android-26" \
  "platforms;android-25" \
  "build-tools;28.0.3" \
  "build-tools;28.0.2" \
  "build-tools;26.0.3" \
  "build-tools;25.0.1" \
  "build-tools;23.0.1" \
  "extras;google;m2repository" \
  "extras;android;m2repository" \
  "extras;google;google_play_services"

# ——————————
# Installs Gradle
# ——————————
USER root

ENV GRADLE_VERSION 4.1

RUN cd /usr/lib \
 && curl -fl https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle-bin.zip \
 && unzip "gradle-bin.zip" \
 && ln -s "/usr/lib/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
 && rm "gradle-bin.zip"

# Set Appropriate Environmental Variables
ENV GRADLE_HOME /usr/lib/gradle
ENV PATH $PATH:$GRADLE_HOME/bin

# ——————————
# Install Node and global packages
# ——————————
ENV NODE_VERSION 8.11.3
RUN cd && \
    wget -q http://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz && \
    tar -xzf node-v${NODE_VERSION}-linux-x64.tar.gz && \
    mv node-v${NODE_VERSION}-linux-x64 /opt/node && \
    rm node-v${NODE_VERSION}-linux-x64.tar.gz
ENV PATH ${PATH}:/opt/node/bin

# ——————————
# Install Basic React-Native packages
# ——————————
RUN npm install react-native-cli -g
RUN npm install yarn -g

# ——————————
# Env Vars
# ——————————
ENV LANG en_US.UTF-8
