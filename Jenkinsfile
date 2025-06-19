pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "carlosmorfin"
        IMAGE_NAME = "${DOCKER_HUB_USER}/my-front"
        TAG = "${env.BUILD_NUMBER}"
    }

    tools {
        nodejs 'NodeJS-18'
    }

    stages {
        stage('Checkout'){
            steps {
                echo 'Clonado de repositorio'
                checkout scm
            }
        }

        stage('Install Dependecies & Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Enviando analisis'
                script {
                    def scannerPath = tool 'SonarScannerCLI'
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerPath}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Esperando analisis de SonarQube') {
            steps {
                echo 'Esperando analisis de SonarQube'
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Imge') {
            steps {
                echo 'Build Docker Imge'
                script {
                    def dockerImage = docker.build("${env.IMAGE_NAME}:${env.TAG}", ".")
                    dockerImage.tag('latest')
                }
            }
        }


    }

    post {
        always {
            echo 'Limpiando workspace...'
            cleanWs()
        }
    }
}
