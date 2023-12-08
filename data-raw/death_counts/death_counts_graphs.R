#####
# graph data
#####
gdt = mdc1[source_name %in% c("DPIC Execution Database", "Epsy and Smykla 2016"), ]
ggplot(data = gdt, mapping = aes(x = year1, y = Death_Count, color = source_name)) +
  geom_line(size = 1) +
  scale_x_continuous(breaks = seq(1890, 2030, by = 10)) +
  theme_sdl() +
  theme(legend.position = 'bottom') +
  labs(title = "Executions in the United States, 1890-2023",
       x = NULL,
       caption = c("@socdoneleft", "Sources:\nDPIC Execution Database (1976-2023)\nExecutions in the United States, 1608-2002: The ESPY File (ICPSR 8451)")) +
  geom_labelled_vline(xvec = c(1932, 1948, 1958, 1968, 1976, 1982, 1988, 1996, 2003, 2008, 2021),
                      yvec = c(50, 50, 150, 150, 150, 150, 150, 150, 150, 150, 150),
                      labs = c("1932: Powell v. Alabama (right to lawyer for death penalty)",
                               "1948: UN declares Universal Human Rights",
                               "1958: Trop v. Dulles ('evolving standards of decency')",
                               "1966: First year with zero executions",
                               "1976: Gregg v. Georgia (death penalty upheld)",
                               "1982: Texas conducts world's first lethal injection",
                               "1988: Dukakis-Bush debate ('no')",
                               "1996: Clinton signs AEDPA (sped death penalty process)",
                               "2003: Federal execution moratorium begins",
                               "2008: Baze v. Rees (lethal injection 'humane')",
                               "2021: Trump executes 13 federal prisoners"),
                      xoffset = -2, color = "white")
ggsave_sdl("executions_1890_2023.png")
