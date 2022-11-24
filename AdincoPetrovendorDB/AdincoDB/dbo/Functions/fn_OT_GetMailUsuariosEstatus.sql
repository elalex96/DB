
CREATE FUNCTION [dbo].[fn_OT_GetMailUsuariosEstatus] 
(
	-- Add the parameters for the function here
	@pIdOTSolicitud int,	
	@pIdOTEstatus int,
	@pFlujoAprobacionEstatusId int,
	@pTipoNotificacionId int
)
RETURNS varchar(max)
AS
BEGIN
	
	declare @result varchar(max)=''

	declare @tmpNotificacion TABLE (UsuarioId int,TipoNotificacionId int,Desactivar bit)


	insert into @tmpNotificacion(UsuarioId,TipoNotificacionId,Desactivar)
	SELECT un.UsuarioId,un.TipoNotificacionId,un.Desactivar 
	FROM [AP_UsuarioNotificaciones] un
	inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = un.UsuarioId 
	inner join OT_Solicitud ot on ot.IdCentroCosto = ucc.IdCentroCosto and
									ot.IdOTSolicitud = @pIdOTSolicitud
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato and
									sc.IdContrato = un.ContratoId
	INNER JOIN AP_Usuario U ON U.UsuarioId = un.UsuarioId AND U.IsActivo = 1	
	where un.Desactivar = 1 and
	un.TipoNotificacionId = @pTipoNotificacionId
	

	select @result =@result + ';'+ isnull(u.Usuario,'')  
	from OT_Solicitud ot
	inner join [AP_FlujoAprobacion] fa on fa.TipoFlujoAprobacionId = 1-- Control de Obra
	inner join [AP_FlujoAprobacionEstatus] ae on /*ae.FlujoAprobacionId = fa.FlujoAprobacionId and*/
												ae.FlujoAprobacionEstatusId = @pFlujoAprobacionEstatusId --Aprobación interna OT
	inner join [dbo].[AP_FlujoAprobacionEstatusUsuarios] aeu on aeu.FlujoAprobacionEstatusId = ae.FlujoAprobacionEstatusId
	inner join AP_Usuario u on u.UsuarioID = aeu.UsuarioId	 and u.IsActivo = 1	
	inner join [AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = aeu.UsuarioId and
											ucc.IdCentroCosto = ot.IdCentroCosto
	where  IdOTSolicitud = @pIdOTSolicitud and 
	u.UsuarioID not in (
		select UsuarioId
		from @tmpNotificacion
	)
	GROUP BY u.Usuario



	return isnull(@result,'')

END


