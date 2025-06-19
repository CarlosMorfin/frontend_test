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
    }

    post {
        always {
            // echo ''
            cleanWs()
        }
    }
}
