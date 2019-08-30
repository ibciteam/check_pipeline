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
      
      echo "$BUILD_ID"
      echo "$BUILD_URL"
      echo "$JOB_NAME"
      echo env.GIT_REPO
      echo env.GITHUB_PR
      echo env.GITHUB_COMMIT
      wrap([$class: 'BuildUser']) {
        echo "${BUILD_USER_EMAIL}"
    }
          
    }
  }
    
    stage("Build CVE job"){
      steps{
    
      build job: 'run_docker_image_cve_scan', parameters: [[$class: 'StringParameterValue', name: 'upstream_git_commit', value:env.GITHUB_COMMIT], [$class: 'StringParameterValue', name: 'upstream_github_repo', value:env.GIT_REPO],[$class: 'StringParameterValue', name: 'upstream_build_PR', value:env.GITHUB_PR], [$class: 'StringParameterValue', name: 'upstream_build_id', value:$BUILD_ID], [$class: 'StringParameterValue', name: 'upstream_job_name', value:$JOB_NAME], [$class: 'StringParameterValue', name: 'upstream_job_owners', value:'ssarojini@infoblox.com'], [$class: 'StringParameterValue', name: 'upstream_build_user', value:$BUILD_USER_EMAIL], [$class: 'StringParameterValue', name: 'upstream_execution_url', value:$BUILD_URL], [$class: 'StringParameterValue', name: 'tag', value:'20190828-45-357a348'], [$class: 'StringParameterValue', name: 'repo', value:'infobloxcto/siemserver']]
      }
  }
} 
} 
