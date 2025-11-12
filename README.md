# Minimons Arena

Este projeto foi desenvolvido pelo laboratório LABIRAS para a Mostra Nacional de Robótica 2024.

- [Artigo Científico](https://docs.google.com/document/d/1KGFXL5OO8v-VXuSYPPLPmS4l4oGeMCT9fSRDzHWJh6c/edit?pli=1)
- [Banner do Projeto](https://www.canva.com/design/DAGJC3_7V0M/p9SrmXagN4gzMTBnZYLs3A/edit)
- [Vídeo de Apresentação](https://youtu.be/vXHZ5OMD9kg)

## 🕹️Sobre o Jogo

Projeto que integra visão computacional e marcadores fiduciais ArUcos em um jogo de batalha por turnos, permitindo que ações físicas no mundo real sejam refletidas no ambiente virtual. O objetivo é explorar como essas tecnologias podem criar novas oportunidades não apenas para o entretenimento, mas também para áreas como educação e saúde, oferecendo experiências mais envolventes e acessíveis.

## 🌟Funcionalidades

- 📷 Integração com câmera para detecção de movimentos e objetos.
- 🌐 Conexão com servidor em Python via UDP para gerenciamento de dados em tempo real.
- 🏷️ Detecção e gerenciamento de tags para interação no jogo.
- 🛠️ Ambiente 3D interativo com elementos dinâmicos.

## Servidor Python

Durante o desenvolvimento do projeto foi utilizado um computador conectado a uma webcam externa, apontada para uma plataforma com diferentes ArUcos posicionados, cada um com valores diferentes representando objetos interativos do jogo. No centro da plataforma existe um ArUco representando o centro do cenário, para obter, dessa forma, a referência relativa das posições dos outros objetos no cenário lógico.
Para conectar todas essas tecnologias e conseguir de forma satisfatória representar as interações do ambiente físico no meio digital, foi construída uma aplicação servidora em Python utilizando a biblioteca OpenCV a fim de captar as imagens retornadas pela webcam conectada ao computador local. Dessa maneira, os dados como a posição e rotação dos marcadores fiduciais puderam ser processados com a ajuda da biblioteca DeepTag, para serem utilizadas pela plataforma de produção de jogos, de forma com que o cenário interativo fosse criado.
A transferência de informações entre o servidor e a Godot ocorre por meio do protocolo UDP. Com a obtenção dos dados das posições dos marcadores no meio físico pela engine, pode-se criar as devidas representações digitais utilizando os recursos disponíveis na plataforma.
O código utilizado foi baseado no no seguinte trabalho: https://github.com/herohuyongtao/deeptag-pytorch
"DeepTag: A General Framework for Fiducial Marker Design and Detection."
Zhuming Zhang, Yongtao Hu, Guoxing Yu, and Jingwen Dai
IEEE TPAMI 2023.

## 📜Scripts Principais

### [Global.gd](https://github.com/luisfpatrocinio/MinimonsArena/blob/main/Scripts/Global.gd)

A classe Global é um Node autoload utilizado para gerenciar o estado global do jogo, fornecendo um ponto de acesso centralizado para várias funcionalidades e dados compartilhados entre diferentes partes do jogo. Esta classe facilita a coordenação e comunicação entre diferentes cenas e nós, mantendo informações importantes como o dicionário de tags detectadas, referências a nós críticos do jogo, e gerenciando a transição entre cenas. Além disso, ela contém métodos utilitários para converter dados, gerenciar a câmera, e manipular a exibição de tags no jogo.

### [CameraConnectionManager.gd](https://github.com/luisfpatrocinio/MinimonsArena/blob/main/Scripts/Connection.gd)

Classe responsável por conectar o jogo ao servidor em Python via UDP. Ela lida com a comunicação de rede, recebendo dados das tags detectadas e processando-os para uso no jogo.

### [ScoreManager.gd](https://github.com/luisfpatrocinio/MinimonsArena/blob/main/Scripts/score_manager.gd)

Singleton responsável única e exclusivamente para gerenciar Scores e o Scoreboard. Isso inclui o cálculo e a exibição dos pontos ganhos pelos jogadores. Este script assegura que a pontuação seja atualizada em tempo real e persistida corretamente. (TODO)

### [AudioManager.gd](https://github.com/luisfpatrocinio/MinimonsArena/blob/main/Scripts/AudioManager.gd)

Controla todos os aspectos relacionados ao áudio no jogo, incluindo música de fundo, efeitos sonoros e volume. O AudioManager garante uma experiência sonora imersiva e ajustável conforme a necessidade do jogador.

### [Game.gd](https://github.com/luisfpatrocinio/MinimonsArena/blob/main/Scripts/Game.gd)

A classe Game coordena a lógica principal do jogo, incluindo a inicialização do Level, controle de fluxo de jogo, e gerenciamento de estados. Este script é essencial para a execução e integração de todos os componentes. Ele gerencia as etapas do jogo, alternando entre preparação, jogo e vitória de nível, além de responder a entradas do jogador para iniciar o jogo, pausar ou retornar à tela de título. A classe também é responsável por atualizar a interface do usuário com o estado atual do jogo e iniciar entidades durante a fase de preparação.

## Equipe

- [Antônio Meireles Alves Neto](https://github.com/Meidesu)
- [Hermínio de Barros e Silva Neto](https://github.com/herminioneto)
- [Luis Felipe dos Santos Patrocinio](https://github.com/luisfpatrocinio)
- [Ryan Faustino Carvalho](https://github.com/ryofac)
