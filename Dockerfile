FROM gradle:6.5-jdk8

USER root
WORKDIR /tmp

# install kits...
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && apt-get -yq --no-install-recommends install apt-utils \
    && apt-get -y install git vim zip unzip curl wget gcc make libpng-dev libidn11-dev libexpat1-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoclean

# node env
ARG node_version=12.20.0
ARG nvm_version=0.37.2
ENV NVM_DIR=$HOME/.nvm \
    PATH=$PATH:$NVM_DIR/versions/node/v${node_version}/bin
RUN mkdir -p $NVM_DIR \
    && echo "199.232.68.133 raw.githubusercontent.com" >> /etc/hosts \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install ${node_version} \
    && nvm alias default ${node_version} \
    && nvm use default \
    && ln -s $NVM_DIR/versions/node/v${node_version}/bin/node /usr/bin/node \
    && ln -s $NVM_DIR/versions/node/v${node_version}/bin/npm /usr/bin/npm \
    && npm config set registry http://registry.npm.taobao.org/ \
    && npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass/ \
    && npm config set disturl https://npm.taobao.org/mirrors/node/ \
    && npm config set sharp_dist_base_url https://npm.taobao.org/mirrors/sharp-libvips/v8.9.1/ \
    && npm -g i --unsafe-perm pngquant-bin node-sass yarn @quasar/cli cordova@9.0.0 typescript \
    && ln -s $NVM_DIR/versions/node/v${node_version}/bin/yarn /usr/bin/yarn \
    && ln -s $NVM_DIR/versions/node/v${node_version}/bin/yarnpkg /usr/bin/yarnpkg \
    && yarn config set registry http://registry.npm.taobao.org/ \
    && yarn config set sass_binary_site https://npm.taobao.org/mirrors/node-sass/ \
    && yarn config set disturl https://npm.taobao.org/mirrors/node/ \
    && yarn config set sharp_dist_base_url https://npm.taobao.org/mirrors/sharp-libvips/v8.9.1/

# install android sdk and ndk
ARG android_sdk_version=6858069
# ARG ndk_tool_version=21.0.6113669
ENV ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_SDK_HOME=/opt/android-sdk \
    ANDROID_HOME=/opt/android-sdk \
    # ndk;${ndk_tool_version}
    ANDROID_SDK_PACKAGES="platforms;android-26 platforms;android-27 platforms;android-28 platforms;android-29 platforms;android-30 platform-tools"
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${android_sdk_version}_latest.zip \
    && unzip *tools*linux*.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm *tools*linux*.zip
RUN echo yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses \
    && echo yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "build-tools;30.0.3" > /dev/null \
    && echo yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "build-tools;29.0.3" > /dev/null \
    && echo yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "build-tools;28.0.3" > /dev/null \
    && echo yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "build-tools;27.0.3" > /dev/null \
    && echo yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager ${ANDROID_SDK_PACKAGES}
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/tools/bin
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/build_tools/30.0.3
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/build_tools/29.0.3:${ANDROID_SDK_ROOT}/build_tools/28.0.3:${ANDROID_SDK_ROOT}/build_tools/27.0.3

ENV JAVA_OPTS="-Djava.awt.headless=true -Xms1024m -Xmx2048m" \
    GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.workers.max=4 -Dorg.gradle.parallel=false -XX:+UseG1GC -XX:MaxGCPauseMillis=1000" \
    GRADLE_USER_HOME=$HOME/.gradle
RUN echo 'mkdir -p ${GRADLE_USER_HOME} && echo "org.gradle.daemon=false" > ${GRADLE_USER_HOME}/gradle.properties' >> $HOME/.bashrc

CMD [ "/bin/bash" ]
