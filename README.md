| from source | [![Build Status](https://api.travis-ci.org/FITeagle/integration-test.svg?branch=master)](https://travis-ci.org/FITeagle/integration-test/branches) |
|:--- |:---|
| **binary deployment** | [![Build Status](https://api.travis-ci.org/FITeagle/integration-test.svg?branch=binary-only)](https://travis-ci.org/FITeagle/integration-test/branches) |

# FITeagle
## Integration Test

Testing the final builds all together.
Please have a look at [http://fiteagle.org](http://fiteagle.org) for details.

## Continous integration cycle
 1. git commit into component
 2. components ci-test successful
 3. upload of build artefacts to snapshot repository
 4. trigger rebuild of integration-test
 5. integration test (binary-only) from snapshot repository successful
 6. trigger rebuild of demo.fiteagle.org instance
 7. once every hour the docker container hosting demo.fiteagle.org is rebuild
