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

        stage("Obtener version") {
            steps{
                script{
                    echo 'Obteniendo la version de la aplicacion'
                    // def appVersion= 
                    env.APP_VERSION = sh( script: "node -p \\"require('./package.json').version\\"", returnStdout: true ).trim()
                    echo "version de la aplicacion: ${env.APP_VERSION}"
                }
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
                echo "Build Docker Image: ${env.IMAGE_NAME}:${env.TAG}"
                script {
                    def dockerImage = docker.build("${env.IMAGE_NAME}:${env.TAG}", ".")
                    dockerImage.tag('latest')
                }
            }
        }

        stage('Push Docker Imge') {
            steps {
                echo "Push Docker Image: ${env.IMAGE_NAME}:${env.TAG}"
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER_VAR', passwordVariable: 'DOCKER_PASS_VAR')]) {
                    script {
                        sh "echo ${DOCKER_PASS_VAR} | docker login -u ${DOCKER_USER_VAR} --password-stdin"

                        docker.image("${env.IMAGE_NAME}:${env.TAG}").push()
                        docker.image("${env.IMAGE_NAME}:latest").push()

                        sh "docker logout"
                    }
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
