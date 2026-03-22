

tool
extends Object

func load_image(rel_path, source_path, options):
	var flags = options.image_flags if "image_flags" in options else Texture.FLAGS_DEFAULT
	var embed = options.embed_internal_images if "embed_internal_images" in options else false

	var ext = rel_path.get_extension().to_lower()
	if not ext in ["png", "jpg", "webp", "pvr", "tga"]:
		printerr("Unsupported image format: %s. Use PNG, JPG, WEBP, PVR or TGA instead." % [ext])
		return ERR_FILE_UNRECOGNIZED

	var total_path = rel_path
	if rel_path.is_rel_path():
		total_path = ProjectSettings.globalize_path(source_path.get_base_dir()).plus_file(rel_path)
	total_path = ProjectSettings.localize_path(total_path)

	var dir = Directory.new()
	if not dir.file_exists(total_path):
		printerr("Image not found: %s" % [total_path])
		return ERR_FILE_NOT_FOUND

	if not total_path.begins_with("res://"):

		embed = true

	var image = null
	if embed:
		image = ImageTexture.new()
		image.load(total_path)
	else:
		image = ResourceLoader.load(total_path, "ImageTexture")

	if image != null:
		image.set_flags(flags)

	return image
