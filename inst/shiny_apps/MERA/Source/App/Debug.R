
SaveDebug<-function(){
  save(OM1,file="OM")
  if(exists("MPs"))save(MPs,file="MPs")
  save(MSEobj,file="MSEobj")
  if(exists("Dep_reb"))save(Dep_reb,file="Dep_reb")
  if(exists("OM_reb"))save(OM_reb,file="OM_reb")
  if(exists("MSEobj_reb"))save(MSEobj_reb,file="MSEobj_reb")
  save(PanelState,file="PanelState")
  if(exists("MSClog"))save(MSClog,file="MSClog")
  save(Skin,file="Skin")
}