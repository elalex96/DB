-- =============================================
-- Author:		DANIEL AC
-- Create date: 02-02-18
-- Description:Eliminar información del flujo de aprobación
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_EliminarFlujoAprobacion]
-- Add the parameters for the stored procedure here
@IdFlujoActual INT,
@IdContrato INT,
@IdUsuario  INT = 0,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
	
	UPDATE dbo.MA_Flujo
	SET Activo=0,
	IsEliminado=1,
    Predeterminado=0,
	ModificadoPor=@IdUsuario,
	ModificadoEl=GETDATE()
	WHERE IdFlujo = @IdFlujoActual AND IdContrato=@IdContrato

END; 

