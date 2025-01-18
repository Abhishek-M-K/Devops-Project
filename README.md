**PS** : Ignore k8s/redis dir, have some plans with it for the future 👀

### Terminologies :
-  ⁠Master node: Central server in a distributed system responsible for managing and coordinating resources, tasks, etc across worker nodes 👤.
- ⁠ ⁠Worker/ Managed node: A machine/ node in a distributed system that performs assigned tasks, workloads, and reports results, while being managed by a master node 👥.
-  ⁠⁠AWS EC2: Virtual server which allows users to run applications in the cloud.
-  ⁠⁠Provisiong: Process of setting up and configuring the infrastructure on your cloud provider and Terraform is one popular tool for this 🔍.
-  ⁠⁠Configuration Management: Process of maintaining systems and s/w configurations, and Ansible tool is used for n/w automation, config management, orchestration, etc ⚙️.
-  ⁠⁠Nginx : High performance web server that can be used as reverse proxy, for routing, as load balancer and whatnot.



### Project Flow :

- My PC is the master node and I will spin an infra with 2 EC2 worker nodes with the help of Terraform (complete AWS infra is given in the repo). ❄️
- ⁠Terraform stores the public IPs of worker nodes on AWS S3 later used by Ansible for Passwordless Authentication 🔐.
- ⁠Ansible first fetches the file containing IPs at localhost and then performs the next 2 plays/ tasks on the worker nodes.
- ⁠Firstly, we are deploying an ElysiaJs Bun application on worker nodes ( this had me locked for good hours, Bun on EC2 !!! ) and serving the static HTML and API routes via Nginx ( another great tool ).
- ⁠Then, once the ElysiaJs 🦊 application is deployed and running, Install Docker and spin up containers for Redis locally used by our apps for storing data in KV pairs.
- ⁠Simple, right? clone app, install dependencies, run, connect to the docker container and you get a simple API server interacting with Redis as local DB.


### Terraform :

Followed a modular approach for infra/ resource provisioning with multiple files each serving its purpose as follows:
- **main.tf** : defines our cloud provider and region for infra.
- **compute.tf** : contains ec2 servers configuration with nginx and few necessary modules installed already.
- **networking.tf** : DNS, load balancers, security group, listening rules, etc all are configured here (few resources I already have on my AWS so didn't cared to make new).
- **dns.tf** : contains domain related AWS route53 resource.
- **storage.tf** : AWS s3 bucket resource will store public IPs of instances created.
- **outputs.tf** : Output variable to display public IPs.

### Ansible : 

Made use of Ansible Roles for a readable and scalable configuration Playbook. 
- Play 1 runs locally and extract public IPs from s3 object.
- **Role 1 - ElysiaJs app** : Deploys ElysiaJs Bun application 🦊 with the help of Nginx and pm2. Once deployed, tests the API endpoints.
- **Role 2 - Docker** : Docker installation and containerisation of Redis Images on local instances, to be used by deployed application as a local DB.
 
