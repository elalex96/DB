-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24-04-17
-- Description:	 Actualiza el estado de Iniciado de una petición de Oferta
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarEstatusIniciadoPeticionOferta] 
	-- Add the parameters for the stored procedure here

	@IdPeticionOferta int,
	@Iniciado bit 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

	UPDATE [dbo].[MM_PeticionOferta]
	SET [Iniciada]= @Iniciado
	WHERE [IdPeticionOferta]=@IdPeticionOferta

END


