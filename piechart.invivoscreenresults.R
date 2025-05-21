library(tidyverse)
library(ggplot2)

# make df
gene_data <- data.frame(
  Category = c("Impaired neural regeneration & Behavior phenotype",
               "Impaired neural regeneration only",
               "Behavior phenotype only",
               "Normal"),
  Count = c(12, 1, 6, 38),
  Group = c("Impaired neural regeneration & Behavior phenotype",
             "Impaired neural regeneration only",
             "Behavior phenotype only",
             "Normal")
  )
  
# define factor levels to control plotting order
gene_data$Category <- factor(gene_data$Category, levels = c(
    "Impaired neural regeneration & Behavior phenotype",
    "Impaired neural regeneration only",
    "Behavior phenotype only",
    "Normal")
)

# colors
color_palette <- c("Impaired neural regeneration & Behavior phenotype" = "green", 
                   "Impaired neural regeneration only" = "magenta",
                   "Behavior phenotype only" = "gray", 
                   "Normal" = "gray25")

# calculate label positions within pie
gene_data <- gene_data %>%
  dplyr::mutate(
    fraction = Count / sum(Count),
    ymax = cumsum(fraction),
    ymin = dplyr::lag(ymax, default = 0),
    labelPosition = (ymax + ymin) / 2,
    label = as.character(Count),
    label_color = ifelse(Category == "Normal", "white", "black")
  )


# plot pie chart
screenresults <- ggplot(gene_data, aes(x = "", y = Count, fill = Category)) +
  geom_bar(stat = "identity", width = 2, color = "white", linewidth = 0.5) +
  coord_polar("y", start = 0) +  # convert to pie chart
  geom_text(aes(y = labelPosition, label = label, color = "label_color"), size = 4) + # add counts within pie segments
  theme_void() +  # Remove unnecessary axes
  scale_fill_manual(values = color_palette) +  # Apply custom colors
  labs(title = "In vivo Candidate Screen Results") +
  theme(plot.title = element_text(hjust = 0.5))  # Center the title
screenresults
ggsave("InvivoCandidateScreenResults.pdf", plot = screenresults, device = "pdf")



# stacked bar 

screenresultsbar <- ggplot(gene_data, aes(x = "All", y = Count, fill = Category)) +
  geom_bar(stat = "identity", width = 0.5, color = "white") +
  geom_text(aes(y = midpoint, label = label, color = label_color), size = 5, show.legend = FALSE) +
  scale_fill_manual(values = color_palette) +
  scale_color_identity() +
  scale_y_continuous(
    breaks = seq(0, 70, by = 10),  # Interval of 10
    expand = expansion(mult = c(0, 0.05))  # Remove extra space at bottom
  ) +
  theme_minimal(base_size = 16) +  # Increases base font size including y-axis
  labs(title = "In vivo Candidate Screen Results", x = NULL, y = "Count") +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    plot.title = element_text(hjust = 0.5)
  )
screenresultsbar

# Save
ggsave("InvivoCandidateScreenResults.Bar.pdf", plot = screenresultsbar, device = "pdf")


