// Forest boundary
var geometry = ee.FeatureCollection('projects/ee-vulture/assets/OS_WM_MK');
// Get forest names
var forestNames = geometry.aggregate_array('NOM_FORET');

// 1. Map over forest names and return a list of FeatureCollections
var perForestStats = forestNames.map(function(fn){
  fn = ee.String(fn);
  
  var singleForest = geometry.filter(ee.Filter.eq('NOM_FORET', fn));
  var bufferZone = singleForest.map(function(f) {
    return f.buffer(10000).difference(f);
  });

  // Burned area per image
  var burnedCollection = ee.ImageCollection('MODIS/061/MCD64A1')
    .filterDate('2000-01-01', '2025-06-01')
    .select('BurnDate')
    .map(function(img) {
      var burned = img.gt(0).selfMask();
      var areaImg = burned.multiply(ee.Image.pixelArea());

      var coreArea = areaImg.reduceRegion({
        reducer: ee.Reducer.sum(),
        geometry: singleForest.geometry(),
        scale: 500,
        maxPixels: 1e13
      }).get('BurnDate');

      var bufferArea = areaImg.reduceRegion({
        reducer: ee.Reducer.sum(),
        geometry: bufferZone.geometry(),
        scale: 500,
        maxPixels: 1e13
      }).get('BurnDate');

      var date = img.date();
      return ee.Feature(null, {
        'NOM_FORET': fn,
        'date': date.format('YYYY-MM-dd'),
        'year': date.get('year'),
        'month': date.get('month'),
        'burned_core_m2': ee.Number(coreArea).divide(1e6),
        'burned_buffer_m2': ee.Number(bufferArea).divide(1e6)
      });
    });

  return burnedCollection; // this is a FeatureCollection
});

// 2. Flatten the list of FeatureCollections into a single FeatureCollection
var resultFC = ee.FeatureCollection(perForestStats).flatten();
print(resultFC.limit(10), 'Burned area per zone');

// 3. Export to CSV for further analysis in R
Export.table.toDrive({
  collection: resultFC,
  description: 'Burned_Area_By_Zone_Core_Buffer',
  fileFormat: 'CSV'
});
