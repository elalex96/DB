
/*
DANIEL MORENO 03/11/2020
Función creada para obtener la cantidad que ha sido consumida dentro de las diferentes OTs
*/

create FUNCTION [dbo].[fn_SC_GetCantidadUsada]
(
	@pIdSCMaterial int
)
RETURNS float
AS
BEGIN
	 declare @result float

	
	
	select  @result = isnull(sum(otMat.Cantidad),0)
	from OT_Solicitud ot
	inner join SC_Subcontrato sc on sc.IdSubContrato = ot.IdSubContrato
	inner join SC_Materiales sMat on sMat.IdSubContrato = sc.IdSubContrato
	inner join [dbo].[OT_SolicitudMaterial] otMat on otMat.IdSCMaterial = sMat.IdSCMaterial	
	where sMat.IdSCMATERIAL = @pIdSCMATERIAL and
	isnull(ot.IsActivo,0) = 1 and
	ot.IdOTEstatus not in (7,8,12) and
	otMat.IdOTSolicitud = ot.IdOTSolicitud 
	--order by otMat.IdOTSolicitudMaterial


	select	
		@result = @result + isnull(sum(spc.Captura),0)
	from SC_Materiales sMat
	inner join [OT_SolicitudMaterial] otMat2 on otMat2.IdSCMaterial = SmAT.IdSCMaterial
	inner join OT_Solicitud ot2 on ot2.IdOTSolicitud = otMat2.IdOTSolicitud and
	ot2.IdOTEstatus in (12) and
	isnull(ot2.IsActivo,0) = 1
	inner join OT_SolicitudProgramaCaptura spc on spc.VoBoContratista = 1 and
	spc.IdOTSolicitudMaterial = otMat2.IdOTSolicitudMaterial
	 where sMat.IdSCMATERIAL = @pIdSCMATERIAL       
	 


	 return @result

END