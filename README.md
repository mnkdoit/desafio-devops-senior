# Resposta ao Desafio DevOps Engineering do Brasil

## Para iniciar o stack da aplicação:
* Necessário ter Docker Instalado na máquina;
* Execute "docker-compose up", apartir da pasta do repositório;
* Após o stack estar em execução execute "configure-route.sh", que será configurada a rota "htt://<endereço>/desafio" para a aplicação "bookmanager";
* Prontinho!
    
## Acessando a aplicação:
* Para acessar a aplicação é necessário utilizar autenticação por chave (chave -> 20644b66-36a8-4c46-9460-5a87247a3e3d em: htt://<endereço>:8001/desafio
* Você também pode acessar o Konga para administrador o api-gateway, bastando apenas criar seu usuário e senha em htt://<endereço>/:1337
* Para administrar o Kong via API pasta enviar as requisições para http://<endereço>:8000/ - Guia completo em: [Kong](https://docs.konghq.com/1.2.x/admin-api/)

## Como funciona:
####Docker:
É um projeto de software livre que ajuda a automatizar aplicativos autossuficientes e portateis, que independem do ambiente externo.
>A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another
https://www.docker.com/resources/what-container

####Dockercompose:
Dockercompose é uma ferramenta utilizada para entregar aplicações "multi-container". Para que seja executado, deve-se criar uma receita em [YAML](https://yaml.org/), chamado "docker-compose.yaml" ou "docker-compose.yml". Neste arquivo há a configuração do nosso stack da aplicação (Com a configuração das máquinas, sequência de 'subida', variáveis de ambiente e etc...). Ao executar 'docker-compose up' é feita uma validação desse arquivo, em seguida são iniciadas instâncias de máquinas na sequência estabelecida.