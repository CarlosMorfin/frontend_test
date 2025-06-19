pipeline {
    agent any

    // environment {

    // }

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
    }

    post {
        always {
            echo 'Limpiando workspace...'
            cleanWs()
        }
    }
}
