
function  media_search, DATES=dates_value,WAVES=waves_list,CADENCE=cadence_list,NB_RES_MAX=nbresmax_value
	compile_opt idl2
	
	IF n_elements(dates_value) EQ 0 THEN message, "Provide dates please" ELSE DATES=dates_value
	IF n_elements(waves_list) EQ 0 THEN WAVES=LIST('94','131','171','193','211','304','335','1600','1700') ELSE WAVES=waves_list
	IF n_elements(cadence_list) EQ 0 THEN CADENCE=LIST('1+min') ELSE CADENCE=cadence_list
	IF n_elements(nbresmax_value) EQ 0 THEN NB_RES_MAX=-1 ELSE NB_RES_MAX=nbresmax_value

	sdo_dataset=obj_new('sdoIasDataset')

	PRINT, "Loading MEDIA Sitools2 client : ",sdo_dataset->get_sitools2_url()
	fields_list=(sdo_dataset->get_attributes()).FIELDS_LIST
	dates_param=LIST([fields_list[4]],DATES,'DATE_BETWEEN')
	waves_param=LIST([fields_list[5]],WAVES,'IN')
	cadence_param=LIST([fields_list[10]],CADENCE,'CADENCE')

	Q1=obj_new('query',dates_param)
	Q2=obj_new('query',waves_param)
	Q3=obj_new('query',cadence_param)

;;	PRINT, Q2
;;	PRINT, Q2->get_value_list_str()

	query_list=LIST(Q1,Q2,Q3)
	;;Ask columns : get, recnum, sunum, date__obs, wavelnth, ias_location,exptime,t_rec_index etc...
	output_options=LIST(fields_list[0],fields_list[1],fields_list[2],fields_list[4],fields_list[5],fields_list[7],fields_list[8],fields_list[9])
	;;sort date_obs ASC, wave ASC
	sort_options=LIST(LIST(fields_list[5],'ASC'),LIST(fields_list[4],'ASC'))

	results=sdo_dataset->search(query_list, output_options, sort_options, limit_to_nb_res_max=NB_RES_MAX)
	
;;	FOREACH data, results DO PRINT, JSON_SERIALIZE(data)
	sdo_data_list=LIST()
	IF n_elements(results) NE 0 THEN BEGIN
		FOREACH data_item, results DO BEGIN
			sdo_data_list.Add, obj_new('sdoData',data_item)
		ENDFOREACH
	ENDIF
	PRINT , "Nbr results : "+STRTRIM(n_elements(results),2)

	OBJ_DESTROY, Q1,Q2,Q3
	return, sdo_data_list
end
