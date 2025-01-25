## NodeJS Microservice - Docker Image -
`docker run -p 5000:5000 quay.io/anshuk6469/node-service`

`curl localhost:5000/plusone/99`
 
## NodeJS Microservice - Kubernetes Deployment -
`kubectl create deploy node-app --image quay.io/anshuk6469/node-service`

`kubectl expose deploy node-app --name node-service --port 5000 --type ClusterIP`

`curl http://node-service-ip:5000/plusone/99`
