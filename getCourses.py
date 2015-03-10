import requests, json, string

departments = []
ALPHABET = list(string.ascii_lowercase)
IGNORE = ["ZZALIAS"]

for letter in ALPHABET:
	request_url = "https://apis-dev.berkeley.edu:443/cxf/asws/department?departmentCode=" + letter + "&_type=json"
	payload = {'app_id':'1e3f7196', 'app_key':'d5f9869c5bc87cb5ed57135526a3cd2a'}
	r = requests.get(request_url, params=payload)
	departmentsJson = r.json()['CanonicalDepartment']
	if departmentsJson[0] != dict():
		for departmentJson in departmentsJson:
			if departmentJson['departmentCode'] not in IGNORE:
				departments.append(departmentJson['departmentCode'])

for department in departments:
	request_url = "https://apis-dev.berkeley.edu:443/cxf/asws/course?departmentCode=" + department + "&_type=json"
	payload = {'app_id':'1e3f7196', 'app_key':'d5f9869c5bc87cb5ed57135526a3cd2a'}
	r = requests.get(request_url, params=payload)
	if r.status_code == requests.codes.ok:
		coursesJson = r.json()['CanonicalCourse']
		for courseJson in coursesJson:
			course = {}
			course['courseUID'] = courseJson['courseUID'].replace(".", " ")
			if 'courseTitle' in courseJson:
				course['courseTitle'] = courseJson['courseTitle']
			else:
				course['courseTitle'] = ""
			print course['courseUID'] + ":" + course['courseTitle']


