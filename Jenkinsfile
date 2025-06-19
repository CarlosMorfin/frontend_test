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
                script {
                    def scannerPath = tool 'SonarScannerCLI'
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerPath}/bin/sonar-scanner"
                    }
                }
            }
        }
    }

    post {
        always {
            // echo ''
            cleanWs()
        }
    }
}
