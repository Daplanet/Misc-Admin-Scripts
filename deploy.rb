#!/usr/bin/env ruby -w
# This script deploys select repos so they are available for download
# through dl.rig.gr.

deploylist = {
  "webcel_cluster"     =>      "ssh://git@rig.gr:2020/webcel_cluster_setup_script.git",
  "cluster_monitoring" =>      "ssh://git@rig.gr:2020/cluster_monitoring.git",
  "magento_stack"      =>      "ssh://git@rig.gr:2020/magento_stack.git",
  "misc_scripts"       =>      "ssh://git@rig.gr:2020/misc_sysadmin_scripts.git",
}

deploypath = '/home/ukfast/www'

#################################################################
# Do not edit below this line.
#################################################################

deploylist.each do | name, repo |
  fullpath = "#{deploypath}/#{name}"
  if Dir.exists?(fullpath)
    # Already checked out, do a pull
    `su - deploy -c "cd #{fullpath} && git pull > /dev/null 2>&1"`
    puts "Error updating repository #{name} from #{repo}" unless $? == 0
  else
    # Need to clone for the first time
    `su - deploy -c "git clone #{repo} #{deploypath}/#{name} > /dev/null 2>&1"`
    puts "Error cloning new repository #{name} from #{repo}" unless $? == 0
  end
end
