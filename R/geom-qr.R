
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Key Lime
#'
#' @param data,params,size key stuff
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
draw_key_qr <- function(data, params, size) {

  # print("Key")
  # print(data)
  # print(params)

  gp = gpar(col = 'black', fill = data$colour)

  grid::grobTree(
    grid::rectGrob(gp = gpar(fill = data$fill)),
    grid::rectGrob(x = 0.25, y = 0.25, width = 0.5, height = 0.5, gp = gp),
    grid::rectGrob(x = 0.75, y = 0.75, width = 0.5, height = 0.5, gp = gp)
  )
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Draw QR Codes
#'
#'
#' @section Aesthetics:
#'
#' \code{geom_qr()} understands the following aesthetics:
#' \itemize{
#' \item{x}
#' \item{y}
#' \item{label}
#' \item{colour}
#' \item{fill}
#' \item{size (in inches)}
#' }
#'
#'
#' @param mapping,data,stat,position,...,na.rm,show.legend,inherit.aes see
#'        documentation for \code{ggplot2::geom_point()}
#'
#' @import ggplot2
#' @import qrencoder
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
geom_qr <- function(mapping     = NULL,
                    data        = NULL,
                    stat        = "identity",
                    position    = "identity",
                    ...,
                    na.rm       = FALSE,
                    show.legend = NA,
                    inherit.aes = TRUE) {
  layer(
    data        = data,
    mapping     = mapping,
    stat        = stat,
    geom        = GeomQR,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      na.rm    = na.rm,
      ...
    )
  )
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Render text as a QR code raster object
#'
#' @param label text to encode into QR Code
#' @param fill,col fill(bg) and colour(fg). Will override \code{gp} values
#'        if set
#' @param size used for width and height of QR code. To ensure that the QR code
#'        is actually square, \code{size} is usually best to
#'        be in absolute units like 'pt', 'mm', etc.
#' @param x,y,just,hjust,vjust,interpolate,default.units,name,gp,vp
#'        See \code{grid::rasterGrob()} documentation
#'
#' @import grid
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
qrGrob <- function(
  label,
  x             = unit(0.5, "npc"),
  y             = unit(0.5, "npc"),
  size          = unit(72, 'pt'),
  just          = "centre",
  hjust         = NULL,
  vjust         = NULL,
  interpolate   = FALSE,
  default.units = "npc",
  name          = NULL,
  gp            = gpar(),
  vp            = NULL,
  fill          = NULL,
  col           = NULL
) {

  qr    <- qrencoder::qrencode_raster(label)
  image <- raster::as.raster(1 - raster::as.matrix(qr))

  image[image == '#000000'] <- col  %||% gp$col  %||% '#000000'
  image[image == '#FFFFFF'] <- fill %||% gp$fill %||% '#FFFFFF'

  grid::rasterGrob(
    image         = image,
    x             = x,
    y             = y,
    width         = size,
    height        = size,
    just          = just,
    hjust         = hjust,
    vjust         = vjust,
    interpolate   = interpolate,
    default.units = default.units,
    name          = name,
    gp            = gp,
    vp            = vp
  )
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' GeomQR
#'
#' @format NULL
#' @usage NULL
#'
#' @import raster
#' @import ggplot2
#' @import grid
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GeomQR <- ggplot2::ggproto(
  "GeomQR", ggplot2::Geom,
  required_aes = c("x", "y", "label"),
  non_missing_aes = c("size", "label"),
  default_aes = ggplot2::aes(
    shape  = 19,
    colour = "black",
    size   = 1,
    fill   = 'white',
    alpha  = NA,
    stroke = 0.5,
    hjust  = 0.5,
    vjust  = 0.5
  ),

  draw_panel = function(data, panel_params, coord, na.rm = FALSE) {

    coords <- coord$transform(data, panel_params)

    qr    <- qrencoder::qrencode_raster("Hello")
    image <- raster::as.raster(1 - raster::as.matrix(qr))

    # print(coords)

    grobs <- lapply(
      seq(nrow(coords)),
      function(idx) {
        row <- coords[idx, , drop=FALSE]
        # print(row)
        size <- ggplot2::unit(row$size * 72, 'pt')
        qrGrob(
          label = row$label,
          x     = row$x,
          y     = row$y,
          col   = ggplot2::alpha(row$colour, row$alpha),
          fill  = ggplot2::alpha(row$fill  , row$alpha),
          hjust = row$hjust,
          vjust = row$vjust,
          size  = size
        )
      }
    )

    do.call(grid::grobTree, grobs)
  },

  draw_key = draw_key_qr
)


