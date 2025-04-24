setwd("~/Desktop/Code/R studio")

# Load required libraries
library(sf)
library(spatstat)
library(tmap)
library(dplyr)
library(spgwr)
library(spdep)
library(grid)
library(gridExtra)

# Read input data
census_data <- read.csv("~/Downloads/Worksheet_Data/eng_wales_practical_data.csv")
lsoa_shapefile <- st_read(dsn = "~/Downloads/worksheet_data/Census_OA_Shapefile.geojson")
oa_shapefile <- st_read("~/Downloads/Worksheet_Data/OA_2021_EW_BGC_V2.shp")

# Process centroids for LSOA
lsoa_centroids <- st_centroid(lsoa_shapefile)
lsoa_lambeth <- oa_shapefile[grepl('Lambeth', oa_shapefile$LSOA21NM),]

# Merge census data with the LSOA shapefile based on OA code
lambeth_census <- merge(lsoa_lambeth, census_data, by.x = "OA21CD", by.y = "OA")
lambeth_census_lsoa <- lambeth_census[, -1] # Remove redundant column
st_write(lambeth_census, dsn = "~/Downloads/Worksheet_Data/Lambeth_Census_Shapefile.geojson", driver="GeoJSON")

# Create OA to LSOA mapping
oa_to_lsoa <- lsoa_lambeth[, c("OA21CD", "LSOA21CD")]

# Merge census data with LSOA mapping based on OA code
merged_data <- merge(census_data, oa_to_lsoa, by.x = "OA", by.y = "OA21CD")

# Aggregate data by LSOA (e.g., calculate average unemployment rate)
aggregated_data <- merged_data %>%
  group_by(LSOA21CD) %>%
  summarise(Unemployment_Rate = mean(Unemployed, na.rm = TRUE))

# Merge aggregated data with LSOA shapefile
lsoa_areas <- st_read("~/Downloads/Worksheet_Data/Lower_layer_Super_Output_Areas_2021_EW_BGC_V3.geojson")
lsoa_merged <- merge(lsoa_areas, aggregated_data, by.x = "LSOA21CD", by.y = "LSOA21CD")



tm_shape(lsoa_merged) + 
  tm_fill("Unemployment_Rate", legend.hist = TRUE, palette = "-RdYlGn" , style = "jenks", n = 5, title = "Unemployment Rate") +
  tm_borders(alpha = .6) +
  tm_compass(size = 2, fontsize = 0.5,position = c("center","bottom"))+
  tm_layout(title = "Unemployment Distribution by LSOA",legend.text.size = 0.9,frame = FALSE,asp = 0,legend.position = c("left","bottom"),legend.hist.width = 0.3,title.size = 1.1)

# Spatial neighbors for poly2nb and different types of adjacency
neighbours <- poly2nb(lsoa_merged)
neighbours_rook <- poly2nb(lsoa_merged, queen = FALSE)

# Plot both types of neighbor relationships
par(mfrow = c(1, 2))
plot(neighbours, st_geometry(lsoa_merged), col = 'red')
plot(neighbours_rook, st_geometry(lsoa_merged), col = 'blue')

# Create spatial weight list for Moran's test
listw <- nb2listw(neighbours_rook, style = "W")

# Run Moran's I test for spatial autocorrelation
moran.test(lsoa_merged$Unemployment_Rate, listw)

# Calculate lagged unemployment rate and plot
lagged_rate <- lag.listw(listw, lsoa_merged$Unemployment_Rate)
unemployment_rate <- lsoa_merged$Unemployment_Rate
plot(unemployment_rate, lagged_rate)
abline(h = mean(unemployment_rate), lty = 2)
abline(v = mean(lagged_rate), lty = 2)

# Recenter the data
recentered_uep <- unemployment_rate - mean(unemployment_rate)
recentered_lag <- lagged_rate - mean(lagged_rate)
plot(recentered_uep, recentered_lag)
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)

# Linear model for spatial lag
lm_model <- lm(recentered_lag ~ recentered_uep)
abline(lm_model, lty = 3)

# Local Moran's I
local_moran <- localmoran(x = lsoa_merged$Unemployment_Rate, listw = nb2listw(neighbours_rook, style = "W"))
moran_map <- cbind(lsoa_merged, local_moran)

# Plot Local Moran's I map
tm_shape(moran_map) +
  tm_fill(col = "Ii", style = "jenks", title = "Local Moran's I statistics")

# Nearest neighbors based on distance (2 km)
distance_neighbours <- dnearneigh(st_centroid(lsoa_merged), 0, 2000)
moran.test(lsoa_merged$Unemployment_Rate, listw = nb2listw(distance_neighbours, style = "W"))

# Local Moran's I with distance-based neighbors
local_moran_distance <- localmoran(x = lsoa_merged$Unemployment_Rate, listw = nb2listw(distance_neighbours, style = "W"))
moran_map_distance <- cbind(lsoa_merged, local_moran_distance)

