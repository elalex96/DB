CREATE PROCEDURE [dbo].[SP_EN_InformacionInstancia] 
	-- Add the parameters for the stored procedure here
@Idinstancia INT,
@idContrato int =0,
@idUsuario int =0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		  SET LANGUAGE spanish;
    -- Insert statements for procedure here

         SELECT E.IdEntregable,
				IE.idInstanciaEntregable,
				DocumentoEntregable,
				 CONCAT(DAY(FechasLimiteAprobacion), ' ', datename(month, FechasLimiteAprobacion), ' ', YEAR(FechasLimiteAprobacion))
               
         FROM EN_Entregable E
		Join EN_ContratoEntregable CE on E.IdEntregable= CE.IdEntregable
		AND E.BITJOA = 0
		Join EN_InstanciasEntregable IE on CE.idContratoEntregable=IE.idContratoEntregable
	    WHERE IE.idInstanciaEntregable = @Idinstancia
     END;