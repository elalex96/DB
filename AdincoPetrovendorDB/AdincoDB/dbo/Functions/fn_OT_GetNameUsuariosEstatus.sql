

CREATE FUNCTION [dbo].fn_OT_GetNameUsuariosEstatus 
(
	-- Add the parameters for the function here
	@pIdOTSolicitud int,	
	@pIdOTEstatus int,
	@pFlujoAprobacionEstatusId int

)
RETURNS varchar(1000)
AS
BEGIN
	
	declare @result varchar(1000)=''

	select @result =@result + ','+ isnull(u.Nombre,'')  
	from OT_Solicitud ot
	inner join [AP_FlujoAprobacion] fa on fa.TipoFlujoAprobacionId = 1-- Control de Obra
	inner join [AP_FlujoAprobacionEstatus] ae on /*ae.FlujoAprobacionId = fa.FlujoAprobacionId and*/
												ae.FlujoAprobacionEstatusId = @pFlujoAprobacionEstatusId --Aprobación interna OT
	inner join [dbo].[AP_FlujoAprobacionEstatusUsuarios] aeu on aeu.FlujoAprobacionEstatusId = ae.FlujoAprobacionEstatusId
	inner join AP_Usuario u on u.UsuarioID = aeu.UsuarioId	 and u.IsActivo = 1	
	inner join [AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = aeu.UsuarioId and
											ucc.IdCentroCosto = ot.IdCentroCosto
	where  IdOTSolicitud = @pIdOTSolicitud 
	and 
	(
		u.Usuario not like '%@adinco.mx%' and
		u.Usuario not like '%@ogss.com.mx%' and
		u.usuario not like '%@smps-sp.com%' and
		u.usuario not like '%@smpslegal.com%'
	)
	GROUP BY u.Nombre



	return isnull(@result,'')

END
