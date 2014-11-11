
	weightUpdateModel wu;

			
  // Add new weightupdate type - static weightp: 
  wu.varNames.clear();
  wu.varTypes.clear();
  
  wu.pNames.clear();
  
  wu.pNames.push_back(tS("g_WU"));
  //wu.dpNames.clear();

  wu.simCode = tS(" \
      { \n \
     } \n \
  	 	$(addtoinSyn) = $(g_WU); \n \
				$(updatelinsyn); \n \
");

  weightUpdateModels.push_back(wu);

	
			
  // Add new weightupdate type - static weight: 
  wu.varNames.clear();
  wu.varTypes.clear();
  
  wu.varNames.push_back(tS("g_WU"));
  wu.varTypes.push_back(tS("float"));
  wu.pNames.clear();
  
  //wu.dpNames.clear();

  wu.simCode = tS(" \
      { \n \
     } \n \
  	 	$(addtoinSyn) = $(g_WU); \n \
				$(updatelinsyn); \n \
");

  weightUpdateModels.push_back(wu);

	
			
  // Add new weightupdate type - static weight: 
  wu.varNames.clear();
  wu.varTypes.clear();
  
  wu.varNames.push_back(tS("g_WU"));
  wu.varTypes.push_back(tS("float"));
  wu.pNames.clear();
  
  //wu.dpNames.clear();

  wu.simCode = tS(" \
      { \n \
     } \n \
  	 	$(addtoinSyn) = $(g_WU); \n \
				$(updatelinsyn); \n \
");

  weightUpdateModels.push_back(wu);

	