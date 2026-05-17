extends CanvasLayer

func _ready() -> void:
	# Назначаем чистый текст для обычного Label (без BBCode тегов)
	%text.text = """OUTREACH
""" + str(GlobalValues.version) + """

-------------------------------

DEVELOPMENT & DESIGN

Game Designer / Project Lead
Kykemanov Daniil

Lead Programmer
Kykemanov Daniil

-------------------------------

ART & ANIMATION

3D Artist
Kykemanov Daniil

2D Artist
cc19

UI/UX Designer
Kykemanov Daniil

Technical Shader Artist
Kykemanov Daniil

-------------------------------

AUDIO & MUSIC

Composer
Kykemanov Daniil

Sound Designer / SFX
Kykemanov Daniil

-------------------------------

QUALITY ASSURANCE (QA)

Lead QA Tester
Kykemanov Daniil

Testing Team
Name "Nick" Petrov
Name "Nick" Sidorov

-------------------------------

CREDITS & THIRD-PARTY RESOURCES

Special Thanks
A huge thanks to my friend cc19 for providing sprites and helping with the game's development. 

I would also like to extend a big thank you to all the developers whose assets I used to bring this project to life.

Last but not least, thank you to our small but wonderful Outreach community for being here.

Tools Used

Game Engine: Godot Engine 4.6 (MIT License)

Voxel Plugin: Voxel Tools 1.6 (MIT License)

Font: Public Pixel (CC0 1.0 License)

-------------------------------

Thank you for playing!

© Kykemanov Daniil | MIT License"""
