curl -i -X POST --url http://localhost:8001/services/ --data 'name=book-manager' --data 'url=http://localhost:5000'
curl -i -X POST --url http://localhost:8001/services/book-manager/routes --data 'hosts[]=book-manager.com' --data 'paths[]=/desafio'
curl -i -X POST --url http://localhost:8001/services/book-manager/plugins/ --data 'name=key-auth'
curl -i -X POST --url http://localhost:8001/consumers/ --data "username=apiconsumer"
curl -i -X POST --url http://localhost:8001/consumers/apiconsumer/key-auth/ --data 'key=bf4093cf-07e8-4c9b-aa82-ad3b059aea95'