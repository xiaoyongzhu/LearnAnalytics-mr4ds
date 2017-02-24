dir.create("Student-Resources/data/")
system("wget https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2015-10.csv -d /Student-Resources/data/")

devtools::install_github("dgrtwo/gganimate")
install.packages("cowplot")

devtools::install_github("ropensci/magick")

library(readr)
library(dplyr)
library(purrr)
library(lubridate)
library(ggplot2)
library(RColorBrewer)
library(magick)

library(gganimate)

library(ggmap)

yellow_data <- read_csv("yellow_tripdata_2015-10.csv")

yellow_counts <- yellow_data %>% group_by(pickup_longitude, pickup_latitude) %>% 
  summarise(num_pickups = n(), 
            total_earnings = sum(total_amount))

min_lat <- 40.5774
max_lat <- 40.9176
min_long <- -74.15
max_long <- -73.7004


theme_map_dark <- function(palate_color = "Greys") {
  
  palate <- brewer.pal(palate_color, n=9)
  color.background = "black"
  color.grid.minor = "black"
  color.grid.major = "black"
  color.axis.text = palate[1]
  color.axis.title = palate[1]
  color.title = palate[1]
  
  font.title <- "Source Sans Pro"
  font.axis <- "Open Sans Condensed Bold"
  
  theme_bw(base_size=5) +
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    theme(panel.grid.major=element_blank()) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    theme(legend.background = element_rect(fill=color.background)) +
    theme(legend.text = element_text(size=3,colour=color.axis.title,family=font.axis)) +
    theme(legend.title = element_blank(), legend.position="top", legend.direction="horizontal") +
    theme(legend.key.width=unit(1, "cm"), legend.key.height=unit(0.25, "cm"), legend.margin=unit(-0.5,"cm")) +
    theme(plot.title=element_text(colour=color.title,family=font.title, size=14)) +
    theme(plot.subtitle = element_text(colour=color.title,family=font.title, size=12)) +
    theme(axis.text.x=element_blank()) +
    theme(axis.text.y=element_blank()) +
    theme(axis.title.y=element_blank()) +
    theme(axis.title.x=element_blank()) +
    # theme(plot.margin = unit(c(0.0, -0.5, -1, -0.75), "cm")) +
    theme(strip.background = element_rect(fill=color.background, 
                                          color=color.background),
          strip.text=element_text(size=7,colour=color.axis.title,family=font.title))
  
}

# plot <- ggplot(yellow_counts, 
#                aes(x=pickup_longitude, y=pickup_latitude)) +
#   geom_point(size=0.06) + 
#   scale_x_continuous(limits=c(min_long, max_long)) +
#   scale_y_continuous(limits=c(min_lat, max_lat))
# 
# 
# 
# plot <- ggplot(filter(yellow_counts, num_pickups > 1), 
#                aes(x=pickup_longitude, y=pickup_latitude)) +
#   geom_point(color="white", size=0.06) +
#   scale_x_continuous(limits=c(min_long, max_long)) +
#   scale_y_continuous(limits=c(min_lat, max_lat)) +
#   theme_map_dark()

yellow_data <- yellow_data %>% 
  mutate(date = ymd_hms(tpep_pickup_datetime),
         month= factor(month(date), levels = 1:12))

xforms <- function(data) { # transformation function for extracting some date and time features
  # require(lubridate)
  weekday_labels <- c('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')
  cut_levels <- c(1, 5, 9, 12, 16, 18, 22)
  hour_labels <- c('1AM-5AM', '5AM-9AM', '9AM-12PM', '12PM-4PM', '4PM-6PM', '6PM-10PM', '10PM-1AM')
  
  pickup_datetime <- lubridate::ymd_hms(data$tpep_pickup_datetime, tz = "UTC")
  pickup_hour <- addNA(cut(hour(pickup_datetime), cut_levels))
  pickup_dow <- factor(wday(pickup_datetime), levels = 1:7, labels = weekday_labels)
  levels(pickup_hour) <- hour_labels
  # 
  dropoff_datetime <- lubridate::ymd_hms(data$tpep_dropoff_datetime, tz = "UTC")
  dropoff_hour <- addNA(cut(hour(dropoff_datetime), cut_levels))
  dropoff_dow <- factor(wday(dropoff_datetime), levels = 1:7, labels = weekday_labels)
  levels(dropoff_hour) <- hour_labels
  # 
  
  trip_duration <- as.integer(lubridate::interval(pickup_datetime, dropoff_datetime))
  
  return(data.frame(pickup_hour, pickup_dow, trip_duration))
}

yellow_df <- yellow_data %>% bind_cols(xforms(yellow_data))


yellow_counts <- yellow_df %>% 
  filter(pickup_longitude > min_long,
         pickup_latitude < max_lat,
         dropoff_longitude > min_long,
         dropoff_latitude < max_lat) %>% 
  group_by(pickup_hour, 
           pickup_longitude, 
           pickup_latitude) %>% 
  summarise(num_pickups = n(), 
            total_earnings = sum(total_amount))

# plots <- ggplot(filter(ungroup(yellow_counts), num_pickups > 1), 
#                 aes(x=pickup_longitude, y=pickup_latitude, frame=pickup_hour)) +
#   geom_point(color="white", size=0.06) +
#   scale_x_continuous(limits=c(min_long, max_long)) +
#   scale_y_continuous(limits=c(min_lat, max_lat)) +
#   theme_map_dark()


map_nyc <- function(df, pickup_hr) {
  
  gplot <- ggplot(df, 
                  aes(x=pickup_longitude, 
                      y=pickup_latitude)) +
    geom_point(color="white", size=0.06) +
    scale_x_continuous(limits=c(min_long, max_long)) +
    scale_y_continuous(limits=c(min_lat, max_lat)) +
    theme_map_dark() + 
    labs(title = "Map of NYC Taxi Pickups",
         subtitle = paste0("Pickups between ", pickup_hr))
  
  ggsave(paste("./img/map_pickup_", pickup_hr, ".png", sep =""))
  
  return(gplot)
  
}

make_map <- . %>% map_nyc

hour_plots <- ungroup(yellow_counts) %>% 
  filter(num_pickups > 1) %>% 
  split(.$pickup_hour) %>% 
  map(~ map_nyc(.x, pickup_hr = .x$pickup_hour[1]))

imgs <- list.files("img/", full.names = TRUE)
image_magicks <- imgs %>% map(~ image_read(.x))

## Can't seem to unlist

img1 <- image_read(imgs[3])
img2 <- image_read(imgs[5])
img3 <- image_read(imgs[7])
img4 <- image_read(imgs[2])
img5 <- image_read(imgs[4])
img6 <- image_read(imgs[6])
img7 <- image_read(imgs[1])

img_c <- c(img1, img2, img3, img4, img5, img6, img7)

image_animate(img_c, fps = 1)
