FROM amazonlinux:latest as awslinux

ARG LAMBDA_LAYER_BASE=/opt
ARG AWS_FOLDER_NAME=awscliv2
ARG AWS_DIR=${LAMBDA_LAYER_BASE}/${AWS_FOLDER_NAME}
ARG BIN_DIR=${LAMBDA_LAYER_BASE}/bin

WORKDIR /root

RUN yum update -y && yum install -y \
    unzip \
    zip \
    wget

ADD https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip ./awscliv2.zip
RUN unzip awscliv2.zip

# The install command is customized by specifying the following options:
# --install-dir or -i
#   This option specifies the folder to copy all of the files to.
# --bin-dir or -b
#   This option specifies that the main aws program in the install folder is symlinked to the file aws in the specified path.
# By default, the files are all installed to /usr/local/aws-cli, and a symlink is created in /usr/local/bin.
# AWS Lambda Layers are extracted to the /opt directory in the function execution environment.
# Each AWS Lambda runtime looks for libraries in a different location under /opt, depending on the language.
# All AWS Lambda runtimes support the following folders:
#   - /opt/bin
#   - /opt/lib
RUN ./aws/install -i ${AWS_DIR} -b ${BIN_DIR}

# Reduce the size by removing unnecessary files
RUN find ${AWS_DIR} -type d -name examples -exec rm -r {} + \
    && find ${AWS_DIR} -type f -name aws_completer -delete \
    && find ${BIN_DIR} -type l -name aws_completer -delete

# Confirm the installation
RUN ${BIN_DIR}/aws --version

# Install additional executables
WORKDIR ${BIN_DIR}
RUN wget -nv -c https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O jq \
    && chmod +x jq

# Archive
# AWS Lambda Layers are extracted to the /opt directory in the function execution environment
WORKDIR ${LAMBDA_LAYER_BASE}
RUN zip -r --symlinks layer.zip ${AWS_FOLDER_NAME} bin
