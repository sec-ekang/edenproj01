// Jenkinsfile.cd - Updated with Slack-based Approval Workflow

pipeline {
    agent { label 'kubernetes-deploy-agent' }

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: '', description: 'Docker image tag passed from the CI pipeline')
    }

    environment {
        APP_NAME         = 'sockshop-frontend'
        DOCKER_REG       = credentials('ecr-registry-url')
        MANIFESTS_REPO_URL= 'git@github.com:your_org/sock-shop-manifests.git'
        ARGOCD_SERVER_URL = 'argo.example.com'
        ARGOCD_AUTH_TOKEN= credentials('argocd-auth-token')
        DATADOG_API_KEY  = credentials('datadog-api-key')
        // Dedicated channel for approval notifications
        SLACK_APPROVAL_CHANNEL = '#deployments-approval'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '25'))
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Checkout Manifests Repo') {
            steps {
                dir('manifests') {
                    git branch: 'main', url: MANIFESTS_REPO_URL, credentialsId: 'git-manifests-creds'
                }
            }
        }
        
        stage('Deploy to QA & Test') {
            // Unchanged from previous version
            steps {
                dir('manifests/qa') {
                    sh "yq e '.spec.template.spec.containers[0].image = \"${DOCKER_REG}/${APP_NAME}:${params.IMAGE_TAG}\"' -i deployment.yaml"
                    sh """
                        git config user.name 'Jenkins CD'
                        git config user.email 'jenkins@example.com'
                        git commit -m "feat: Deploy ${APP_NAME}:${params.IMAGE_TAG} to QA"
                        git push origin main
                    """
                }
                script {
                    sh "argocd login ${ARGOCD_SERVER_URL} --auth-token ${ARGOCD_AUTH_TOKEN} --insecure"
                    sh "argocd app sync sockshop-frontend-qa --wait --timeout 300"
                    echo "Placeholder for running integration and DAST tests in QA."
                }
            }
        }

        stage('Approve for Staging') {
            // Updated Stage: Slack-based approval workflow
            steps {
                script {
                    // 1. Send a notification to Slack with a direct link to the approval action.
                    // A true ChatOps solution would have interactive buttons in Slack that send a
                    // callback to a service that resumes the Jenkins pipeline. This pattern is a
                    // robust alternative that keeps the logic within Jenkins.
                    slackSend(
                        channel: SLACK_APPROVAL_CHANNEL,
                        color: 'warning',
                        message: "🔔 *Approval Needed for STAGING* | App: `${APP_NAME}` | Version: `${params.IMAGE_TAG}` | Please <${env.BUILD_URL}input/|approve or reject this deployment>."
                    )

                    // 2. The input step pauses the pipeline, waiting for an authorized user to interact in the Jenkins UI.
                    timeout(time: 2, unit: 'HOURS') {
                        input message: "Deploy ${APP_NAME}:${params.IMAGE_TAG} to STAGING? (See Slack for notification)", submitter: 'dev-leads,qa-team'
                    }
                    
                    // 3. If approved, send a confirmation message to a general channel.
                    slackSend(
                        channel: '#deployments',
                        color: 'good',
                        message: "✅ Staging deployment for `${APP_NAME}:${params.IMAGE_TAG}` was approved and is proceeding."
                    )
                }
            }
        }


        stage('Deploy & Test in Staging') {
            // Unchanged from previous version
            steps {
                dir('manifests/staging') {
                    sh "yq e '.spec.template.spec.containers[0].image = \"${DOCKER_REG}/${APP_NAME}:${params.IMAGE_TAG}\"' -i deployment.yaml"
                    sh "git commit -am 'feat: Promote ${APP_NAME}:${params.IMAGE_TAG} to Staging' && git push origin main"
                }
                sh "argocd app sync sockshop-frontend-staging --wait --timeout 300"
                echo "Placeholder for running acceptance and performance tests in Staging."
            }
        }
        
        stage('Approve for Production') {
            // Updated Stage: Slack-based approval workflow for the critical production gate
            steps {
                script {
                    slackSend(
                        channel: SLACK_APPROVAL_CHANNEL,
                        color: '#FF0000', // Use a more urgent color for production
                        message: "🚨 *CRITICAL Approval Needed for PRODUCTION* | App: `${APP_NAME}` | Version: `${params.IMAGE_TAG}` | Please <${env.BUILD_URL}input/|approve or reject this deployment>."
                    )

                    timeout(time: 4, unit: 'HOURS') {
                        input message: "CRITICAL: Approve deployment of ${APP_NAME}:${params.IMAGE_TAG} to PRODUCTION? (See Slack for notification)", submitter: 'ops-team,release-managers'
                    }

                    slackSend(
                        channel: '#deployments',
                        color: 'good',
                        message: "✅ Production deployment for `${APP_NAME}:${params.IMAGE_TAG}` was approved and is proceeding."
                    )
                }
            }
        }
        
        stage('Deploy to Production (Canary)') {
            // Unchanged from previous version
            steps {
                script {
                    dir('manifests/prod') {
                        sh "yq e '.spec.template.spec.containers[0].image = \"${DOCKER_REG}/${APP_NAME}:${params.IMAGE_TAG}\"' -i rollout.yaml"
                        sh "git commit -am 'feat: Begin canary deployment of ${APP_NAME}:${params.IMAGE_TAG} to Production' && git push origin main"
                    }
                    sh "argocd app sync sockshop-frontend-prod --wait=false"
                    timeout(time: 20, unit: 'MINUTES') {
                        input message: "Canary is running. Analyze metrics. Promote to 100% or Abort?"
                    }
                    sh "kubectl argo rollouts promote sockshop-frontend-prod"
                    sh "argocd app wait sockshop-frontend-prod --health --timeout 600"
                }
            }
        }

        stage('Verify Production (SRE Check)') {
            // Unchanged from previous version
            steps {
                sleep 30
                echo "Placeholder for SLO checks."
            }
        }
    }

    post {
        // Unchanged from previous version
        always {
            cleanWs()
            sh "argocd logout ${ARGOCD_SERVER_URL} || true"
        }
        success {
            slackSend channel: '#deployments', color: 'good', message: "✅ DEPLOY SUCCESS: `${APP_NAME}:${params.IMAGE_TAG}` is live in Production. <${env.BUILD_URL}|View Build>"
            sh """
              curl -X POST "https://api.datadoghq.com/api/v1/events?api_key=${DATADOG_API_KEY}" \\
              -H "Content-Type: application/json" \\
              -d '{"title": "Deployment: ${APP_NAME}", "text": "Version ${params.IMAGE_TAG} deployed.", "tags": ["deployment", "env:prod", "app:${APP_NAME}"]}'
            """
        }
        failure {
            slackSend channel: '#alerts', color: 'danger', message: "🚨 DEPLOY FAILED: Pipeline for `${APP_NAME}:${params.IMAGE_TAG}` failed at stage `${STAGE_NAME}`. <${env.BUILD_URL}|View Build>"
            script {
                echo "A failure was detected. Initiating automated rollback in production."
                sh "kubectl argo rollouts undo sockshop-frontend-prod"
                slackSend channel: '#alerts', color: 'warning', message: "🔁 AUTOMATED ROLLBACK initiated for `${APP_NAME}` in production due to pipeline failure."
            }
        }
    }
}
