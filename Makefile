lint:
	helm lint .

build:
	helm package .
	mv *.tgz charts/
	helm repo index --url https://helm-charts.authorizer.dev .