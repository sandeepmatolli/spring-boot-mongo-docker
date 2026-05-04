pipeline{

agent any

tools{
maven 'maven'
}

environment{
deploy_path = '/ubuntu/home/deploy/'
host= "ubuntu"
host_ip = "13.61.19.217"
AppImage = "springapp"
DbImage = "mongo"
IMAGE_TAG = "${Build_number}"
spring_file = "Dockerfile.app"
Db_file = "Dockerfile.mongo"
Deploy_file = "docker-compose.yml"
}

triggers{
cron('* * * * *'), pollSCM('* * * * *')
}

options{
buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '1', numToKeepStr: '1'))
}

stages{
	stage('git checkout'){
		steps{
		git branch: 'sandeep', credentialsId: 'git', url: 'git@github.com:sandeepmatolli/spring-boot-mongo-docker.git'
		}
	}

	stage('build artifact'){
		steps{
		sh 'mvn clean package -DskipTests'
		}
	}

	stage('build setup'){
		steps{
		sh '''
		rm -rf /ubuntu/home/deploy/
		mkdir -p /ubuntu/home/deploy/
		cp target/spring-boot-mongo-1.0.jar /ubuntu/home/deploy/
		cp Dockerfile.app /ubuntu/home/deploy/
		cp Dockerfile.mongo /ubuntu/home/deploy/
		cp docker-compose.yml /ubuntu/home/deploy/
		cp .env /ubuntu/home/deploy/
		'''
		}
	}

	stage('docker copy to host'){
		steps{
			sshagent(['docker-server-ssh']) {
                	sh '''
                	ssh -o StrictHostKeyChecking=no ${host}@${host_ip} "rm -rf ${deploy_path} && mkdir -p ${deploy_path}"
                	scp -o StrictHostKeyChecking=no ${deploy_path}/.env ${deploy_path}/* ${host}@${host_ip}:${deploy_path}
                	'''
			}
		}
	}

	stage('build image'){
		steps{
			sshagent(['docker-server-ssh']) {
                	sh '''
                	ssh -o StrictHostKeyChecking=no ${host}@${host_ip}
                	"cd ${deploy_path} &&
                	docker build -t ${AppImage}:${IMAGE_TAG} -f ${spring_file} . &&
                	docker build -t ${DbImage}:${IMAGE_TAG} -f ${Db_file} . "
                	'''
			}
		}
	}

	stage('deploy_to_container'){
		steps{
			sshagent(['docker-server-ssh']) {
               	 	sh '''
               	 	ssh -o StrictHostKeyChecking=no ${host}@${host_ip}
               	 	"cd ${deploy_path} &&
               	 	export DOCKER_TAG=${IMAGE_TAG} &&
			docker compose down  || true &&
			docker compose up -d"
	                '''
			}
		}
	}
}

}
