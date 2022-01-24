library(sf)
library(raster)
library(dplyr)
library(tmap)  
library(leaflet) 
library(ggplot2)

source('../scripts/helpers.R') # helper script, note that '../' is used to change into the directory above the directory this notebook is in

download_data()

countries <- read_sf("../data/africa/countries.shp")
zambia <- subset(countries, countries$NAME == 'Zambia')
land_cover <- raster('../data/africa/land_cover.tif')

# we can then crop the land_use raster to Zambia's extent as in tutorial 4
land_cover_zambia <- crop(land_cover, zambia)
land_cover_zambia <- mask(land_cover_zambia, zambia)

# determine the CRS 
st_crs(countries)

# define the relevant CRS
crs <- '+proj=utm +zone=35 +south +datum=WGS84 +units=m +no_defs' 

# convert the sf objects 
countries_utm35s <- st_transform(countries, crs=crs)
zambia_utm35s <- st_transform(zambia, crs=crs)

# convert the raster object 
land_cover_zambia_utm35s <- projectRaster(land_cover_zambia, crs=crs)


# continent & country outlines can be represented through ggplot as:
ggplot() +
  geom_sf(data = countries_utm35s, color = 'black', fill = 'antiquewhite') +
  theme_bw()


# equivelant representation through tmaps showing layer development add fill with default colouring
tm_shape(countries_utm35s) +
  tm_fill() 

# add border layer only to the map
tm_shape(countries_utm35s) +
  tm_borders() 

# combine these two for a more complete representation
tm_shape(countries_utm35s) +
  tm_fill() +
  tm_borders() 

# this can also be achieved through tm_polygons()  
tm_shape(countries_utm35s) + 
  tm_polygons()

# you can add detail to each layer  
tm_shape(countries_utm35s) +
  tm_fill(col = 'green') +
  tm_borders(col = 'red')

# selecting a complimentary combination of colours for the map can benefit its readibility significantly i.e., not using vivid greens and reds
tm_shape(countries_utm35s) +
  tm_fill(col = 'antiquewhite') +
  tm_borders(col = 'black')


ggplot() +
  geom_sf(data = countries_utm35s, color = 'black', fill = 'antiquewhite') +
  geom_sf(data = zambia_utm35s, color = 'white', fill = 'orange') +
  theme_bw()



# represented through tmaps
tm_shape(countries_utm35s) +
  tm_fill(col = 'antiquewhite') +
  tm_borders(col = 'black') +
  tm_shape(zambia_utm35s) +
  tm_fill(col = 'orange') +
  tm_borders(col = 'white')

# determining the extent of the zambia file
ext_zamb <- extent(zambia_utm35s)
xmin <- ext_zamb[1] - 100000
xmax <- ext_zamb[2] + 100000
ymin <- ext_zamb[3] - 100000
ymax <- ext_zamb[4] + 100000 # we change the extent to buffer around the country

reduced_countries_utm35s <- st_crop(countries_utm35s, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax)


# represented through ggplot
ggplot() +
  geom_sf(data = reduced_countries_utm35s, color = 'black', fill = 'antiquewhite') +
  geom_sf(data = zambia_utm35s, color = 'white', fill = 'orange') +
  theme_bw()



# represented through tmaps
tm_shape(reduced_countries_utm35s) +
  tm_fill(col = 'antiquewhite') +
  tm_borders(col = 'black') +
  tm_shape(zambia_utm35s) +
  tm_fill(col = 'orange') +
  tm_borders(col = 'white')

map_zambia_one <- tm_shape(reduced_countries_utm35s) +
  tm_fill(col = 'antiquewhite') +
  tm_borders(col = 'black') +
  tm_shape(zambia_utm35s) +
  tm_fill(col = 'orange') +
  tm_borders(col = 'white', lwd = 3)
class(map_zambia_one)
print(map_zambia_one)

map_zambia_two <- map_zambia_one + 
  tm_shape(land_cover_zambia_utm35s) + 
  tm_raster()
class(map_zambia_two)


print(map_zambia_two)

# editting the legend
map_zambia_two <- map_zambia_one + 
  tm_shape(land_cover_zambia_utm35s) + 
  tm_raster() +
  tm_layout(legend.position = c('right', 'bottom'))
print(map_zambia_two)

map_zambia_two <- map_zambia_one + 
  tm_shape(land_cover_zambia_utm35s) + 
  tm_raster() +
  tm_layout(legend.outside = TRUE)
print(map_zambia_two)

# Editing the legend title & changing the colour theme
legend <- paste('Land Cover')
map_zambia_two <- map_zambia_one + 
  tm_shape(land_cover_zambia_utm35s) + 
  tm_raster(title = legend, palette = 'Greens') +
  tm_layout(legend.outside = TRUE)
print(map_zambia_two)

tmap_arrange(map_zambia_one, map_zambia_two)

# compass elements
# position
map_zambia_two + 
  tm_compass(position = c('left', 'top'))