# Plot Local Moran's I with distance-based neighbors
tm_shape(moran_map_distance) +
  tm_fill(col = "Ii", style = "jenks", title = "Local Moran's I statistic (Distance-Based)")

# Define quadrants based on recentered data
quadrant <- numeric(length = nrow(local_moran_distance))
significance_threshold <- 0.05
quadrant[recentered_uep < 0 & recentered_lag < 0] <- 1
quadrant[recentered_uep < 0 & recentered_lag > 0] <- 2
quadrant[recentered_uep > 0 & recentered_lag < 0] <- 3
quadrant[recentered_uep > 0 & recentered_lag > 0] <- 4
quadrant[local_moran_distance[, 5] > significance_threshold] <- 0

# Define color scheme for quadrant visualization
color_breaks <- c(0, 1, 2, 3, 4)
colors <- c("white", "blue", rgb(0, 0, 1, alpha = 0.4), rgb(1, 0, 0, alpha = 0.4), "red")

# Plot the spatial clustering map
plot(lsoa_merged[1], border = "lightgrey", 
     col = colors[findInterval(quadrant, color_breaks, all.inside = FALSE)],
     main = "Lambeth Spatial Clustering: Unemployment")
legend("bottomleft", legend = c("insignificant", "low-low", "low-high", "high-low", "high-high"), fill = colors, bty = "n")

# Read IMD data and merge with census data
imd_data <- st_read(dsn = "~/Downloads/English IMD 2019/IMD_2019.dbf")
imd_lambeth <- imd_data[grepl('Lambeth', imd_data$lsoa11nm),]
merged_imd_census <- merge(imd_lambeth, aggregated_data, by.x = "lsoa11cd", by.y = "LSOA21CD")

# Fit linear model for unemployment rate and education rank
lm_model_imd <- lm(merged_imd_census$Unemployment_Rate ~ merged_imd_census$EduRank)
summary(lm_model_imd)

# Plot model diagnostics
plot(lm_model_imd, which = 3)

# Residuals and mapping
residuals_data <- residuals(lm_model_imd)
map_residuals <- cbind(merged_imd_census, residuals_data)
qtm(map_residuals, fill = "residuals_data")

# GWR model
imd_census_spatial <- as(merged_imd_census, "Spatial")
gwr_bandwidth <- gwr.sel(imd_census_spatial$Unemployment_Rate ~ imd_census_spatial$EduRank, data = imd_census_spatial, adapt = TRUE)
gwr_model <- gwr(imd_census_spatial$Unemployment_Rate ~ imd_census_spatial$EduRank, data = imd_census_spatial, adapt = gwr_bandwidth, hatmatrix = TRUE, se.fit = TRUE)

# GWR results
gwr_results <- as.data.frame(gwr_model$SDF)
gwr_map <- cbind(imd_census_spatial, as.matrix(gwr_results))

# Plot GWR Local R2 distribution map
tm_shape(gwr_map) + 
  tm_fill("localR2", style = "jenks", legend.hist = TRUE, n = 5, title = "Local R2") +
  tm_borders(alpha = 0.6) +
  tm_compass(size = 2, fontsize = 0.5,position = c("center","bottom"))+
  tm_layout(title = "Local R2 Distribution by LSOA", legend.text.size = 0.9,frame = FALSE,asp = 0,legend.position = c("left","bottom"),legend.hist.width = 0.3,title.size = 1.1)

# Plot education rank and coefficient maps
map1 <- tm_shape(gwr_map) + 
  tm_fill("EduRank", n = 5, style = "quantile", title = "Education Rank", palette = "-RdYlBu", legend.hist = TRUE) +
  tm_borders(alpha = 0.6) +
  tm_compass(size = 2, fontsize = 0.5,position = c("center","bottom"))+
  tm_layout(legend.text.size = 0.9,frame = FALSE,asp = 0,legend.position = c("left","bottom"),legend.hist.width = 0.3,title.size = 1.1)

map2 <- tm_shape(gwr_map) +
  tm_fill("imd_census_spatial.EduRank", n = 3, style = "jenks", title = "Education Coefficient", legend.hist = TRUE) +
  tm_layout(legend.text.size = 0.9,frame = FALSE,asp = 0,legend.position = c("left","bottom"),legend.hist.width = 0.3,title.size = 1.1) +
  tm_compass(size = 2, fontsize = 0.5,position = c("center","bottom"))+
  tm_borders(alpha = 0.6)

# Display both maps
print(map1)
print(map2)

# Correlation and scatter plot for GWR results
round(cor(gwr_results[, c(3, 5, 7, 8)], use = "complete.obs"), 2)
pairs(gwr_results[, c(3, 5, 7, 8)], pch = ".")

library(psych)
describe(lsoa_merged$Unemployment_Rate)
describe(merged_imd_census$EduRank)
