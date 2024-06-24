extends Node
## Singleton responsável única e exclusivamente para gerenciar Scores e o Scoreboard [br]
## Isso inclui o cálculo e a exibição dos pontos ganhos pelos jogadores. 
## Este script assegura que a pontuação seja atualizada em tempo real e persistida corretamente. (TODO)

## Armazena as "Scores", o relatório de uma run, geradas com [method ScoreManager.generateLevelScore]
var scoreboard: Array[Dictionary] = []

## Armazena a Score da última run
var lastGamePlayedScore: Dictionary = {}

## Função responsável por gerar uma [b] Struct de uma "Score", o relatório de uma run [/b] [br]
func generateLevelScore(monsterPlayedKey: String, levelPoints: int, stagesSurvived: int, enemiesKilled: int) -> Dictionary:
	var actualTime = Time.get_datetime_string_from_system()
	return {
		"monsterPlayedKey" : monsterPlayedKey,
		"levelPoints" : levelPoints,
		"stagesSurvived" : stagesSurvived,
		"enemiesKilled" : enemiesKilled,
		"createdAt" : actualTime
	}

## Função responsável por registrar uma nova pontuação no [member scoreboard]
func registerScore(score: Dictionary):
	self.scoreboard.append(score)
