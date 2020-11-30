-- =============================================
-- Author:		Reyna Olvera
-- Create date: 19/04/2020
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeProcesoPorId]--10061,3,12843
    @idUsuario INT,
    @IdContrato INT,
    @IdProceso INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT	IdProceso,
			NombreProceso,
			Descripcion,
			CreadoPor,
			CreadoEl,
			Activo,
			idTipoProceso,
			IdInstalacion,
			IsProcesoEvento,
			IsSerie,
			Clave FROM EN_Procesos WHERE IdProceso	=	@IdProceso
END