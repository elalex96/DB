-- =============================================
-- Author:	Alexander Gomez
-- Create date: 11-04-17
-- Description:	SP que crea la realcion para el historial de las SolPed recicladas
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarRelacionSolPedReciclaje]
		
		@IdSolPedAnterior int,
		@IdSolPedNueva int


AS
BEGIN
	SET NOCOUNT ON;
	

	INSERT INTO [dbo].[TA_RecicajeSolPed]
           ([IdSolPedAnterior]
           ,[IdSolPedNueva]
		   )
     VALUES
           (
		    @IdSolPedAnterior,
			@IdSolPedNueva
			)

	SELECT @@IDENTITY

END

