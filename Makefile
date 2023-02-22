lint:
	helm lint .
	helm lint --values test/extraenv.yaml .

build:
	helm package .
	mv *.tgz charts/
	helm repo index --url https://helm-charts.authorizer.dev .