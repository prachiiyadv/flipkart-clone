pipeline {
    agent any

    environment {
        APP_NAME     = "flipkart-app"
        GREEN_TAG    = "green-${BUILD_NUMBER}"
        COMPOSE_FILE = "docker-compose-bg.yml"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/prachiiyadv/flipkart-clone.git'
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
                echo "Stopping old GREEN container if exists..."
                docker stop flipkart-green || true
                docker rm flipkart-green || true

                echo "Tagging new GREEN image..."
                docker tag ${APP_NAME}:${GREEN_TAG} ${APP_NAME}:2.0

                echo "Starting GREEN container..."
                docker-compose -f ${COMPOSE_FILE} up -d green
                """
            }
        }

        stage('Health Check Green') {
            steps {
                sh """
                echo "Waiting for GREEN container to be healthy..."
                sleep 10
                docker ps | grep flipkart-green
                """
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                sh """
                echo "Switching Nginx traffic to GREEN..."

                sed -i 's/server blue:80;/# server blue:80;/g' nginx/nginx.conf
                sed -i 's/# server green:80;/server green:80;/g' nginx/nginx.conf

                docker exec flipkart-nginx nginx -s reload
                """
            }
        }
    }
        stage('Trivy Image Scan') {
    steps {
        sh '''
        trivy image --exit-code 1 --severity CRITICAL,HIGH flipkart-app:latest
        '''
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
            echo "✅ Deployment successful. GREEN is live, BLUE kept for rollback."
        }
    }
}
