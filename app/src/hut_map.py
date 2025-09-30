import folium

from streamlit_folium import st_folium


color_map = {
    None: 'gra  y',
    0: 'red',
}

def render_map(data):
    m = folium.Map(location=[46.773988681609087128, 10.004598243242869], zoom_start=8)

    fg = folium.FeatureGroup(name="Huts")
    for hut in data:
        location = [hut.latitude, hut.longitude]
        color = color_map.get(hut.free_beds, 'green')
        icon = folium.Icon(color=color, icon="info-sign")

        fg.add_child(folium.Marker(
            location,
            popup=f"{hut.hut_name}<br>Free beds: {hut.free_beds}",
            tooltip=hut.hut_name,
            icon=icon,
        ))


    st_folium(
        m,
        feature_group_to_add=fg,
        width=2000,
        height=700,
    )
