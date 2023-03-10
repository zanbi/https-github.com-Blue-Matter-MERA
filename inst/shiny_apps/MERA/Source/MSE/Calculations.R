# Calculations

# Status Calcs
Calc_Status<-function(){
  
  if(LoadOM()==1&input$OM_L){ 
    OM1<-OM_L
  }else{
    if(MadeOM()==0)OM1<<-makeOM(PanelState)
  }

  setup(cpus=ncpus)
  
  tryCatch({
    
    withProgress(message = "Running Status Determination", value = 0, {
      incProgress(1/2, detail = 50)
      dofit(OM1,dat)
      incProgress(2/2, detail = 50) 
    })
    
    SD(1) 
    CondOM(1)
    message("preredoSD")
    smartRedo()
    message("postredoSD")
    
  },
  error = function(e){
    AM(paste0(e,sep="\n"))
    shinyalert("Computational error", paste("The Status Determination method",codes,"returned an error. Try selecting an alternative Status Determination method from the settings menu."), type = "info")
    return(0)
  }
  )

}



Calc_Plan<-function(){
  
  if(LoadOM()==1&input$OM_L){ 
    OM1<<-OM_L
    doprogress("Using loaded OM",1)
  }else{
    
    if(MadeOM()==0){
      doprogress("Building new OM",1)
      OM1<<-makeOM(PanelState)
    }else{
      doprogress("Using the OM that has been built",1)
    }  
      
  }
  
  Fpanel(1)
  MPs<<-getMPs()
  
  nsim<<-input$nsim
  parallel=F
  
  if(input$Parallel){
    
    if(nsim>47){
      
      parallel=T
      setup(cpus=ncpus)
      
    }
    
  }
  
  MSClog<<-list(PanelState, Just, Des)
  
  Update_Options()
  #saveRDS(OM1,"C:/temp/OM.rda") 
  tryCatch({
    AM("Starting MSE projections")
    AM(paste(MPs))
    withProgress(message = "Running Planning Analysis", value = 0, {
      silent=T
      MSEobj<<-runMSE(OM1,MPs=MPs,silent=silent,parallel=parallel)
    })
    
    AM(paste("Class of MSEobj =",class(MSEobj)))
    # if (input$Skin !="Train") { # don't run rebuild for Train skin
    if(exists('SampList'))MSEobj@Misc[[4]]<<-SampList
    Dep_reb<-runif(OM1@nsim,input$Dep_reb[1],input$Dep_reb[2]) # is a %
    OM_reb<-OM1
    OM_reb@cpars$D<-(Dep_reb/100)*MSEobj@OM$SSBMSY_SSB0 
    
    withProgress(message = "Rebuilding Analysis", value = 0, {
      if (!'NFref' %in% MPs) MPs <- c("NFref", MPs) # added this so I can calculate Tmin - rebuild time with no fishing - AH
      MSEobj_reb<<-runMSE(OM_reb,MPs=MPs,silent=silent,parallel=parallel)
    })
    
    MSEobj_reb@Misc[[4]]<<-SampList
    
    # ==== Types of reporting ==========================================================
    #saveRDS(MSEobj,"C:/temp/MSEobj.rda")  #
    #saveRDS(MSEobj_reb,"C:/temp/MSEobj_reb.rda")  #
    
    AM("preredoPlan")
    Plan(1)
    smartRedo()
    AM("postredoPlan")
 
  },
  error = function(e){
    AM(paste0(e,"\n"))
    shinyalert("Computational error", "This probably occurred because the fishery dynamics of your questionnaire are not possible.
                     For example, a short lived stock a low stock depletion with recently declining effort.
                    Try revising operating model parameters.", type = "info")
    return(0)
  }
  
  )
}


Calc_Perf<-function(){
  
  doprogress("Building OM from Questionnaire",1)
  YIU=length(dat_ind@Year)-length(dat@Year)
  
  if(LoadOM()==1&input$OM_L){ 
    OM1<<-OM_L
  }else{
    if(MadeOM()==0)OM1<<-makeOM(PanelState,proyears=YIU*2) # project to 2 x years in use
  }  
  
  Fpanel(1)
  EvalMPs<-input$sel_MP
  
  nsim<<-input$nsim
  parallel=F
  
  if(input$Parallel){
    
    if(nsim>47){
      
      parallel=T
      setup(cpus=ncpus)
      
    }
    
  }
  
  MSClog<<-list(PanelState, Just, Des)
  Update_Options()
  
  tryCatch({
    
    withProgress(message = "Running Performance Evaluation", value = 0, {
        
      EvalMPs<-input$sel_MP
      MSEobj_Eval<<-runMSE(OM1,MPs=EvalMPs,silent=T,parallel=parallel)
       #saveRDS(MSEobj_Eval,"C:/temp/MSEobj_Eval.rda") # 
       #saveRDS(dat,"C:/temp/dat.rda") #  
       #saveRDS(dat_ind,"C:/temp/dat_ind.rda") # 
    })
    
    Eval(1)
    Ind(1)
    message("preredoEval")
    smartRedo()
    message("postredoEval")
    
  },
  error = function(e){
    AM(paste0(e,"\n"))
    shinyalert("Computational error", "This probably occurred because your simulated conditions are not possible.
                   For example a short lived stock a low stock depletion with recently declining effort.
                   Try revising operating model parameters.", type = "info")
    return(0)
  }
  ) # try catch
  
}
