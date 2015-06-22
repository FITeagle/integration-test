#!/usr/bin/env python2.7
 
__author__    = 'Bjoern Riemer <bjoern.riemer@tu-berlin.de>'
__copyright__ = "Bjoern Riemer. TUB"
__licence__   = "GPL"
__version__   = 0.1

from travispy import TravisPy
import yaml
import os.path,sys

def read_config(filename):
	with open(filename, 'r') as ymlfile:
		config = yaml.load(ymlfile)
		return config

def old_logic(gh_token):
	t = TravisPy.github_auth(gh_token)
	user = t.user()
	repos = t.repos(member=user.login)
	print "found", len(repos), "repositories:"
	for r in repos:
		print r.slug
	repo = t.repo('FITeagle/integration-test')

	branch_bin = t.branch(repo_id_or_slug=repo.slug,name='binary-only')
	branch_master = t.branch(repo_id_or_slug=repo.slug,name='master')

	print "bin:", branch_bin.repository_id, branch_bin.number
	print "master:", branch_master.repository_id, branch_master.number

	builds_master = t.builds(repository_id=branch_master.repository_id,number=branch_master.number)
	builds_bin = t.builds(repository_id=branch_bin.repository_id,number=branch_bin.number)

	print "Branch >>binary-only<< has", len(builds_bin), "Builds"
	print "Branch >>master<< has", len(builds_master), "Builds"
	build_master=builds_master[0]
	build_bin=builds_bin[0]

	print "restarting >>binary-only<< build...", build_bin.restart()
	print "restarting >>master<< build...", build_master.restart()

def cfgExample():
	cfgdata = {
		'github_token':"1234567890123456789012345678901234567890",
		'triggers':[{
			"trigger_file":"/tmp/trigger.txt",
			"delete_after":True,
			"repositories":[{
				"slug":"FITeagle/integration-test",
				"branches":["master","binary-only"]
				},
				{
				"slug":"FITeagle/core",
				"branches":["master"]
				}
				]
			},
			{
			"trigger_file":"/tmp/trigger_two.txt",
			"delete_after":False,
			"repositories":[{
				"slug":"FITeagle/two",
				"branches":["master"]
				}]
			}]
		}
	print yaml.dump(cfgdata)

try:
	config = read_config(os.path.dirname(sys.argv[0])+"/trigger_travis.yaml")
except Exception, e:
	print "can't open config file!\nCreate a file named >>trigger_travis.yaml<< with the following contens:"
	cfgExample()
	exit(1)

t=False

if len(config['triggers']):
	for trigger in  config['triggers']:
		fname=trigger['trigger_file']
		#print "file:",fname,"delete:",trigger['delete_after']
		if os.path.isfile(fname):
			if not t:
				t = TravisPy.github_auth(config['github_token'])
			for r in trigger['repositories']:
				repo = t.repo(r['slug'])
				for bname in r['branches']:
					branch = t.branch(repo_id_or_slug=repo.slug,name=bname)
					build = t.builds(repository_id=branch.repository_id,number=branch.number)[0]
					print "Restarting",repo.slug, "branch", bname, "Build..."
					if build.restart():
						print "OK"
						try:
							if trigger['delete_after']:
								os.remove(fname)
						except Exception, e:
							print e
					else:
						print "Failed!"
			
		else:
			#print "nothing to do for",fname
			pass


#latest_build = t.build(repo.last_build_id)
#latest_build.restart()
