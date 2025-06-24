pipeline {
    // Defines the agent and tools for the pipeline
    agent { label 'docker-build-agent' }

    // Ensures Node.js 16 is available for tasks
    tools { nodejs 'NodeJS_16' }

    // Defines environment variables
    environment {
        APP_NAME          = 'sockshop-frontend'                // Application identifier
        IMAGE_TAG         = "${env.BUILD_NUMBER}"              // Uses build number as Docker tag
        DOCKER_HUB_USER   = 'your_docker_hub_username'         // Your Docker Hub username
    }

    // Configures global options for the pipeline
    options {
        buildDiscarder(logRotator(numToKeepStr: '20')) // Keeps the last 20 builds
        disableConcurrentBuilds()                      // Prevents overlapping runs
        timestamps()                                   // Adds timestamps to console output
        ansiColor('xterm')                             // Enables colored logs
    }

    // Defines a parameter for controlling the deployment step
    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['none', 'dev', 'qa', 'staging', 'prod'],
            description: 'Select deployment environment (none to skip deployment)'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                // Checks out the source code
                checkout scm
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Builds and pushes Docker images
                    def fullImage   = "${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                    def latestImage = "${DOCKER_HUB_USER}/${APP_NAME}:latest"

                    // Primes the layer cache
                    sh "docker pull ${latestImage} || true"
                    // Builds images
                    sh "docker build --cache-from=${latestImage} -t ${fullImage} -t ${latestImage} ."

                    // Pushes to the Docker registry
                    docker.withRegistry('https://index.docker.io/v1/') {
                        sh "docker push ${fullImage}"
                        sh "docker push ${latestImage}"
                    }
                }
            }
        }

        stage('Deployment') {
            when {
                // Conditionally deploys based on DEPLOY_ENV parameter
                expression { params.DEPLOY_ENV != 'none' }
            }
            steps {
                script {
                    // Chooses the appropriate .env file
                    def envFile = ""
                    if (params.DEPLOY_ENV == 'dev') {
                        envFile = '.env.dev'
                    } else if (params.DEPLOY_ENV == 'qa') {
                        envFile = '.env.qa'
                    } else if (params.DEPLOY_ENV == 'staging') {
                        envFile = '.env.staging'
                    } else if (params.DEPLOY_ENV == 'prod') {
                        envFile = '.env.prod'
                    }

                    // Shuts down existing services and removes orphans
                    sh "docker-compose down --remove-orphans || true"

                    // Pulls the new image and deploys
                    sh "docker pull ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                    sh "docker-compose --env-file ${envFile} up -d"

                    // Waits for containers to start
                    sleep 10

                    // Performs a health check to verify deployment
                    sh 'curl --fail http://localhost/health || exit 1'
                }
            }
        }
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
                channel: '#ci-notifications',
                color: 'good',
                message: "✅ `${APP_NAME}:${IMAGE_TAG}` (${params.DEPLOY_ENV}) succeeded [Stage: ${env.STAGE_NAME}]"
            )
        }
        failure {
            // Sends a failure notification
            slackSend(
                channel: '#ci-notifications',
                color: 'danger',
                message: "🚨 `${APP_NAME}:${IMAGE_TAG}` (${params.DEPLOY_ENV}) failed at stage: `${env.STAGE_NAME}`"
            )
        }
    }
}