module builder

interface Executor {
	exec(cmd string) ?string
	file_write(path string, text string) ?
	file_read(path string) ?string
	file_exists(path string) bool
	remove(path string) ?
	download(source string, dest string) ?string
	upload(source string, dest string) ?string
	environ_get() ?map[string]string
	info() map[string]string
}
