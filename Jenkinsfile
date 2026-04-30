pipeline {
    agent any

    environment {
        APP_NAME = "springapp"
        MONGO_IMAGE = "custom-mongo"
        REMOTE_HOST = "16.171.36.37"
        REMOTE_USER = "ubuntu"
        REMOTE_APP_DIR = "/home/ubuntu/deploy/spring-boot-mongo-docker"
        APP_PORT = "8080"
        HOST_PORT = "8080"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    tools {
        maven 'maven'
        jdk 'jdk8'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-ssh',
                    url: 'git@github.com:sandeepmatolli/spring-boot-mongo-docker.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Prepare Deployment Bundle') {
            steps {
                sh '''
                    rm -rf deploy
                    mkdir -p deploy

                    cp target/spring-boot-mongo-1.0.jar deploy/
                    cp Dockerfile.app deploy/
                    cp Dockerfile.mongo deploy/
                    cp docker-compose.yml deploy/
                    cp .env deploy/
                '''
            }
        }

        stage('Copy Files To Docker Server') {
            steps {
                sshagent(credentials: ['docker-server-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_APP_DIR}"
                        scp -o StrictHostKeyChecking=no deploy/* ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_APP_DIR}/
                    '''
                }
            }
        }

        stage('Build Images On Docker Server') {
            steps {
                sshagent(credentials: ['docker-server-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                            cd ${REMOTE_APP_DIR} &&
                            docker build -t ${APP_NAME}:${IMAGE_TAG} -f Dockerfile.app . &&
                            docker build -t ${MONGO_IMAGE}:${IMAGE_TAG} -f Dockerfile.mongo .
                        "
                    '''
                }
            }
        }

        stage('Deploy Containers On Docker Server') {
            steps {
                sshagent(credentials: ['docker-server-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                            cd ${REMOTE_APP_DIR} &&
                            export IMAGE_TAG=${IMAGE_TAG} &&
                            docker compose down || true &&
                            docker compose up -d
                        "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful. App image tag: ${BUILD_NUMBER}"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
