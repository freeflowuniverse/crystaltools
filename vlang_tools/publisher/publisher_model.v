module publisher

struct Publisher {
mut:
	gitlevel     int
pub mut:
	domain       string
	sites        []Site
	lazy_loading bool = false // leave on false for now
}
