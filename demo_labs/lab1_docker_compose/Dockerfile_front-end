pipeline {
    // Defines the agent and tools for the pipeline
    agent { 
        label 'docker-build-agent' 
    }


    // Defines environment variables
    environment {
        REPO_USER = 'sec-ekang'
        REPO_NAME = 'sock-shop_front-end'
        REPO = "${REPO_USER}/${REPO_NAME}"              // Repository name (github)
        DOCKER_HUB_USER   = 'edenkang'                       // Your Docker Hub username
        APP_NAME          = 'test01-frontend'                // Application identifier (Docker Hub)
        IMAGE_NAME        = "${DOCKER_HUB_USER}/${APP_NAME}"  // Docker Hub image name
        IMAGE_TAG         = "${env.BUILD_NUMBER}"              // Uses build number as Docker tag
    }

    // Configures global options for the pipeline
    options {
        buildDiscarder(logRotator(numToKeepStr: '20')) // Keeps the last 20 builds
        disableConcurrentBuilds()                      // Prevents overlapping runs
        timestamps()                                   // Adds timestamps to console output
        ansiColor('xterm')                             // Enables colored logs
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    try {
                        def gitUrl = "https://github.com/${env.REPO}.git"
                        echo "Attempting to clone from URL: ${gitUrl}"
                        sh "git clone ${gitUrl} front-end"
                        dir('front-end') {
                            sh "git checkout master"
                        }
                    } catch (err) {
                        env.FAILED_STEP = 'Checkout'
                        throw err
                    }
                }
            }
        }
      
        stage('Remove Previous Docker Image') {
            steps {
                script {
                    try {
                        // Find and stop/remove containers using any tag of the image
                        def containers = sh(script: "docker ps -a -q --filter ancestor=${IMAGE_NAME}", returnStdout: true).trim()
                        if (containers) {
                            echo "Found containers from previous builds to remove:\n${containers}"
                            sh "docker stop ${containers.replaceAll('\\n', ' ')} || true"
                            sh "docker rm ${containers.replaceAll('\\n', ' ')} || true"
                            echo "Stopped and removed old containers."
                        } else {
                            echo "No containers found for ${IMAGE_NAME}."
                        }

                        // Find and remove all tags of the image
                        def images = sh(script: "docker images -q ${IMAGE_NAME}", returnStdout: true).trim()
                        if (images) {
                            echo "Found previous images for ${IMAGE_NAME} to remove:\n${images}"
                            sh "docker rmi -f ${images.replaceAll('\\n', ' ')} || true"
                            echo "Deleted previous Docker images."
                        } else {
                            echo "No Docker images found for ${IMAGE_NAME}."
                        }
                    } catch (err) {
                        env.FAILED_STEP = 'Remove Previous Docker Image'
                        throw err
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    try {
                        // Builds and pushes Docker images
                        def fullImage   = "${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                        def latestImage = "${DOCKER_HUB_USER}/${APP_NAME}:latest"

                        dir('front-end') {
                            // Primes the layer cache
                            sh "docker pull ${latestImage} || true"
                            // Builds images
                            sh "docker build --cache-from=${latestImage} -t ${fullImage} -t ${latestImage} ."
                            // sh "docker build --no-cache -t ${fullImage} -t ${latestImage} ."

                            // Pushes to the Docker registry
                            docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                                sh "docker push ${fullImage}"
                                sh "docker push ${latestImage}"
                            }
                        }
                    } catch (err) {
                        env.FAILED_STEP = 'Docker Build & Push'
                        throw err
                    }
                }
            }
        }

        stage('Deployment') {
            steps {
                script {
                    try {
                        // Stop any container using port 80 to prevent conflicts
                        def containerOnPort80 = sh(script: "docker ps -q --filter 'publish=80'", returnStdout: true).trim()
                        if (containerOnPort80) {
                            echo "Found and stopping container ${containerOnPort80} using port 80."
                            sh "docker stop ${containerOnPort80}"
                        }

                        dir('front-end') {
                            sh "chmod 644 docker-compose.yml"
                            // Pass environment variables to docker-compose
                            sh "DOCKER_HUB_USER=${DOCKER_HUB_USER} APP_NAME=${APP_NAME} IMAGE_TAG=${IMAGE_TAG} MYSQL_ROOT_PASSWORD= docker-compose -f docker-compose.yml down --rmi all --remove-orphans || true"
                            sh "docker pull ${DOCKER_HUB_USER}/${APP_NAME}:${IMAGE_TAG}"
                            sh "DOCKER_HUB_USER=${DOCKER_HUB_USER} APP_NAME=${APP_NAME} IMAGE_TAG=${IMAGE_TAG} MYSQL_ROOT_PASSWORD= docker-compose -f docker-compose.yml up -d"
                        }
                        sleep 10
                        sh 'curl --fail http://localhost/metrics || exit 1'
                    } catch (err) {
                        env.FAILED_STEP = 'Deployment'
                        throw err
                    }
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
                channel: '#test01',
                color: 'good',
                message: "✅ `${APP_NAME}:${IMAGE_TAG}` succeeded!"
            )
        }
        failure {
            // Sends a failure notification
            slackSend(
                channel: '#test01',
                color: 'danger',
                message: "🚨 `${APP_NAME}:${IMAGE_TAG}` failed at stage: `${env.FAILED_STEP ?: env.STAGE_NAME}`"
            )
        }
    }
}