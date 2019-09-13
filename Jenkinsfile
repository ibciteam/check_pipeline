pipeline {
  agent {
    label 'ubuntu_docker_label'
  }
  environment {
    GOPATH = "$WORKSPACE"
    DIRECTORY = "src/github.com/Infoblox-CTO/atlas.onprem.config.generator"
    DOCKER_IMAGE = "infobloxcto/atlas.onprem.config.generator"
    CSP_HOST = "www-test.csp.infoblox.com"
  }
  stages {
    stage("Test") {
      steps {
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'ib-aws-creds',
                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
      ],
      usernamePassword(
          credentialsId: 'csp-admin',
          usernameVariable: 'CSP_USER',
          passwordVariable: 'CSP_PASS'),
      ]) {
            sh "cd $DIRECTORY && AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} make test"
    }
      }
    }
    stage("Build") {
      steps {
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'ib-aws-creds',
                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
      ]]) {  
            sh "cd $DIRECTORY && AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} make docker-build"
        }
        withDockerRegistry([credentialsId: "dockerhub-bloxcicd", url: ""]) {
             sh 'cd $DIRECTORY && make docker-publish'
          }
      }
    }
    
    stage("First") {
      steps {
       script{
        def url="$GIT_URL"
        final git_repo = url.substring(url.lastIndexOf('/') + 1, url.length()-4)
        env.GIT_REPO =git_repo
       
        }
       }
      }
  }
    post {
        success {
        script{
      if(env.CHANGE_ID ==null)
        {
          env.CHANGE_ID=""
        }
       
        def email_list = "${ownership.job.secondaryOwnerEmails}".substring(1,"${ownership.job.secondaryOwnerEmails}".size()-1)+", "+"${ownership.job.primaryOwnerEmail}"
        wrap([$class: 'BuildUser']){
          if(env.BUILD_USER_EMAIL!= null)
          {
            email_list+=", "+env.BUILD_USER_EMAIL
          }
        }
        env.EMAIL_LIST=email_list+", ibciteam@infoblox.com"
        echo env.EMAIL_LIST
       
       }
       wrap([$class: 'BuildUser']) {
       build job: 'run_docker_image_cve_scan', parameters: [[$class: 'StringParameterValue', name: 'upstream_git_commit', value:env.GIT_COMMIT], [$class: 'StringParameterValue', name: 'upstream_github_repo', value:env.GIT_REPO],[$class: 'StringParameterValue', name: 'upstream_build_PR', value:env.CHANGE_ID], [$class: 'StringParameterValue', name: 'upstream_build_id', value:env.BUILD_ID], [$class: 'StringParameterValue', name: 'upstream_job_name', value:env.JOB_NAME], [$class: 'StringParameterValue', name: 'email_recipients', value:env.EMAIL_LIST], [$class: 'StringParameterValue', name: 'upstream_execution_url', value:env.BUILD_URL], [$class: 'StringParameterValue', name: 'tag', value:'20190828-45-357a348'], [$class: 'StringParameterValue', name: 'repo', value:'infobloxcto/siemserver']]
       }
      }
   
  } 
}

