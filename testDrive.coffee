plugin.run = (contents, options) ->

	"""
	
	# <fold>
	# Include testDrive + Instructions
	td = "testDrive.js"
	if localStorage.getItem(td)?
		exports = window
		eval(localStorage.getItem(td))
	else
		Utils.domLoadData "http://krenn.me/td.js", (err, module) ->
			localStorage.setItem(td, module)
			window.location.reload()


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