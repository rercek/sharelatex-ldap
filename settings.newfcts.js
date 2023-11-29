// Functions used to create a list of images for compiles using sibling containers (settings.default.js)
// imageRoot and  allowedImageNames from env "ALL_TEX_LIVE_DOCKER_IMAGES" string (str)
// Author : rudy.ercek@ulb.be

// Split path from the filename and return path and filename as a an array
const splitPath = function (str) {
     var index = str.lastIndexOf('/')
     if (index == -1) return undefined
     return [str.substring(0,index), str.substring(index+1, str.length)]
}

// Obtain the root directory (registry path) for an image
const getImageRoot = function (str) {
     if (str == undefined) return undefined
     var imgs =  str.split(',')
     var splitpath  = splitPath(imgs[0])
     if (splitpath == undefined) return undefined
     return splitpath[0]
}

// Obtain a list of images (with description and name) from a comma separated images with the same root directory !
const getImages = function (str) {
     var ImageRoot = getImageRoot(str)
     if (ImageRoot == undefined) return []
     var imgs =  str.split(',')
     var imgslist = []
     for (var i = 0; i < imgs.length; i++) {
	var splitpath = splitPath(imgs[i])
        //if the root is different from the global image root --> return an empty image list
        if (splitpath[0] !== ImageRoot) return []
        const match = splitpath[1].match(/:([0-9]+)\.[0-9]+/)
        //By default the image description is the year!
        if (match) imgDesc = match[1]
        else imgDesc = splitpath[1]
	imgslist.push( { imageName: splitpath[1], imageDesc: imgDesc } )
     }
     return imgslist
}

// Finish function for images list

// Start of the original file below 
