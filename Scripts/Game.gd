extends Node
class_name Game

## Classe responsável por gerenciar as regras do jogo.

enum STAGES {PREPARATION, GAME}
var stage: int = STAGES.PREPARATION;

