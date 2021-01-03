module publisher

struct Publisher {
mut:
	gitlevel     int
pub mut:
	domain       string
	sites        []Site
}
