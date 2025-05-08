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
  
# define factor levels to control plotting order
gene_data$Category <- factor(gene_data$Category, levels = c(
    "Impaired neural regeneration & Behavior phenotype",
    "Impaired neural regeneration only",
    "Behavior phenotype only",
    "Normal"
    )
)

# colors
color_palette <- c("Impaired neural regeneration & Behavior phenotype" = "green", 
                   "Impaired neural regeneration only" = "magenta",
                   "Behavior phenotype only" = "gray", 
                   "Normal" = "gray10")

# plot
screenresults <- ggplot(gene_data, aes(x = "", y = Count, fill = Category)) +
  geom_bar(stat = "identity", width = 2, color = "white", linewidth = 0.5) +  # Create the bars
  coord_polar("y", start = 0) +  # Convert to pie chart
  theme_void() +  # Remove unnecessary axes
  scale_fill_manual(values = color_palette) +  # Apply custom colors
  labs(title = "In vivo Candidate Screen Results") +
  theme(plot.title = element_text(hjust = 0.5))  # Center the title
screenresults
ggsave("InvivoCandidateScreenResults", plot = screenresults, device = "pdf")
