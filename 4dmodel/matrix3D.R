library(tidyr)
library(tidyverse)
library(rgl)

r3dDefaults$windowRect <- c(0,0, 1000, 1000)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

roundUp <- function(x) 10^ceiling(log10(x))

draw_lines <- function(file,color,x,y,z,z_label) {
  
  path<-read.csv(file, sep="\t")
  seg_x <- c(path$x)
  seg_y <- c(path$y)
  seg_z <- c(path$cost)
  
  draw_landscape(x,y,z,z_labels)
  
  #peak<-filter(landscape, QV == max(na.omit(z_QV)))
  #arrow3d(cbind(peak[,1],peak[,2],peak[,3]+0.2),cbind(peak[,1],peak[,2],peak[,3]+0.03), col = "red", size=20)
  
  
  start_time=0
  dur=3
  
  for(i in 1:dim(path)[1])
  {
    if (i==1) {
      points3d(cbind(seg_x[1],seg_y[1],seg_z[1]), col = color, size=6)
      movie3d(spin3d(axis = c(0, 0, 1),rpm = 0.5), startTime = start_time, duration = dur,dir = "figures/", convert = FALSE)  
      start_time=start_time+dur
      dur=1
      
      
    } else {
      
      M <- par3d("userMatrix")
      
      points3d(cbind(seg_x[i],seg_y[i],seg_z[i]), col = "black", size=3)
      lines3d(cbind(rbind(seg_x[i],seg_x[i-1]),rbind(seg_y[i],seg_y[i-1]),rbind(seg_z[i],seg_z[i-1])), add=TRUE, lwd = 3, col = color)
      
      movie3d( par3dinterp(time = c(start_time,start_time+dur), userMatrix = list(M,rotate3d(M, 0.05, 0, 0, 1) ) ), startTime = start_time, duration = start_time+dur,dir = "figures/", convert = FALSE)
      
      start_time=start_time+dur
    }
  }
  
  movie3d( par3dinterp(time = c(start_time,dur), userMatrix = list(M,M) ), startTime = start_time, duration = start_time+1,dir = "figures/", convert = FALSE)
  
}
draw_landscape <- function(x,y,z,z_label) {
  
  par3d(zoom=1.5)
  persp3d(x,sort(y),z, col=color[zcol], xlab="",ylab="",zlab="", axes = FALSE, box = TRUE, alpha=0.8)
  #title3d('enrichment by PHASTcons parameters len and tc')
  axis3d(edge= 'x', at=seq(min(x), max(x),by=roundUp((max(x)-min(x))/10)))
  axis3d(edge= 'y-', at=seq(min(y), max(y),by=0.15))
  axis3d(edge= 'z+', at=seq(min(na.omit(z)), max(na.omit(z)), by=roundUp((max(z)-min(z))/20)))
  
  mtext3d("Tc (Target coverage)", edge= 'y-', line = 4, at = NULL, pos = NA)
  mtext3d("Len (Min expected len)", edge= 'x', line = 4, at = NULL, pos = NA)
  mtext3d(z_label, edge= 'z+', line = 4, at = NULL, pos = NA)
  
}

generate_landscape <- function(landscape, variable, z_label) {
  
  matrix<-pivot_wider(landscape, id_cols = len, names_from = tc, values_from = {{variable}})
  matrix<- matrix[order(matrix$len),]
  max = max(na.omit(c(get(variable,landscape))))
  peak<-filter(landscape, {{variable}} == max)
  
  y<-na.omit(as.numeric(colnames(matrix)))
  x<-deframe(tibble(matrix$len))
  z<-data.matrix(unname(matrix[,-1]))
  
  nbcol = 4
  color = rev(heat.colors(nbcol))
  zcol  = cut(z, nbcol)
  
  draw_landscape(x,y,z,z_label)
  arrow3d(cbind(peak[,1],peak[,2],peak[,5]+0.01), cbind(peak[,1],peak[,2],peak[,5]+0.005), col = "red", s = 1/3, theta = pi/4)
  movie3d(spin3d(axis = c(0, 0, 1),rpm = 0.5), startTime = 0, duration = 40,dir = "figures/", convert = TRUE)
}

#landscape
landscape<-read.csv("matrix3D.def.txt", sep="\t")
landscape<-landscape %>% distinct(len, tc, .keep_all = TRUE)

generate_landscape(landscape, "enrichment", "Enrichment (Jaccard)")
generate_landscape(landscape, "intersection", "Intersection")

# gradient descent
draw_lines("test4.txt", "purple")
draw_lines("test15.txt", "green",x,y,z_QV,0.1)
draw_lines("test21.txt", "blue")
draw_lines("test16.txt", "aquamarine")
draw_lines("test19.txt", "darkslateblue")
draw_lines("test25.txt", "darkolivegreen1",x,y,z_QV,0.1)

rgl.quads( x = c(4395000,4395000,4395000,4395000), y = c(min(y), max(y), max(y), min(y)),
           z = c(min(na.omit(z_QV)),min(na.omit(z_QV)),max(na.omit(z_QV)),max(na.omit(z_QV))), alpha=0.6)

draw_landscape(z_cost,1)
draw_lines("test25.txt", "darkolivegreen1",x,y,z_cost,0.5)

fil_landscape<-filter(landscape, between(genomeSize, 4000000, 4200000))
fil_m_cost<-pivot_wider(fil_landscape, id_cols = genomeSize, names_from = err_rate, values_from = cost)
fil_m_cost<- fil_m_cost[order(fil_m_cost$genomeSize),]
fil_z_cost<-data.matrix(unname(fil_m_cost[,-1]))
fil_y<-na.omit(as.numeric(colnames(fil_m_cost)))
fil_x<-deframe(tibble(fil_m_cost$genomeSize))


draw_lines("test25.txt", "darkolivegreen1",fil_x,fil_y,fil_z_cost,1)


