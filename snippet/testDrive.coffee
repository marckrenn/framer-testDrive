plugin.run = (contents, options) ->

	"""
	
	# <fold>
	# Include testDrive + Instructions

	# testDrive loader
	td = "testDrive.js"
	source = "https://raw.githubusercontent.com/marckrenn/framer-testDrive/master/td.coffee"

	if localStorage.getItem(td)?
		eval(localStorage.getItem(td))
	else
		Utils.domLoadData source, (err, module) ->
			js = CoffeeScript.compile(module, bare: true)
			localStorage.setItem(td, js)
			location.reload()


	# • LOG AVAILABLE MODULES (see Inspect → Console)
	#testDrive.availableModules (modules) -> console.log(modules)

	# • USAGE:
	# testDrive.modules [<availableModules>]
	# or
	# testDrive.module "<availableModule>"
	# or just type e.g.
	# fb = new Firebase # and wait 2-3 seconds, "Autopilot"-feature

	# • NOTE: All module-classes, -methods and -functions are added to your project's global scope, so you may not use the usual yourModule.function-prefix!

	# • UPDATE testDrive (de-comment temporarily)
	#localStorage.removeItem(td)
	# </fold>
	
	
	#{contents}

	"""