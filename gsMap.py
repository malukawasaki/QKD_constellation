# Map of the optical ground stations in Europe. Source: ENISA(2022), ESA(2023) and TNO(2023)

import folium
European_map = folium.Map()

# Add tiles:
# folium.TileLayer('MapQuest Open Aerial').add_to(European_map)

#European ground stations
stations = [[48.0744, 11.2622], [36.8381, -2.4597], [37.8206, 22.6610], [35.1558, 24.8950], [52.0706, 4.3129], [47.0766, 15.4213],[51.903614, -8.468399], [47.497913, 19.040236],[45.328979, 14.457664],[35.884445, 14.506944],[40.666668, 16.600000],[46.770439, 23.591423],[44.439663, 26.096306],[40.629269, 22.947412], [34.707130, 33.022617]]

for station in stations:
    folium.CircleMarker(station,radius = 5,color = 'blue',fill = True).add_to(European_map)

# Add polylines (for the optical fiber infrastructure)
# folium.PolyLine(points, color="red", weight=2.5, opacity=1).add_to(European_map)

# Create an HTML file of the map
European_map.save('Europe7.html')