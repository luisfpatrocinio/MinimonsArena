extends Node

@onready var bgmPlayer: AudioStreamPlayer = get_node("BGMPlayer");

var musicDict: Dictionary = {
	"title": preload("res://Audio/BGM/Ostensetris.ogg"),
	"characterSelect": preload("res://Audio/BGM/Piramática.ogg")
}

func playBGM(audioKey: String) -> void:
	var _audioFile = musicDict.get(audioKey);
	if _audioFile:
		bgmPlayer.stream = _audioFile;
		bgmPlayer.playing = true;
