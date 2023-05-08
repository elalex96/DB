-- =============================================
-- Author:		Manuel Cruz
-- Create date: 03-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Icoterms]
	-- Add the parameters for the stored procedure here
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here Descripcion
		 
		 CREATE TABLE #TERMINOS(IdTerminoComercio int,Termino nvarchar(300))
		 	/***Optimizacion*/
		--- INSERT INTO #TERMINOS(IdTerminoComercio,Termino) values(0, '-- Seleccione un opción ---')

		-- INSERT INTO #TERMINOS
  --       SELECT IdTerminoComercio,
  --              Termino
		--FROM MM_TerminoComercio
		-- ORDER BY Termino ASC 

		 SELECT * FROM #TERMINOS

     END;

