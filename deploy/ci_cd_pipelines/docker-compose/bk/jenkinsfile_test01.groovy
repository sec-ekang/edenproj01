pipeline {
    // 1. Agent & Tools: run on nodes labeled 'docker-build-agent'
    agent { label 'docker-build-agent' }

    // Ensure Node.js 16 is available for build and test tasks
    tools { nodejs 'NodeJS_16' }

    // 2. Environment Variables: define key settings and credentials
    environment {
        APP_NAME          = 'sockshop-frontend'                // Application identifier
        DOCKER_REG        = credentials('ecr-registry-url')    // ECR registry URL credential
        IMAGE_TAG         = "${env.BUILD_NUMBER}"              // Use build number as Docker tag
        SONAR_PROJECT_KEY = "${APP_NAME}"                      // SonarQube project key
        SNYK_FAIL_ON      = '--fail-on=high'                   // Snyk failure threshold
        SNYK_TOKEN        = credentials('snyk-token')          // Snyk API token
    }

    // 3. Global Options: build retention, concurrency, logging features
    options {
        buildDiscarder(logRotator(numToKeepStr: '20')) // Keep last 20 builds
        disableConcurrentBuilds()                      // Prevent overlapping runs
        timestamps()                                   // Add timestamps to console output
        ansiColor('xterm')                             // Enable colored logs
    }

    // 4. Deployment Parameter: control CD step
    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['none', 'staging', 'production'],
            description: 'Select deployment environment (none to skip deployment)'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                // 1. Checkout: clone code, compatible with multibranch pipelines
                checkout scm
            }
        }

        stage('Secret Scanning (GitLeaks)') {
            steps {
                // 2. GitLeaks: detect accidental secrets using committed rules
                sh """
                   gitleaks detect \
                     --source . \
                     --config .gitleaks.toml \
                     --verbose \
                     --report-path=gitleaks-report.json
                """
            }
            post {
                always {
                    // Archive the secrets scan report
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                }
                failure {
                    // Fail fast on any detected secret
                    error "🚨 GitLeaks found secrets — aborting build."
                }
            }
        }

        stage('Install & Cache Dependencies') {
            steps {
                // 3. Dependency install with caching for faster rebuilds
                cache(path: 'node_modules', key: "npm-${hashFiles('package-lock.json')}") {
                    sh 'npm ci' // Clean install dependencies
                }
            }
        }

        stage('Lint & Unit Tests') {
            steps {
                // 4. Quality & Unit Testing: lint code and run unit tests
                sh 'npm run lint'
                sh 'npm test -- --reporters=default --reporters=jest-junit'
            }
            post {
                always {
                    // Archive JUnit report
                    junit 'junit.xml'
                }
            }
        }

        stage('Simple Integration Tests') {
            steps {
                // 5. Integration Tests: lightweight service-to-service checks
                sh 'npm run test:integration:simple -- --reporters=jest-junit --outputFile=integration-junit.xml'
            }
            post {
                always {
                    // Archive integration test report
                    junit 'integration-junit.xml'
                }
            }
        }

        stage('Smoke Tests') {
            steps {
                // 6. Smoke Tests: quick validation of basic functionality
                sh 'npm run test:smoke'
            }
        }

        stage('Security Scanning') {
            parallel {
                stage('SAST (SonarQube)') {
                    steps {
                        // 7a. Static Analysis: run SonarQube scan
                        withSonarQubeEnv('Your-SonarQube-Server') {
                            sh 'sonar-scanner'
                        }
                    }
                }
                stage('SCA (Snyk)') {
                    steps {
                        // 7b. Dependency Analysis: authenticate, test, archive, enforce failure
                        sh 'snyk auth ${SNYK_TOKEN}'
                        sh 'snyk test --json > snyk-report.json || true'
                        archiveArtifacts artifacts: 'snyk-report.json', allowEmptyArchive: true
                        sh "snyk test ${SNYK_FAIL_ON}"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // 8. SonarQube Quality Gate: wait up to 5 minutes, abort on failure
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // 9. Docker Build: use cache, tag with build number and 'latest'
                    def fullImage   = "${DOCKER_REG}/${APP_NAME}:${IMAGE_TAG}"
                    def latestImage = "${DOCKER_REG}/${APP_NAME}:latest"

                    // Prime layer cache
                    sh "docker pull ${latestImage} || true"
                    // Build images
                    sh "docker build --cache-from=${latestImage} -t ${fullImage} -t ${latestImage} ."

                    // Push to registry
                    docker.withRegistry("https://${DOCKER_REG}", 'ecr:ap-northeast-1:aws-ecr-credentials') {
                        sh "docker push ${fullImage}"
                        sh "docker push ${latestImage}"
                    }
                }
            }
        }

        stage('Container Image Scan (Trivy)') {
            steps {
                script {
                    // 10. Vulnerability Scan: fail on HIGH/CRITICAL issues
                    def fullImage = "${DOCKER_REG}/${APP_NAME}:${IMAGE_TAG}"
                    try {
                        sh "trivy image --exit-code 1 --severity HIGH,CRITICAL --format json -o trivy-report.json ${fullImage}"
                    } catch (err) {
                        error "🚨 Trivy found critical vulnerabilities — aborting build."
                    } finally {
                        archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                    }
                }
            }
        }

        stage('Deployment') {
            when {
                // 11. Conditional Deployment: skip if 'none'
                expression { params.DEPLOY_ENV != 'none' }
            }
            steps {
                script {
                    // Choose appropriate .env file
                    def envFile = (params.DEPLOY_ENV == 'production') ? '.env.production' : '.env.staging'

                    // Shutdown existing services and remove orphans
                    sh "docker-compose down --remove-orphans || true"

                    // Deploy new image
                    sh "docker pull ${DOCKER_REG}/${APP_NAME}:${IMAGE_TAG}"
                    sh "docker-compose --env-file ${envFile} up -d"

                    // Wait for containers to start
                    sleep 10

                    // Health check to verify deployment
                    sh 'curl --fail http://localhost/health || exit 1'
                }
            }
        }
    }

    post {
        always {
            // Cleanup: workspace and old images
            cleanWs()
            sh 'docker image prune -a -f --filter "until=24h"'
        }
        success {
            // Notification on success
            slackSend(
                channel: '#ci-notifications',
                color: 'good',
                message: "✅ `${APP_NAME}:${IMAGE_TAG}` (${params.DEPLOY_ENV}) succeeded [Stage: ${env.STAGE_NAME}]"
            )
        }
        failure {
            // Notification on failure
            slackSend(
                channel: '#ci-notifications',
                color: 'danger',
                message: "🚨 `${APP_NAME}:${IMAGE_TAG}` (${params.DEPLOY_ENV}) failed at stage: `${env.STAGE_NAME}`"
            )
        }
    }
}