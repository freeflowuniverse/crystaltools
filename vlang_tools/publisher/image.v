module publisher

import os

pub fn (image Image) path_get(site &Site) string {
	return os.join_path(site.path, image.path)
}

// need to create smaller sizes if needed and change the name
pub fn (mut image Image) process(site &Site) {
}
