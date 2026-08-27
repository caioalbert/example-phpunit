# Example PHPUnit with SonarQube coverage

Projeto PHP mínimo com testes PHPUnit e integração de cobertura no SonarQube.

## Estrutura

- `src/`: código-fonte analisado;
- `test/`: testes unitários;
- `test/phpunit.xml`: configuração do PHPUnit;
- `sonar-project.properties`: escopo e caminhos dos relatórios importados pelo Sonar;
- `.github/workflows/ci.yml`: testes, geração da cobertura e análise do Sonar.

## Executar localmente

Com Docker, não é necessário instalar PHP, Composer ou Xdebug no host:

```sh
docker compose run --rm tests
```

Para executar sem Docker, os requisitos são PHP 8.3, Composer 2 e Xdebug com
suporte a coverage:

```sh
composer install
TEST_NAME=Scarlett XDEBUG_MODE=coverage composer test:coverage
```

O comando gera:

- `build/logs/clover.xml`: cobertura em formato Clover XML;
- `build/logs/junit.xml`: resultado da execução dos testes em formato JUnit XML.

Os dois arquivos também ficam disponíveis no artefato `phpunit-reports` de cada
execução do GitHub Actions.

## Enviar a cobertura ao SonarQube local

O servidor local esperado é `http://127.0.0.1:9000`. Gere um token em
**My Account > Security** e execute:

```sh
docker compose run --rm tests
SONAR_TOKEN='seu-token' ./scripts/sonar-local.sh
```

O script usa a imagem oficial do SonarScanner, valida se o servidor e os dois
relatórios estão disponíveis e envia o projeto `caioalbert_example-phpunit` ao
dashboard local. Para outro endereço, informe também `SONAR_HOST_URL`.

## GitHub Actions

Todo push em `master`/`main` e todo pull request executa os testes, gera os
relatórios e publica o artefato `phpunit-reports`.

O runner hospedado do GitHub não consegue acessar o `localhost:9000` da máquina
de desenvolvimento. Para executar também a análise no workflow, o servidor
precisa estar acessível pelo runner ou o job deve usar um runner self-hosted.
Nesse cenário, configure no repositório:

- secret `SONAR_TOKEN`: token de análise;
- variable `SONAR_HOST_URL`: URL alcançável do SonarQube.

Sem essas duas configurações, apenas a etapa de análise é ignorada; os testes e
a geração de cobertura continuam sendo executados normalmente.
