extends Node
var services:Dictionary = {}

##### SERVICE LOCATOR #####
# The goal of the service locator is to make it so other scripts in the game only have to reference the service locator
# in order to use the functions of a specific module.
# This makes it so that we only have to actually load one module to access any module we want, which is pretty handy.

func register_service(service_name:String, new_service:Object) -> void: ## Registers the given service with the provided name.
	if service_name in services: return # if the service is already registered, don't proceed
	services[service_name] = new_service

# get service in registered services
func get_service(service_name:String) -> Object: ## Returns the requested service.
	if !(services.has(service_name)): return null # if the service is not registered, don't proceed
	return services[service_name]

func erase_service(service_name:String) -> void: ## Erases the requested service.
	if !(services.has(service_name)): return # if the service is not registered, don't proceed
	services.erase(service_name)
