# 1. Base da Imagem
FROM python:latest

LABEL maintainer="OmniDB team"
ARG OMNIDB_VERSION=3.0.3b
SHELL ["/bin/bash", "-c"]
USER root

# 2. Instalação de dependências do Sistema Operacional (isso já estava correto)
RUN addgroup --system omnidb \
    && adduser --system omnidb --ingroup omnidb \
    && apt-get update \
    && apt-get install libsasl2-dev python-dev-is-python3 libldap2-dev libssl-dev vim -y

# 3. Criação do diretório da aplicação e definição do usuário
WORKDIR /app
USER omnidb:omnidb

# 4. COPIA APENAS O ARQUIVO DE DEPENDÊNCIAS PRIMEIRO
#    (Isso otimiza o cache do Docker)
COPY --chown=omnidb:omnidb requirements.txt .

# 5. INSTALA AS DEPENDÊNCIAS DO PYTHON
RUN pip install -r requirements.txt

# 6. AGORA COPIA TODO O RESTO DO CÓDIGO (incluindo seu urls.py corrigido)
COPY --chown=omnidb:omnidb . .

# 7. ENTRA NO DIRETÓRIO ONDE A APLICAÇÃO REALMENTE ESTÁ
WORKDIR /app/OmniDB

# 8. EXECUTA OS SCRIPTS DE INICIALIZAÇÃO
#    (Não precisa mais do 'sed', pois o config.py já será a sua versão corrigida se você alterar)
RUN python omnidb-server.py --init \
    && python omnidb-server.py --dropuser=admin

# 9. EXPOR A PORTA E DEFINIR O COMANDO DE INICIALIZAÇÃO
EXPOSE 8000
CMD ["python", "omnidb-server.py"]```
