pipeline {
    // Defines the agent and tools for the pipeline
    agent { 
        label 'docker-build-agent' 
    }


    // Defines environment variables
    environment {
        REPO = 'sec-ekang/sock-shop_front-end'
        APP_NAME          = 'test01-frontend'                // Application identifier
        IMAGE_TAG         = "${env.BUILD_NUMBER}"              // Uses build number as Docker tag
        DOCKER_HUB_USER   = 'edenkang'         // Your Docker Hub username
    }

    // Configures global options for the pipeline
    options {
        buildDiscarder(logRotator(numToKeepStr: '20')) // Keeps the last 20 builds
        disableConcurrentBuilds()                      // Prevents overlapping runs
        timestamps()                                   // Adds timestamps to console output
        ansiColor('xterm')                             // Enables colored logs
    }

    stages {
        stage('Docker Build & Push') {
            steps {
                script {
                    // Builds and pushes Docker images
                    def fullImage   = "${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                    def latestImage = "${DOCKER_HUB_USER}/${APP_NAME}:latest"

                    dir('front-end') {
                        // Primes the layer cache
                        sh "docker pull ${latestImage} || true"
                        // Builds images
                        sh "docker build --cache-from=${latestImage} -t ${fullImage} -t ${latestImage} ."

                        // Pushes to the Docker registry
                        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                            sh "docker push ${fullImage}"
                            sh "docker push ${latestImage}"
                        }
                    }
                }
            }
        }

/*         stage('Deployment') {
            steps {
                script {
                    dir('front-end') {
                        sh "docker-compose down --remove-orphans || true"
                        sh "docker pull ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                        sh "docker-compose up -d"
                        sleep 10
                        sh 'curl --fail http://localhost/health || exit 1'
                    }
                }
            }
        } */
    }

    post {
        always {
            // Cleans up the workspace and old images
            cleanWs()
            sh 'docker image prune -a -f --filter "until=24h"'
        }
        success {
            // Sends a success notification
            slackSend(
                channel: '#test01',
                color: 'good',
                message: "✅ `${APP_NAME}:${IMAGE_TAG}` succeeded [Stage: ${env.STAGE_NAME}]"
            )
        }
        failure {
            // Sends a failure notification
            slackSend(
                channel: '#test01',
                color: 'danger',
                message: "🚨 `${APP_NAME}:${IMAGE_TAG}` failed at stage: `${env.STAGE_NAME}`"
            )
        }
    }
}