## 
## -------------------------------------------------------------
##    Copyright 2004-2009 Synopsys, Inc.
##    All Rights Reserved Worldwide
## 
##    Licensed under the Apache License, Version 2.0 (the
##    "License"); you may not use this file except in
##    compliance with the License.  You may obtain a copy of
##    the License at
## 
##        http://www.apache.org/licenses/LICENSE-2.0
## 
##    Unless required by applicable law or agreed to in
##    writing, software distributed under the License is
##    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.  See
##    the License for the specific language governing
##    permissions and limitations under the License.
## -------------------------------------------------------------
##

#!/bin/csh -f

simv +vmm_opts+FOO_INT=99@d2:b1+FOO_INT=1050@d2:c2:b1+FOO_BIT@d2:b1+FOO_BIT@d2:c2:b1+FOO_STR=NEW_VAL1@d2:b1+FOO_STR=NEW_VAL2@d2:c2:b1 -l run.log
