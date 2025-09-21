@Library('Shared') _
pipeline {
    agent any
    
    environment{
        SONAR_HOME = tool "Sonar"
    }
    
    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: 'latest-frontend', description: 'Docker tag for frontend image')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: 'latest-backend', description: 'Docker tag for backend image')
    }
    
    stages {
        stage("Validate Parameters") {
            steps {
                script {
                    if (params.FRONTEND_DOCKER_TAG == '' || params.BACKEND_DOCKER_TAG == '') {
                        echo "⚠️ Warning: Docker tags not provided, using defaults."
                        if (params.FRONTEND_DOCKER_TAG == '') {
                            params.FRONTEND_DOCKER_TAG = "latest-frontend"
                        }
                        if (params.BACKEND_DOCKER_TAG == '') {
                            params.BACKEND_DOCKER_TAG = "latest-backend"
                        }
                    }
                    echo "FRONTEND_DOCKER_TAG: ${params.FRONTEND_DOCKER_TAG}"
                    echo "BACKEND_DOCKER_TAG: ${params.BACKEND_DOCKER_TAG}"
                }
            }
        }
        
        stage("Workspace cleanup"){
            steps{
                script{
                    cleanWs()
                }
            }
        }
        
        stage('Git: Code Checkout') {
            steps {
                script{
                    code_checkout("https://github.com/sahukalu/Wanderlust-Mega-Project.git","main")
                }
            }
        }
        
        stage("Trivy: Filesystem scan"){
            steps{
                script{
                    trivy_scan()
                }
            }
        }

        stage("OWASP: Dependency check"){
            steps{
                script{
                    owasp_dependency()
                }
            }
        }
        
        stage("SonarQube: Code Analysis"){
            steps{
                script{
                    sonarqube_analysis("Sonar","wanderlust","wanderlust")
                }
            }
        }
        
        stage("SonarQube: Code Quality Gates"){
            steps{
                script{
                    sonarqube_code_quality()
                }
            }
        }
        
        stage('Exporting environment variables') {
            parallel{
                stage("Backend env setup"){
                    steps {
                        script{
                            dir("Automations"){
                                sh "bash updatebackendnew.sh"
                            }
                        }
                    }
                }
                
                stage("Frontend env setup"){
                    steps {
                        script{
                            dir("Automations"){
                                sh "bash updatefrontendnew.sh"
                            }
                        }
                    }
                }
            }
        }
        
        stage("Docker: Build Images"){
            steps{
                script{
                    dir('backend'){
                        docker_build("wanderlust-backend-beta","${params.BACKEND_DOCKER_TAG}","kalusahu902")
                    }
                    
                    dir('frontend'){
                        docker_build("wanderlust-frontend-beta","${params.FRONTEND_DOCKER_TAG}","kalusahu902")
                    }
                }
            }
        }
        
        stage("Docker: Push to DockerHub"){
            steps{
                script{
                    docker_push("wanderlust-backend-beta","${params.BACKEND_DOCKER_TAG}","kalusahu902") 
                    docker_push("wanderlust-frontend-beta","${params.FRONTEND_DOCKER_TAG}","kalusahu902")
                }
            }
        }
    }
    
    post{
        success{
            archiveArtifacts artifacts: '*.xml', followSymlinks: false
            build job: "Wanderlust-CD", parameters: [
                string(name: 'FRONTEND_DOCKER_TAG', value: "${params.FRONTEND_DOCKER_TAG}"),
                string(name: 'BACKEND_DOCKER_TAG', value: "${params.BACKEND_DOCKER_TAG}")
            ]
        }
    }
}
