// Jenkinsfile.ci - For Docker Compose Deployments
// Updated with Secret Scanning, Integration Tests, and Cleanup

pipeline {
    agent { label 'docker-build-agent' }

    environment {
        APP_NAME         = 'sockshop-frontend'
        DOCKER_REG       = credentials('ecr-registry-url')
        IMAGE_TAG        = "${env.BUILD_NUMBER}"
        SONAR_PROJECT_KEY= "${APP_NAME}"
        SNYK_FAIL_ON     = '--fail-on=high'
        SNYK_TOKEN       = credentials('snyk-token')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'git@github.com:your_org/sock-shop-frontend.git', changelog: false, poll: false, depth: 1
            }
        }

        stage('Secret Scanning (GitLeaks)') {
            // Detect hardcoded secrets before any other processing.
            steps {
                // Ensure the 'gitleaks' binary is installed on your build agent.
                // This command scans the repository and fails the build if any secrets are found.
                sh 'gitleaks detect --source . --verbose --report-path gitleaks-report.json'
            }
            post {
                always {
                    // Archive the report for security auditing.
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                }
            }
        }
        
        stage('Install & Cache Dependencies') {
            steps {
                cache(path: 'node_modules', key: "npm-${hashFiles('package-lock.json')}") {
                    sh 'npm ci'
                }
            }
        }

        stage('Testing') {
            parallel {
                stage('Linting & Unit Tests') {
                    steps {
                        sh 'npm run lint'
                        sh 'npm test -- --reporters=default --reporters=jest-junit'
                    }
                    post {
                        always {
                            junit 'junit.xml'
                        }
                    }
                }
                stage('Simple Integration Tests') {
                    // Run tests that check interactions between components,
                    // using mocks, stubs, or in-memory databases to avoid external dependencies.
                    steps {
                        script {
                            echo "Running simple integration tests..."
                            // This command should execute your integration test suite.
                            // For example, it could use Jest to test API routes with a mocked database.
                            sh 'npm run test:integration:simple -- --reporters=jest-junit --outputFile=integration-junit.xml'
                        }
                    }
                    post {
                        always {
                            // Publish integration test results separately.
                            junit 'integration-junit.xml'
                        }
                    }
                }
            }
        }

        stage('Security Scanning (SAST & SCA)') {
            steps {
                parallel(
                    "SAST Scan (SonarQube)": {
                        withSonarQubeEnv('Your-SonarQube-Server') {
                            sh "sonar-scanner"
                        }
                    },
                    "SCA Scan (Snyk)": {
                        sh "snyk auth ${SNYK_TOKEN}"
                        sh "snyk test --json > snyk-report.json || true"
                        archiveArtifacts artifacts: 'snyk-report.json'
                        sh "snyk test ${SNYK_FAIL_ON}"
                    }
                )
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def fullImage = "${DOCKER_REG}/${APP_NAME}:${IMAGE_TAG}"
                    def latestImage = "${DOCKER_REG}/${APP_NAME}:latest"
                    sh "docker build --cache-from=${latestImage} -t ${fullImage} -t ${latestImage} ."
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
                    def fullImage = "${DOCKER_REG}/${APP_NAME}:${IMAGE_TAG}"
                    try {
                        sh "trivy image --exit-code 1 --severity HIGH,CRITICAL --format json -o trivy-report.json ${fullImage}"
                    } catch (e) {
                        error "Failing build due to critical container vulnerabilities."
                    } finally {
                        archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            // Prune old Docker images from the build agent to conserve disk space.
            sh 'docker image prune -a -f --filter "until=24h"'
        }
        success {
            build job: 'sockshop-frontend-cd-docker-compose', parameters: [string(name: 'IMAGE_TAG', value: IMAGE_TAG)]
            slackSend channel: '#ci-success', color: 'good',
                message: "✅ CI SUCCESS: ${APP_NAME} build #${env.BUILD_NUMBER} completed. Image `${DOCKER_REG}/${APP_NAME}:${IMAGE_TAG}` is ready. <${env.BUILD_URL}|View Build>"
        }
        failure {
            slackSend channel: '#ci-failures', color: 'danger',
                message: "🚨 CI FAILED: ${APP_NAME} build #${env.BUILD_NUMBER} failed at stage: `${STAGE_NAME}`. <${env.BUILD_URL}|View Build>"
        }
    }
} 