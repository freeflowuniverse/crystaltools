module publishingtools
import os

struct ImageActor {
	site &Site
	publtools &PublTools		
	image &Image
}

pub fn (mut imageactor ImageActor) path_get() string{
	return os.join_path(imageactor.site.path,imageactor.image.path)
}

pub fn (mut imageactor ImageActor) process(){

}