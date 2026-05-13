CREATE PROCEDURE [dbo].[SP_TaMostrarTareaAprobador] 	-- Add the parameters for the stored procedure here
@IdTarea INT,
@IdUsuario INT

AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 02-01-17
-- Description:	Muestra el contenido o los detalles de la tarea que le fue enviada al usuario Aprobador
				-- validando que exista el Asignador para esa tarea
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    	SET NOCOUNT ON;
	
	DECLARE @IdEstatusApr INT
	DECLARE @IsAsignador INT 
	DECLARE @IsAprobador INT
	

    -- Insert statements for procedure here
-- USAR EL MISMO SELECT PARA REALIZAR LA ASIGNACION
	--SET @IsAprobador = (SELECT COUNT(TAP.IdUsuario) 
	SELECT @IsAprobador = COUNT(TAP.IdUsuario) 
	FROM TaTarea AS T
	JOIN TaTareaAprobador AS TAP ON TAP.IdTarea = T.IdTarea
	JOIN AP_Usuario Us ON TAP.IdUsuario = Us.UsuarioID
	WHERE T.IdTarea = @IdTarea AND TAP.IdUsuario = @IdUsuario

	IF (@IsAprobador > 0) 
		BEGIN
		
		SELECT @IdEstatusApr = TA.IdEstatus 
		FROM TaTarea T
		JOIN TaTareaAprobador TA ON T.IdTarea = TA.IdTarea
		JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
		JOIN TaEstatus E ON TA.IdEstatus = E.IdEstatus
		WHERE T.IdTarea = @IdTarea AND TA.IdUsuario = @IdUsuario

		SELECT T.NombreTarea,  Us.Nombre AS NombreAsignador, T.FechaRegistro, TipTa.NombreTipoTarea AS NombreTipoTarea,
		P.Nombre AS NombrePrioridad, T.Descripcion, T.IdEstatus AS IdEstatusTarea, E.Nombre AS NombreEstatusGral,
		@IdEstatusApr AS EstatusApr, Us.UsuarioID AS IdAsignador, V.DiaVencimiento AS Vencimiento, 
		CAST(DATEADD(day,CAST(V.DiaVencimiento AS int), T.FechaRegistro)AS date) AS FVencimiento, CCT.Comentario AS ComentarioCancelacion, T.idOperacion		
		FROM TaTarea AS T 
		JOIN TaTipoTarea TipTa ON T.IdTipoTarea = TipTa.IdTipoTarea
		JOIN TaTareaAsignador TA ON T.IdTarea = TA.IdTarea
		JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
		JOIN TaPrioridad P ON T.IdPrioridad = P.IdPrioridad
		JOIN TaVencimiento AS V ON V.IdVencimiento = T.IdVencimiento
		JOIN TaEstatus E ON T.IdEstatus = E.IdEstatus
		LEFT JOIN TaComentarioCancelacionTarea CCT ON CCT.IdTarea = T.IdTarea
		WHERE T.IdTarea = @IdTarea
	END 
END