map_zambia_two + 
  tm_compass(position = c('left', 'bottom'))
# compass type
map_zambia_two + 
  tm_compass(type = '4star', position = c('left', 'top'))
map_zambia_two + 
  tm_compass(type = '8star', position = c('left', 'top'))
    
# scale bar size 
map_zambia_two + 
  tm_scale_bar(breaks = c(0, 100, 200))
map_zambia_two + 
  tm_scale_bar(breaks = c(0, 250, 500))

map_zambia_two + 
  tm_compass(type = '8star', position = c('left', 'top'), bg.color = 'red')
map_zambia_two + 
  tm_compass(type = '8star', position = c('left', 'top'), bg.color = 'red', size = 10)
map_zambia_two + 
  tm_compass(type = '8star', position = c('left', 'top'), bg.color = 'red', size = 10, bg.alpha = 0.5)

map_zambia_two + 
  tm_scale_bar(breaks = c(0, 200, 400), bg.color = 'blue', bg.alpha = 0.25)


# types of titles 
map_zambia_two +
  tm_layout(title = 'Legend')
    
map_zambia_two +
  tm_layout(main.title = 'Zambia Test Map')


map_zambia_two +
  tm_layout(main.title = 'Zambia Test Map', 
            title = 'Legend:')
    
# title characteristics 
map_zambia_two +
  tm_layout(main.title = 'Zambia Test Map', main.title.size = 2, main.title.position = c('right', 'top'), 
            main.title.color = 'red', main.title.fontface = 'bold')


map_zambia_two +
  tm_layout(frame = FALSE)

map_zambia_three <- map_zambia_two + 
  tm_compass(type = '8star', position = c('left', 'top'), bg.color = 'black', bg.alpha = 0.5, size = 2) + 
  tm_scale_bar(breaks = c(0, 200, 400), bg.color = 'black', bg.alpha = 0.5) +
  tm_layout(main.title = 'Zambia Test Map', main.title.size = 2, main.title.position = c('left', 'top'), main.title.fontface = 'bold', 
            title = 'Legend:', title.size = 1.5, 
            frame = FALSE)
print(map_zambia_three)

cities <- read_sf("data/africa/cities.shp")
cities_utm35s <- st_transform(cities, crs=crs)
cities_utm35s_intersect <- st_intersects(cities_utm35s, zambia_utm35s, sparse=FALSE)

intersected_cities_idxs <- which(cities_utm35s_intersect)

idx <- intersected_cities_idxs[1]
cities_utm35s[idx, 'COUNTRY']

zambia_cities_utm35s <- cities_utm35s[intersected_cities_idxs, ]

map_zambia_two + 
  tm_shape(zambia_cities_utm35s) +
  tm_symbols(col = 'black', size = 0.5, border.col = 'white', shape = 22)


# subsetting the df to be only the 'big' cities 
# populations of 50,000+ in 1990
zambia_big_cities_utm35s <- subset(zambia_cities_utm35s, zambia_cities_utm35s$ES90POP > 50000)
map_zambia_two + 
  tm_shape(zambia_big_cities_utm35s) +
  tm_symbols(col = 'black', size = 'ES90POP', border.col = 'white', shape = 22, 
             title.size = '1990s Population')
# significant figures are important to keep the map neat

# population as thousands of people
zambia_big_cities_utm35s$ES90POP_neat_thous <- zambia_big_cities_utm35s$ES90POP/1000
map_zambia_two + 
  tm_shape(zambia_big_cities_utm35s) +
  tm_symbols(col = 'black', size = 'ES90POP_neat_thous', border.col = 'white', shape = 22, 
             title.size = '1990s Population (thousand)')

# the above map makes the legen title undreadable 
# '\n' creates a new line
map_zambia_two + 
  tm_shape(zambia_big_cities_utm35s) +
  tm_symbols(col = 'black', size = 'ES90POP_neat_thous', border.col = 'white', shape = 22, 
             title.size = '1990s Population \n(thousands)')

# population as millions of people
zambia_big_cities_utm35s$ES90POP_neat_mil <- zambia_big_cities_utm35s$ES90POP/1000000
map_zambia_two + 
  tm_shape(zambia_big_cities_utm35s) +
  tm_symbols(col = 'black', size = 'ES90POP_neat_mil', border.col = 'white', shape = 22, 
             title.size = '1990s Population \n(million)')


map_zambia_four <- map_zambia_three + 
  tm_shape(zambia_big_cities_utm35s) +
  tm_symbols(col = 'black', size = 'ES90POP_neat_mil', border.col = 'white', shape = 22, 
             title.size = '1990s Population \n(million)')
print(map_zambia_four)

tmap_arrange(map_zambia_one, map_zambia_two, map_zambia_three, map_zambia_four)

tmap_save(map_zambia_four, filename="map_zambia_four_small.pdf", height=4, width=5, units="in", dpi=300)
tmap_save(map_zambia_four, filename="map_zambia_four_big.pdf", height=8.5, width=11, units="in", dpi=300)

