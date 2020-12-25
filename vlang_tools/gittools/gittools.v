module gittools
import os

pub fn ssh_agent_loaded() bool{
	res := os.exec("ssh-add -l") or {
				os.Result{exit_code:1,output:""}
			}
	if res.exit_code==0{
		return true
	}else{
		return false
	}
}