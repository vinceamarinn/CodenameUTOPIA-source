extends Node
var services:Dictionary = {}

##### SERVICE LOCATOR #####
# The goal of the service locator is to make it so other scripts in the game only have to reference the service locator
# in order to use the functions of a specific module.
# This makes it so that we only have to actually load one module to access any module we want, which is pretty handy.

# register service in service locator
func register_service(name:String, new_service:Object) -> void:
	if name in services: return # if the service is already registered, don't proceed
	services[name] = new_service

# get service in registered services
func get_service(name:String) -> Object:
	if !(services.has(name)): return null # if the service is not registered, don't proceed
	return services[name]

func erase_service(name:String) -> void:
	if !(services.has(name)): return # if the service is not registered, don't proceed
	services.erase(name)
