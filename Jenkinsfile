pipeline {
    agent any

    // environment {

    // }

    stages {
        stage('Checkout'){
            steps {
                echo 'Clonado de repositorio'
                chekcout scm
            }
        }

    }

    post {
        always {
            echo ''
            cleanWs()
        }
    }
}
