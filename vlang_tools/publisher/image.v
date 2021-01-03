module publisher

import os

pub fn (image Image) path_get(mut publisher &Publisher) string {
	site_path := publisher.sites[image.site_id].path
	return os.join_path(site_path, image.path)
}

// need to create smaller sizes if needed and change the name
pub fn (mut image Image) process(mut publisher &Publisher) {
}
