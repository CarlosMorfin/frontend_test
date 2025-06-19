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
                    
                    def appVersion = sh( 
                        script: "node -p \"require('./package.json').version\"",
                        returnStdout: true
                    ).trim()

                    echo "Version de la aplicacion: ${appVersion}"

                    env.APP_VERSION = appVersion
                }
            }
        }

        stage('Install Dependecies & Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }

        // stage('Scan application with trivy') {
        //     steps {
        //         echo "Scanenado la aplicacion con trivy"
        //         sh """
        //         docker run --rm \\
        //             -v ${WORKSPACE}:/root/app \\
        //             aquasec/trivy fs --severity HIGH,CRITICAL --exit-code 1 \\
        //             /root/app/package-lock.json
        //         """

        //     }
        // }

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
                echo "Build Docker Image: ${env.IMAGE_NAME}:${env.APP_VERSION}"
                script {
                    def dockerImage = docker.build("${env.IMAGE_NAME}:${env.APP_VERSION}", ".")
                }
            }
        }

        stage('Scan Docker image') {
            steps {
                echo "Scanenado la imagen de docker"
                sh """
                docker run --rm \\
                    -v /var/run/docker.sock:/var/run/docker.sock -v /home/jesus/personal/test:/root/app  \\
                    aquasec/trivy image --severity HIGH,CRITICAL --exit-code 1 \\
                        --format template \\
                        --template "@/contrib/html.tpl" \\
                        -o /root/app/trivy-image-report.html \\
                    ${env.IMAGE_NAME}:${env.APP_VERSION}
                """

            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Push Docker Image: ${env.IMAGE_NAME}:${env.APP_VERSION}"
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER_VAR', passwordVariable: 'DOCKER_PASS_VAR')]) {
                    script {
                        sh "echo ${DOCKER_PASS_VAR} | docker login -u ${DOCKER_USER_VAR} --password-stdin"

                        docker.image("${env.IMAGE_NAME}:${env.APP_VERSION}").push()

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
