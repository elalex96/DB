USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_ENT_ActualizarUsuarioActividad'
)
    DROP PROCEDURE USP_UPD_ENT_ActualizarUsuarioActividad;
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/10/2024>
-- Description:	<Actualizacion de usuario de un rol en un entregable>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_ENT_ActualizarUsuarioActividad] --119721,10747,1
	-- Add the parameters for the stored procedure here
	@IdContratoEntregable INT,
	@IdContrato INT,
	@IdUsuarioRemplazo INT,
	@IdUsuarioSustituto INT,
	@Justificacion NVARCHAR(1000),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CorreoUsuarioSeleccionado NVARCHAR(100) = (SELECT Usuario FROM AP_Usuario WHERE UsuarioID = @IdUsuarioRemplazo);
	DECLARE @CorreoUsuarioSustituto NVARCHAR(100) = (SELECT Usuario FROM AP_Usuario WHERE UsuarioID = @IdUsuarioSustituto);
	DECLARE @NombreUsuarioSeleccionado NVARCHAR(100) = (SELECT Nombre FROM AP_Usuario WHERE UsuarioID = @IdUsuarioRemplazo);
	DECLARE @NombreUsuarioSustituto NVARCHAR(100) = (SELECT Nombre FROM AP_Usuario WHERE UsuarioID = @IdUsuarioSustituto);
	DECLARE @RolesUsuarioSustituido NVARCHAR(1000) = '';
	DECLARE @DetalleString NVARCHAR(1000) = '';
	--SE OBTIENEN LAS ACTIVIDADES RELACIONADAS AL USUARIO
	CREATE TABLE #EN_Actividad (
		[ActividadID] int,
		[EstadoID] int,
		[idUsuario] int,
		[IdContratoEntregable] int,
		[CreadoPor] int,
		[CreadoEn] datetime,
		[ModificadoPor] int,
		[ModificadoEn] datetime,
		[Activo] bit,
	)

	INSERT INTO #EN_Actividad
	SELECT
		ActividadID
      ,EstadoID
      ,idUsuario
      ,IdContratoEntregable
      ,CreadoPor
      ,CreadoEn
      ,ModificadoPor
      ,ModificadoEn
      ,Activo
	FROM EN_Actividad
	WHERE IdContratoEntregable = @IdContratoEntregable
		AND idUsuario = @IdUsuarioRemplazo;

	--SE ELEIMINAN LAS ACTIVIDADES RELACIONADAS AL ENTREGABLE Y AL ROL DEL USUARIO POR EL QUE SE VA SUSTITUIR
	DELETE FROM EN_Actividad
	WHERE IdContratoEntregable = @IdContratoEntregable
	AND EstadoID IN (SELECT EstadoID FROM #EN_Actividad);

	--SE ACTUALIZA LOS ROLES DE NOTIFICACION
	UPDATE EN_ContratoEntregable
	SET FocalPoint = REPLACE(FocalPoint,@CorreoUsuarioSeleccionado, @CorreoUsuarioSustituto) 
	WHERE IdContratoEntregable = @IdContratoEntregable
	AND FocalPoint LIKE '%'  + @CorreoUsuarioSeleccionado + '%';

	UPDATE EN_ContratoEntregable
	SET AccountableCompliance = REPLACE(AccountableCompliance,@CorreoUsuarioSeleccionado, @CorreoUsuarioSustituto) 
	WHERE IdContratoEntregable = @IdContratoEntregable
	AND AccountableCompliance LIKE '%'  + @CorreoUsuarioSeleccionado + '%';

	UPDATE EN_ContratoEntregable
	SET Accountable = REPLACE(Accountable,@CorreoUsuarioSeleccionado, @CorreoUsuarioSustituto) 
	WHERE IdContratoEntregable = @IdContratoEntregable
	AND Accountable LIKE '%'  + @CorreoUsuarioSeleccionado + '%';

	--SE AGREGAN LAS ACTIVIDADES ANTERIORES PERO CON EL NUEVO USUARIO
	INSERT INTO EN_Actividad
	(
		EstadoID,
		idUsuario,
		IdContratoEntregable,
		CreadoEn,
		Activo
	)
	SELECT
		EstadoID,
		@IdUsuarioSustituto,
		@IdContratoEntregable,
		GETDATE(),
		1
	FROM #EN_Actividad
	GROUP BY EstadoID

	SET @Justificacion = 'Sustitución de usuario en el flujo del Entregable - Justificación: ' + CAST(@Justificacion AS NVARCHAR);

	SET @DetalleString = 'El usuario ##Usuario### remplazo al usuario ' + ISNULL(@NombreUsuarioSeleccionado,'') + ' por ' + ISNULL(@NombreUsuarioSustituto,'') + ' ,en el flujo del IdContratoEntregable ' + CAST(@IdContratoEntregable AS NVARCHAR) + ' en el contrato ##Contrato##, fecha de ##Fecha##';

	EXEC SP_AP_GuardaBitacoraAccion @Mensaje = @Justificacion,
										@Detalle = @DetalleString,
										@ContratoId = @IdContrato,
										@UsuarioId = @IdUsuario,
										@Tipo = 'Sustitución';

	SELECT 'SUSTITUCION CORRECTA' AS RESPONSE;

END