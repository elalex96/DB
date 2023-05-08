
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Description:	Regresa los Operadores de Comparacion 
			
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarOperadoresComparacion] 
	-- Add the parameters for the stored procedure here
	 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT  IdOperador,SignoOperador
	 FROM  TA_OperadorMatematico AS TF

END



