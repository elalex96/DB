-- =============================================
-- Author:		Reyna Olvera
-- Create date: 16042020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_GuardaActividadesEnProcesosProgramados]--10061,3,285713
    @idUsuario INT,
    @idContrato INT,
	@IdInstanciasProceso	INT,
	@NombreActividad varchar(5000),
	@FechaInicio Date,
	@FechaFinReal Date
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @IdActividad	INT = 0,
			@IdProceso	INT,
			@idInstanciaActividad	INT	=	0;

	SELECT @IdProceso	=	IdProceso 
	FROM EN_InstanciasProcesosFecha 
	WHERE IdInstanciasProcesos	=	@IdInstanciasProceso;

	IF(@IdProceso > 0)
	BEGIN
		INSERT INTO EN_Actividades(NombreActividad,Dias,DiasNaturales,CreadoPor,CreadoEl,Activo,IdRegulador,IdActividadOriginal)VALUES(@NombreActividad,0,0,@idUsuario,GETDATE(),1,NULL,NULL);

		SET @IdActividad	=	@@IDENTITY;

		IF(@IdActividad > 0)
		BEGIN
			INSERT INTO EN_ProcesosActividades  (IdProceso,idActividad,IdContrato,Orden,CreadoPor,CreadoEl,Activo,BitIniciaSigProceso)	VALUES	(@IdProceso,@IdActividad,@idContrato,-1,@idUsuario,GETDATE(),1,NULL)
	
			INSERT INTO EN_InstanciasActividades(IdInstanciasProcesos,IdActividad,FechaActividad,CreadoPor,CreadoEl,Activo,FechaRealActividad,FechaInicioActividad) 
			VALUES (@IdInstanciasProceso,@IdActividad,@FechaFinReal,@idUsuario,GETDATE(),1,@FechaFinReal,@FechaInicio)

			SET @idInstanciaActividad	=	@@IDENTITY;
		END

		SELECT @idInstanciaActividad AS idInstanciaActividad;
	END

END;
