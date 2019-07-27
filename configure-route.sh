curl -i -X POST --url http://localhost:8001/services/ --data 'name=bookmanager' --data 'url=http://book-manager:5000/'

curl -i -X POST --url http://localhost:8001/services/bookmanager/routes/ --data 'methods[]=GET' --data 'paths[]=/desafio'

curl -i -X POST --url http://localhost:8001/services/bookmanager/plugins/ --data 'name=key-auth' --data 'config.hide_credentials=false'

curl -i -X POST --url http://localhost:8001/consumers/ --data "username=client"

curl -i -X POST --url http://localhost:8001/consumers/client/key-auth/ --data 'key=20644b66-36a8-4c46-9460-5a87247a3e3d'