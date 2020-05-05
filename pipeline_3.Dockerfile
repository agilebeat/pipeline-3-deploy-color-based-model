FROM python:3.6
LABEL maintainer “Wilson <Seunghye.Wilson@agilebeat.com>”

# Install dependencies
RUN apt-get update && apt-get install -y \
    apt-utils \
    libblas-dev \
    liblapack-dev\
    libatlas-base-dev \
    mecab \
    mecab-naist-jdic \
    mecab-ipadic-utf8 \
    swig \
    libmecab-dev \
    gfortran \
    libav-tools \
    python3-setuptools \
    sudo \
    curl \
    vim \
    mc

RUN pip --no-cache-dir install \
    awscli boto3

RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && sudo apt-get install -y nodejs \
    build-essential 

RUN npm install -g serverless
RUN npm install -g serverless-apigw-binary
RUN npm install -g serverless-apigwy-binary

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install TensorFlow CPU version
#ENV TENSORFLOW_VERSION 1.13.1
#RUN pip --no-cache-dir install \
#    https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl

# Using Ubuntu
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -; apt-get install -y nodejs


# Install Python library for Data Science
RUN pip --no-cache-dir install \
	 jupyter \
 	 ipykernel \
	 numpy==1.18.4 \
         opencv-python==4.2.0.34 \
        && \
    python -m ipykernel.kernelspec

# Set up Jupyter Notebook config
ENV CONFIG /root/.jupyter/jupyter_notebook_config.py
ENV CONFIG_IPYTHON /root/.ipython/profile_default/ipython_config.py 

RUN jupyter notebook --generate-config --allow-root && \
    ipython profile create

RUN echo "c.NotebookApp.ip = '0.0.0.0'" >>${CONFIG} && \
    echo "c.NotebookApp.port = 8888" >>${CONFIG} && \
    echo "c.NotebookApp.open_browser = False" >>${CONFIG} && \
    echo "c.NotebookApp.iopub_data_rate_limit=10000000000" >>${CONFIG} && \
    echo "c.MultiKernelManager.default_kernel_name = 'python3'" >>${CONFIG} 

RUN echo "c.InteractiveShellApp.exec_lines = ['%matplotlib inline']" >>${CONFIG_IPYTHON} 

# Copy sample notebooks.
# COPY notebooks /notebooks

# Port
EXPOSE 8888
EXPOSE 6006 

VOLUME /notebooks

# Run Jupyter Notebook
WORKDIR "/classify"
CMD ["jupyter","notebook", "--allow-root"]
