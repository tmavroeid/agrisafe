def has_rain(df):
    rainy_samples = df.loc[df['precipitation_rate'] > 0.0]
    # print(rainy_samples[['cell_id', 'name']].head())
    return not rainy_samples.empty

def has_high_temp(df):
    high_temp = df.loc[df['temperature'] > 30]
    return not high_temp.empty

def has_extreme_conditions(df):
    xtrm = df.loc[(df['temperature'] > 30) | (df['precipitation_rate'] > 20)]
    return not xtrm.empty


