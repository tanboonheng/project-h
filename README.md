# project-h

There are 4 components to this project
1. FastAPI app with Mongodb
2. Terraform + AWS
3. Kubernetes Deployment
4. Github Actions

# Pre-requisite to run project locally
1. docker desktop (https://www.docker.com/products/docker-desktop/)
2. docker compose (https://docs.docker.com/compose/install/)
3. git (https://git-scm.com/downloads)

# Run the project locally using docker-compose
```
git clone https://github.com/tanboonheng/project-h.git
cd project-h/simple-api-app/app
docker-compose up --build
```
# Test the application locally
visit http://localhost/docs to verify that the application is running. 

## Create a Product
```
curl -X POST http://localhost/products "Content-Type: application/json" -d '{"name": "Test Product","description": "A test product","price": 29.99}'
```
## GET all Products
```
curl http://localhost/products
```

## GET single product
> [!NOTE]
> replace {product_id} with actual product id from previous responses

```
curl http://localhost/products/{product_id}
```
## PUT / Update a Product
```
curl -X PUT http://localhost/products/{product_id} -H "Content-Type: application/json" -d '{"name": "Updated Product","description": "An updated test product","price": 39.99}'
```

## Delete a Product
```
curl -X DELETE http://localhost/products/{product_id}
```

## Cleanup locally after use
Stop and remove all containers, network and volume
```
docker-compose down -v
```
> [!NOTE]
> remove the -v flag to keep volumes with data that persists: docker-compose down

Delete dangling images that are untagged and not in used
```
docker image prune
```

## Pushing to Dockerhub
```
### project-h/simple-api-app/app
docker build -t {DOCKER_HUB_USERNAME}/simple-api-app:latest .
```

## Terraform 
project-h/terraform
Pre-requisite: Create access key on AWS
Env values required:
1. EKS_CLUSTER ### Name of EKS cluster
   - example value: dev-eks-cluster
3. AWS_REGION 
   - example: us-east-1, ap-southeast-1	

```
terraform init
terraform plan
terraform apply

## terraform destroy when resources are no longer needed.
```

## Repository secrets required for github actions:
1. AWS_ACCESS_KEY_ID
2. AWS_SECRET_ACCESS_KEY
3. CODECOV_TOKEN
4. DOCKER_HUB_TOKEN
5. DOCKER_HUB_USERNAME

## Env secrets required
1. KUBE_CONFIG_DATA
```
## Update kubeconfig from AWS and retrieve it in base64 format
aws eks update-kubeconfig --name {EKS_CLUSTER} --region {AWS_REGION}
cat ~/.kube/config -n kube-system | base64
```

## Security measures:
1. Security Group to control network traffic
2. Prevent secrets (keys, passwords, tokens, etc) from being stored in codebase.

## Further improvements to implement:
1. Modify provider.tf to include and provision S3 backend to store and maintain terraform state.
2. AWS Elastic Container Registry (ECR) to store container images.
3. AWS secrets manager or Hashicorp Vault to store secrets.
4. JWT token on FASTAPI for authentication and authorization.
5. Rate limiter to control requests per minute to endpoints.
