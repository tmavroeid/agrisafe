import pyarrow.parquet as pq
import location.algo as location

def from_file(path):
    return pq.read_pandas(path, columns=['name', 'cell_id', 'precipitation_rate', 'temperature']).to_pandas()

def decide(path, algo, lat, lon):
    df = from_file(path)
    geo_filtered = location.geo_filter(df, lat, lon)
    return algo(geo_filtered)


