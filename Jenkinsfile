pipeline {
  agent {
    label 'master'
  }
  
  environment {
    GOPATH = "$WORKSPACE"
    GITHUB_COMMIT="$GIT_COMMIT"
    GITHUB_PR="$CHANGE_ID"
  }
  

  stages {
    stage("First") {
      steps {
       script{
        def url="$GIT_URL"
        final git_repo = url.substring(url.lastIndexOf('/') + 1, url.length())
        env.GIT_REPO =git_repo
       
        }
        
      }
       
    }
    stage("printing other variables"){
    steps{
       env.BUILD_ID ="$BUILD_ID"
       env.BUILD_URL ="$BUILD_URL"
       wrap([$class: 'BuildUser']) {
       env.BUILD_USER_EMAIL ="${BUILD_USER_EMAIL}"
       echo env.BUILD_ID
       echo env.BUILD_URL
       
       env.JOB_NAME="$JOB_NAME"
       env.PRIMARY_JOB_OWNER_ID="${ownership.job.primaryOwnerId}"
       env.PRIMARY_JOB_OWNER_EMAIL="${ownership.job.primaryOwnerEmail}" 
       env.SECONDARY_JOB_OWNER_EMAIL="${ownership.job.secondaryOwnerIds}"
       env.SECONDARY_JOB_OWNER_ID="${ownership.job.secondaryOwnerEmails}"
      //echo env.GIT_REPO
      //println "Primary owner ID: ${ownership.job.primaryOwnerId}"
      //println "Primary owner e-mail: ${ownership.job.primaryOwnerEmail}"
      //println "Secondary owner IDs: ${ownership.job.secondaryOwnerIds}"
      //println "Secondary owner e-mails: ${ownership.job.secondaryOwnerEmails}"
      }  
    }
  }
    
    stage("Build CVE job"){
      steps{
    
      build job: 'run_docker_image_cve_scan', parameters: [[$class: 'StringParameterValue', name: 'upstream_git_commit', value:env.GITHUB_COMMIT], [$class: 'StringParameterValue', name: 'upstream_github_repo', value:env.GIT_REPO],[$class: 'StringParameterValue', name: 'upstream_build_PR', value:env.GITHUB_PR], [$class: 'StringParameterValue', name: 'upstream_build_id', value:env.BUILD_ID], [$class: 'StringParameterValue', name: 'upstream_job_name', value:env.JOB_NAME], [$class: 'StringParameterValue', name: 'upstream_job_owners', value:env.SECONDARY_JOB_OWNER_EMAIL], [$class: 'StringParameterValue', name: 'upstream_build_user', value:env.BUILD_USER_EMAIL], [$class: 'StringParameterValue', name: 'upstream_execution_url', value:env.BUILD_URL], [$class: 'StringParameterValue', name: 'tag', value:'20190828-45-357a348'], [$class: 'StringParameterValue', name: 'repo', value:'infobloxcto/siemserver']]
      }
  } 
   
} 
}
