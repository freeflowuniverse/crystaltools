module main

struct Volume {
	size u64
	vtype string [json: "type"]
}

struct VolumeResult {
	volume_id string
}

struct ZDB {
	size u64
	mode string
	password string
	disk_type string
	public bool
	// plainpassword
}

struct ZDBResult {
	namespace string
	ips []string
	port u32
}

struct PublicIP {
	ip string
}

struct Member {
	network_id string
	ips []string
	public_ip6 string
	yggdrasil_ip string
}

struct Mount {
	volume_id string
	mountpoint string
}

struct Logs {
	logs_type string [json: "type"]
	data LogsData
}

struct LogsData {
	stdout string
	stderr string
	secret_stdout string
	secret_stderr string
}

struct Stats {
	stats_type string [json: "type"]
	endpoint string
}

struct ContainerCapacity {
	cpu u32
	memory u64
	disk_type string
	disk_size u64
}

struct Container {
	flist string
	hub_url string
	env string // fixme
	secretenv string // fixme
	entrypoing string
	interactive bool
	mounts []Mount
	network Member
	capacity ContainerCapacity
	logs []Logs
	stats []Stats
}

struct ContainerResult {
	id string
	ipv6 string
	ipv4 string
	ipygg string
}

struct PublicIPResult {
	ip string
}

struct Kubernetes {
	size u16
	networkid string
	ip string
	clustersecret string
	masterips []string
	sshkeys string
	publicip string

	// plainclustersecret
}

struct KubernetesResult {
	id string
	ip string
}

struct Result {
	id string
	created int
	state int
	error string
	data string
	signature string
}

struct Workload {
	version int
	id string
	user string
	workload_type string [json: "type"]
	data string
	created int
	to_delete bool
	metadata string
	description string
	signature string
	result Result
}
