CREATE PROCEDURE [dbo].[SP_TaNotificarTarea] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
-- =============================================
-- Author:		ManuelCruz
-- Create date: 09-01-17
-- Description:	SP principal con el que trabaja el servicio de windows ya que es el que hace la consulkta diaria
				-- devolviendo el IdTarea, IdUsuario, Correo, NombreTarea, FechaRegistro, FechaNotificacion calculada
				-- de acuerdo al tipo si es por Recordatorio, si es el Ultimo Dia por aprobar, ya que va a vencer ese dia.
				-- O si ya esta vencida la tarea y nadie la aprobo o falto algun usuario, todo esto mientras,
				-- mientras en la tabla de Tareas el campo de Activo esté en True
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TipoNotificacion INT = 1
	DECLARE @TipoCancelacion INT = 2
	DECLARE @TipoVencido INT = 3

	--DECLARE @Fecha DATE = (SELECT cast(DATEADD (day, -1, getdate()) as date))

    -- Insert statements for procedure here

	SELECT T.IdTarea,
	Us.UsuarioID, 
	Us.Usuario, 
	T.NombreTarea, 
	cast (T.FechaRegistro as date) as FechaRegistro, 
	cast(DATEADD (day, NT.DiaNotificacion, T.FechaRegistro) as date) as FechaNotificacion, 
	FN.FechaEnvio,
	@TipoNotificacion
	
	FROM TaTarea T 
	JOIN TaVencimiento V ON V.IdVencimiento = T.IdVencimiento
	JOIN TaNotificacionTarea NT ON NT.IdVencimiento = T.IdVencimiento
	JOIN TaTareaAprobador AS TAp ON TAp.IdTarea = T.IdTarea
	JOIN AP_Usuario Us ON Us.UsuarioID = TAp.IdUsuario
	LEFT JOIN TaFechasNotificacion FN ON T.IdTarea = FN.IdTarea 
	AND TAp.IdUsuario = FN.IdUsuario AND FN.FechaNotificacion = cast(DATEADD (day, NT.DiaNotificacion, T.FechaRegistro) as date)
	-- CUANDO SE TRATA DE CAMPOS DE TIPO BIT, SE PUEDE PONER LA ASIGNACION COMO: T.ACTIVO = 1 EN LUGAR DE TRUE
	WHERE T.Activo = 'True' 
	AND cast(DATEADD (day, NT.DiaNotificacion, T.FechaRegistro) as date) = cast (getdate() as date) 
	AND FechaEnvio IS NULL

	UNION

	SELECT T.IdTarea,
	Us.UsuarioID, 
	Us.Usuario, 
	T.NombreTarea, 
	cast (T.FechaRegistro as date) as FechaRegistro,
	cast(DATEADD (day, V.DiaVencimiento, T.FechaRegistro) as date) as FechaVencimiento,
	FN.FechaEnvio,
	@TipoCancelacion
	
	FROM TaTarea T
	JOIN TaVencimiento V ON V.IdVencimiento = T.IdVencimiento
	JOIN TaTareaAprobador AS TAp ON TAp.IdTarea = T.IdTarea
	JOIN AP_Usuario Us ON Us.UsuarioID = TAp.IdUsuario
	LEFT JOIN TaFechasNotificacion FN ON T.IdTarea = FN.IdTarea 
	AND Us.UsuarioID = FN.IdUsuario AND FN.FechaNotificacion = cast(DATEADD (day, V.DiaVencimiento, T.FechaRegistro) as date)

	WHERE T.Activo = 'True'
	AND cast(DATEADD (day, V.DiaVencimiento, T.FechaRegistro) as date) = cast (getdate() as date)
	AND FechaEnvio IS NULL
	
	UNION

	SELECT T.IdTarea,
	Us.UsuarioID, 
	Us.Usuario,
	T.NombreTarea, 
	cast (T.FechaRegistro as date) as FechaRegistro,
	cast(DATEADD (day, V.DiaVencimiento, T.FechaRegistro) as date) as FechaVencimiento,
	FN.FechaEnvio,
	@TipoVencido
	
	FROM TaTarea T
	JOIN TaVencimiento V ON V.IdVencimiento = T.IdVencimiento
	JOIN TaTareaAprobador AS TAp ON TAp.IdTarea = T.IdTarea
	JOIN AP_Usuario Us ON Us.UsuarioID = TAp.IdUsuario
	LEFT JOIN TaFechasNotificacion FN ON T.IdTarea = FN.IdTarea 
	AND Us.UsuarioID = FN.IdUsuario AND FN.FechaNotificacion = cast(DATEADD (day, V.DiaVencimiento, T.FechaRegistro) as date)

	WHERE T.Activo = 'True'
	AND cast(DATEADD (day, V.DiaVencimiento, T.FechaRegistro) as date) = cast(DATEADD (day, -1, getdate()) as date)
	
END



