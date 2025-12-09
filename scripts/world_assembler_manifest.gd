extends Resource
class_name WorldAssemblerManifest

@export var width:int = 80
@export var height:int = 140
@export var seed:int = 0
@export_file("*.tscn") var generator_paths:Array[String]
