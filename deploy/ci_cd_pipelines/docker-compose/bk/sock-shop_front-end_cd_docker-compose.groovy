// Jenkinsfile.cd - For Docker Compose Deployments

pipeline {
    agent { label 'docker-deploy-agent' }

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: '', description: 'Docker image tag passed from the CI pipeline')
    }

    environment {
        APP_NAME         = 'sockshop-frontend'
        DOCKER_REG       = credentials('ecr-registry-url')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Checkout Application Repo') {
            steps {
                // Checkout the application repository that contains the docker-compose.yml
                git branch: 'main', url: 'git@github.com:your_org/sock-shop-frontend.git', changelog: false, poll: false, depth: 1
            }
        }
        
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    // Stop and remove existing containers (if any) to ensure a clean deployment
                    sh 'docker-compose down || true'
                    // Pull the new image
                    sh "docker pull ${DOCKER_REG}/${APP_NAME}:${params.IMAGE_TAG}"
                    // Deploy using docker-compose.yml
                    // Ensure your docker-compose.yml references the DOCKER_REG and APP_NAME variables
                    // For example, image: "${DOCKER_REG}/${APP_NAME}:${IMAGE_TAG}"
                    sh 'docker-compose up -d'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            slackSend channel: '#deployments', color: 'good', message: "✅ DEPLOY SUCCESS: `${APP_NAME}:${params.IMAGE_TAG}` deployed with Docker Compose. <${env.BUILD_URL}|View Build>"
        }
        failure {
            slackSend channel: '#alerts', color: 'danger', message: "🚨 DEPLOY FAILED: Docker Compose pipeline for `${APP_NAME}:${params.IMAGE_TAG}` failed at stage `${STAGE_NAME}`. <${env.BUILD_URL}|View Build>"
        }
    }
} 