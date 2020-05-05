# pipeline-3-deploy-color-based-model
AWS lambda deployment for color-based image classifiers


### 1. Build docker images with docker file name
`docker build -t python36:color_base -f pipeline_3.Dockerfile  .`


### 2. Running docker image and get container ID
`docker run -v /home/swilson/.aws:/root/.aws -v /home/swilson/PipeLine-03:/classify <IMAGE ID>`  
  
`docker run -v <PATH-TO-YOUR-CREDENTIALS-ON-HOST_MACHINE>/.aws:/root/.aws -v <PATH-TO-YOUR-SERVERLESS-PROJECT>:/root/classify-lambda <IMAGE ID>`

### 3. Get container's terminal access and move to the model directory
`docker exec -it <CONTAINER-ID> /bin/bash`  

For example of model for industrial area,   
`root@xxxx:~# cd classify/pipeline-3-deploy-color-based-model/landuse-industrial`

### 4. Create and activate python virtual environment
`root@xxxx:~/landuse_industrial# python3 -m venv python.venv`  
`root@xxxx:~/landuse_industrial# source python.venv/bin/activate`  

### 5. Install packages necessary for lambda in the virtual environment
`(python.venv) root@xxxx:~/landuse_industrial# pip install -t ./ -r requirements.txt`


### 6. Install necessary plugins for serverless. Run:  
`(python.venv) root@xxxx:~/landuse_industrial# sls plugin install -n serverless-python-requirements`  
`(python.venv) root@xxxx:~/landuse_industrial# sls plugin install -n serverless-reqvalidator-plugin`  
`(python.venv) root@xxxx:~/landuse_industrial# sls plugin install -n serverless-aws-documentation`  
`(python.venv) root@xxxx:~/landuse_industrial# sls plugin install -n serverless-plugin-custom-roles`  


### 7. Deploy the model
`(python.venv) root@xxxx:~/landuse_industrial# sudo sls deploy -v`



### 8.Testing the model with testing images as base64 string
Open 'test.http' and send the request. Make sure the POST endpoint address is from deployment.

