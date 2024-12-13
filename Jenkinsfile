pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        AWS_ACCESS_KEY_ID     = credentials('aws-credentials')
        AWS_SECRET_ACCESS_KEY = credentials('aws-credentials')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'git@github.com:satishgonella2024/wordpress-app-deployment.git'
            }
        }

       pipeline {
    agent any

    stages {
        stage('Fetch Infra Artifacts') {
            steps {
                copyArtifacts(
                    projectName: 'wp-infra-pipeline',
                    filter: 'infra-output.json',
                    selector: lastSuccessful()
                )
                sh 'cat infra-output.json' // Debugging step
                script {
                    def jsonFileContent = readFile('infra-output.json').trim() // Trim extra spaces
                    echo "Raw JSON Content: ${jsonFileContent}" // Debugging step
                    def infra = readJSON text: jsonFileContent
                    env.APP_DNS = infra.app_dns
                    env.APP_PORT = infra.app_port
                }
            }
        }
    }


    stage('Dockerize') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    passwordVariable: 'DOCKER_PASSWORD',
                    usernameVariable: 'DOCKER_USERNAME'
                )]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker build -t satish2024/wordpress:latest .
                        docker push satish2024/wordpress:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy Application') {
            steps {
                sshagent(['ec2-instance-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ec2-user@${APP_DNS} << EOF
                    docker pull satish2024/wordpress:latest
                    docker ps -q --filter "name=wordpress" | grep -q . && docker stop wordpress && docker rm wordpress || true
                    docker run -d -p ${APP_PORT}:${APP_PORT} --name wordpress satish2024/wordpress:latest
                    EOF
                    '''
                }
            }
        }

        stage('Post-Deployment Validation') {
            steps {
                script {
                    def status = sh(script: '''
                        curl -o /dev/null -s -w "%{http_code}" http://${APP_DNS}:${APP_PORT}
                    ''', returnStdout: true).trim()
                    if (status != '200') {
                        error "Post-deployment validation failed! HTTP Status: ${status}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Application deployment successful.'
        }
        failure {
            echo 'Application deployment failed.'
        }
    }
}
