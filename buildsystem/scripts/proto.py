import os

def createFolder(directory):
	try:
		if not os.path.exists(directory):
			os.makedirs(directory)
	except OSError:
		print ('Error in Creating directory. ' + directory)
		
# creates debug and release build folder
createFolder('../binary/debug/')
createFolder('../binary/release/')