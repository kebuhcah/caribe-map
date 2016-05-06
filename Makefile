build/ne_10m_admin_0_countries.zip:
	mkdir -p $(dir $@)
	curl -o $@ http://www.naturalearthdata.com/download/10m/cultural/$(notdir $@)

build/ne_10m_admin_0_countries.shp: build/ne_10m_admin_0_countries.zip
	unzip -od $(dir $@) $<
	touch $@

build/ne_10m_populated_places.zip:
	mkdir -p $(dir $@)
	curl -o $@ http://www.naturalearthdata.com/download/10m/cultural/$(notdir $@)

build/ne_10m_populated_places.shp: build/ne_10m_populated_places.zip
	unzip -od $(dir $@) $<
	touch $@

build/countries.json: build/ne_10m_admin_0_countries.shp
	ogr2ogr -f GeoJSON -where "ADM0_A3 IN ('ATG', 'BHS', 'BLZ', 'BRB', 'CRI', \
	                                       'CUB', 'DMA', 'DOM', 'GLP', 'GRD', \
																				 'GTM', 'GUF', 'GUY', 'HND', 'HTI', \
																				 'JAM', 'KNA', 'LCA', 'MTQ', 'NIC', \
																				 'PAN', 'SLV', 'SUR', 'TTO', 'VCT', \
																				 'VEN', 'COL', 'BRA', 'USA', 'MEX', \
																				 'PRI', 'FRA', 'PER', 'ECU')" $@ $<

build/cities.json: build/ne_10m_populated_places.shp
	ogr2ogr -f GeoJSON -where "ISO_A2 IN ('AG', 'BS', 'BZ', 'BB', 'CR', 'CU', 'DM', \
	                                      'DO', 'GP', 'GD', 'GT', 'GF', 'GY', 'HN', \
																				'HT', 'JM', 'KN', 'LC', 'MQ', 'NI', 'PA', \
																				'SV', 'SR', 'TT', 'VC', 'VE') \
																				AND FEATURECLA = 'Admin-0 Capital'" $@ $<

build/caribe.json: build/countries.json
	topojson -o $@ --id-property 'ADM0_A3,country' \
	--external-properties localdata/caribe_official.tsv \
	--properties quotaKbd=+quotaKbd \
	--properties consumptionKbd=+consumptionKbd \
	--properties name=NAME_LONG -- $^

public/caribe.json: build/caribe.json
	cp $< $@
