pipeline {
  agent {
    label 'master'
  }
  
  stages {
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
       wrap([$class: 'BuildUser']) {
       build job: 'run_docker_image_cve_scan', parameters: [[$class: 'StringParameterValue', name: 'upstream_git_commit', value:env.GIT_COMMIT], [$class: 'StringParameterValue', name: 'upstream_github_repo', value:env.GIT_REPO],[$class: 'StringParameterValue', name: 'upstream_build_PR', value:env.CHANGE_ID], [$class: 'StringParameterValue', name: 'upstream_build_id', value:env.BUILD_ID], [$class: 'StringParameterValue', name: 'upstream_job_name', value:env.JOB_NAME], [$class: 'StringParameterValue', name: 'upstream_build_user', value:env.BUILD_USER_EMAIL], [$class: 'StringParameterValue', name: 'upstream_execution_url', value:env.BUILD_URL], [$class: 'StringParameterValue', name: 'tag', value:'20190828-45-357a348'], [$class: 'StringParameterValue', name: 'repo', value:'infobloxcto/siemserver']]
       }
      }
   
  } 
}

