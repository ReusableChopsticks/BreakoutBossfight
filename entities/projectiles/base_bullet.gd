extends CharacterBody2D
class_name BaseBullet

"""
All bullets must have these functions:
	setup(config: BulletConfig) # constructor
	deflect() # changes bullet state after player attack
"""

var is_normal: bool
var is_deflected: bool
