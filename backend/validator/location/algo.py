import h3

def get_grid_disk(lat, lon):
    cell = h3.geo_to_h3(lat, lon, 7)
    disk = h3.k_ring(cell, 1)
    return disk

def geo_filter(df, lat, lon):
    disk = get_grid_disk(lat, lon)
    return df.loc[df['cell_id'].isin(disk)]


