
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t flipkart-app:latest .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL flipkart-app:latest'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker stop flipkart-app || true
                docker rm flipkart-app || true
                docker run -d -p 80:80 --name flipkart-app flipkart-app:latest
                '''
            }
        }
    }
}
