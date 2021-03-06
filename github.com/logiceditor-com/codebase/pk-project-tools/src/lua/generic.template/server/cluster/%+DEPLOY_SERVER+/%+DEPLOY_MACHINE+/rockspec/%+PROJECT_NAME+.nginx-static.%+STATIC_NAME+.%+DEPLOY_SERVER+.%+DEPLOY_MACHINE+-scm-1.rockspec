package = "#{PROJECT_NAME}.nginx-static.#{STATIC_NAME}.#{DEPLOY_SERVER}.#{DEPLOY_MACHINE}"
version = "scm-1"
source = {
   url = "" -- Installable with `luarocks make` only
}
description = {
   summary = "#{PROJECT_NAME} #{STATIC_NAME} static nginx Configuration for #{DEPLOY_SERVER}.#{DEPLOY_MACHINE}",
   homepage = "http://#{PROJECT_DOMAIN}",
   license = "#{LICENSE}",
   maintainer = "#{MAINTAINER}"
}
supported_platforms = {
   "unix"
}
dependencies = {
}
build = {
   type = "none",
   copy_directories = {
      "cluster/#{DEPLOY_SERVER}/#{DEPLOY_MACHINE}/nginx/#{STATIC_NAME}-static";
   }
}
