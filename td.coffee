repo = "https://framermodulerepo.firebaseio.com/modules.json"

testDrive = {}

testDrive.availableModules = (callback) ->
	availableModules = []
	Utils.domLoadJSON repo, (error, modules) ->
		for module, keys of modules
			availableModules.push(module,keys) unless module.indexOf("!") is 0
		callback(availableModules)


testDrive.modules = (moduleNames) ->
	window.onerror = -> return

	moduleNames = [moduleNames] unless Array.isArray(moduleNames)
	missingModules = []

	for moduleName in moduleNames
		moduleName = moduleName.toLowerCase()

		if sessionStorage.getItem(moduleName)?

			js = sessionStorage.getItem(moduleName)
			exports = window
			val = undefined
			try eval(js)
			catch
				print "Module '#{moduleName}' could not be successsfully injected. Remove this module from testDrive.modules(), Inspect → Storage → Session Storage and also clear testDrive.autopilot.modules."
		else
			missingModules.push(moduleName)

	return if _.isEmpty(missingModules)


	Utils.domLoadJSON repo, (err, data) ->
		for missingModule, i in missingModules

			if data[missingModule]?
				modulesLoadedCounter = 0
				do (missingModule) ->

					if typeof data[missingModule].source is "object"
						subFiles = []
						for name, source of data[missingModule].source
							subFiles.push({name: name, source: source})
					else
						subFiles = [{name: data[missingModule].name, source: data[missingModule].source}]
						

					for subFile in subFiles
						completeFile = ""
						subFileLoadedCounter = 0

						do (subFile) ->

							Utils.domLoadData subFile.source, (error, d) ->
								print "#{missingModule}: Loading file #{subFileLoadedCounter + 1} / #{subFiles.length}"
								subFileLoadedCounter++

								re = /(?:\.([^.]+))?$/

								if ["coffee", "js"].indexOf(re.exec(subFile.source)[1]) isnt -1
									module = d.replace("module.exports", "window.#{missingModule}")
									module = module.replace("exports", "window").replace("module", "window")
									
									if data[missingModule].scope?
										module += """
									
										class window['#{data[missingModule].scope}'] extends window['#{missingModule}']"""

									
									if re.exec(subFile.source)[1] is "coffee"
										js = CoffeeScript.compile(module, bare: true)
									else js = module
									completeFile += " #{js}"

								else
									file = "window['modules'] = {'#{missingModule}': {'#{subFile.name}': '#{subFile.source}'}"
									completeFile += " #{file}"


								if subFileLoadedCounter is subFiles.length
									modulesLoadedCounter++
									sessionStorage.setItem(missingModule, completeFile)
									if modulesLoadedCounter is missingModules.length
										print "Successfully downloaded all required testDrive files, reloading now."
										window.location.reload()


testDrive.module = (moduleNames) -> testDrive.modules(moduleNames)


testDrive.libraries = (libraryNames) ->

	libraryNames = [libraryNames] unless Array.isArray(libraryNames)
	missingLibraries = []

	for libraryName in libraryNames
		libraryName = libraryName.toLowerCase()

		if sessionStorage.getItem(libraryName)?

			js = sessionStorage.getItem(libraryName)

			try eval(js)
			catch
				print "Library '#{libraryName}' could not be successsfully injected. Remove this library from testDrive.libraries() and Inspect → Storage → Session Storage."

		else missingLibraries.push(libraryName)

	return if _.isEmpty(missingLibraries)

	for missingLibrary, i in missingLibraries
		librariesLoadedCounter = 0

		do (missingLibrary) ->

			Utils.domLoadJSON "https://api.cdnjs.com/libraries?search=#{missingLibrary}", (error, libraries) ->

				if _.toArray(libraries.results).length > 0
					print "cdnjs.com found '#{libraries.results[0].name}' for query '#{missingLibrary}'"
					libraryName = libraries.results[0].name

					Utils.domLoadData libraries.results[0].latest, (error, sourcecode) ->

						librariesLoadedCounter++
						sourcecode = sourcecode.replace("exports", "window")
						sourcecode = "/* = '#{libraryName}' library provided by cdnjs.com */ #{sourcecode}"
						sessionStorage.setItem(missingLibrary, sourcecode)

						if librariesLoadedCounter is missingLibraries.length
							print "Successfully downloaded all required testDrive files, reloading"
							window.location.reload()

				else print "cdnjs could not find a matching library for '#{libraryName}'. Remove this library from testDrive.libraries()."


testDrive.library = (libraryNames) -> testDrive.libraries(libraryNames)


if Utils.isInsideFramerCloud()
	locationPathName = window.parent.location.pathname.split("/")[1]
else
	locationPathName = window.location.pathname.split("/")[1]

if sessionStorage.getItem("#{locationPathName} testDrive.autopilot.modules")?
	m = sessionStorage.getItem("#{locationPathName} testDrive.autopilot.modules")
	console.warn("Add     testDrive.modules #{m}     to your code for faster loading")
	m = JSON.parse(m)
	testDrive.modules(m)


saveModules = (module) ->

	if Utils.isInsideFramerCloud()
		locationPathName = window.parent.location.pathname.split("/")[1]
	else
		locationPathName = window.location.pathname.split("/")[1]

	if sessionStorage.getItem("#{locationPathName} testDrive.autopilot.modules")?
		m = sessionStorage.getItem("#{locationPathName} testDrive.autopilot.modules")
		m = JSON.parse(m)
	else
		m = []

	unless _.includes(m, module)
		m.push(module)
		m = JSON.stringify(m)
		sessionStorage.setItem("#{locationPathName} testDrive.autopilot.modules", m)?
		window.location.reload()


window.onerror = (msg) ->

	if Utils.isChrome()
		module = msg.split("Uncaught ReferenceError: ")[1].split(" ")[0].toLowerCase()
	else
		module = msg.split("ReferenceError: Can't find variable: ")[1].toLowerCase()

	Utils.domLoadJSON repo, (err, availableModules) ->
		if availableModules[module]?
			saveModules(module)
		else
			for name, key of availableModules
				if key.synonyms?
					for synonym of key.synonyms
						if synonym is module
							saveModules(name)