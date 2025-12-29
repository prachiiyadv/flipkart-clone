pipeline {
    agent any

    environment {
        APP_NAME = "flipkart-app"
        GREEN_TAG = "green-${BUILD_NUMBER}"
        BLUE_TAG  = "blue-stable"
        COMPOSE_FILE = "docker-compose-bg.yml"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/prachiiyadv/flipkart-clone.git'
            }
        }

        stage('Build Green Image') {
            steps {
                sh """
                docker build -t ${APP_NAME}:${GREEN_TAG} .
                """
            }
        }

        stage('Deploy Green') {
            steps {
                sh """
                docker tag ${APP_NAME}:${GREEN_TAG} ${APP_NAME}:2.0
                docker-compose -f ${COMPOSE_FILE} up -d green
                """
            }
        }

        stage('Health Check Green') {
            steps {
                sh """
                sleep 10
                docker ps | grep flipkart-green
                """
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                sh """
                sed -i 's/server blue:80;/# server blue:80;/g' nginx/nginx.conf
                sed -i 's/# server green:80;/server green:80;/g' nginx/nginx.conf
                docker exec flipkart-nginx nginx -s reload
                """
            }
        }
    }

    post {
        failure {
            echo "❌ Deployment failed. Rolling back to BLUE..."

            sh """
            sed -i 's/server green:80;/# server green:80;/g' nginx/nginx.conf
            sed -i 's/# server blue:80;/server blue:80;/g' nginx/nginx.conf
            docker exec flipkart-nginx nginx -s reload
            """
        }

        success {
            echo "✅ Green deployment successful. Blue kept as rollback."
        }
    }
}

