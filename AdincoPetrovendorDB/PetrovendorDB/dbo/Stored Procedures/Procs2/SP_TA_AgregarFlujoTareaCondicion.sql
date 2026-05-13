-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017 - UPDATE 13/08/2017
-- Description:	Permite agregar un condicion a un flujo de tareas
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_AgregarFlujoTareaCondicion] 
	-- Add the parameters for the stored procedure here
		
	@IdFlujoTarea int,
	@NombreCondicion nvarchar(max), 
	@IdConstanteCondicion int, 
	@ValorInicial float, 
	@ValorFinal float 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	INSERT INTO TA_FlujoTareaCondicion(NombreCondicion,IdFlujoTarea,IdConstanteCondicion,ValorInicial, ValorFinal)
	VALUES(@NombreCondicion,@IdFlujoTarea,@IdConstanteCondicion, @ValorInicial,@ValorFinal)

	SELECT 'Condicion Agregada'

END

