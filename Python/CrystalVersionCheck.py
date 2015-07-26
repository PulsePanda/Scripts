import urllib.request

fileUrl = "https://docs.google.com/document/export?format=txt&id=1Sw7JQMHHeURAlHRhuWFt58uQ7dSoUPfvjg6L-FoHgOo&token=AC4w5VjC4StKDpdZjdBa-bbiN7YgaDBLcA%3A1435202231644"
webResponse = urllib.request.urlopen(fileUrl)
responseData = webResponse.read()
version = responseData.decode('utf-8')

print(version)