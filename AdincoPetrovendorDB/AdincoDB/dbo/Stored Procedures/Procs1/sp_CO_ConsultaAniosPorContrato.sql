-- =============================================
-- Author:		Manuel CD
-- Create date: 22-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaAniosPorContrato] 
	-- Add the parameters for the stored procedure here
@IdContrato INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
/*Fecha inicio contrato*/

         DECLARE @Anio NVARCHAR(10);
         SELECT @Anio = InicioVigencia
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;

/*Fecha actual a partir de la fecha contrato*/

         SELECT --C.IdFecha,
         YEAR(IdFecha) AS Anio
         FROM AP_Calendario C
         WHERE C.Dia = 1
               AND YEAR(C.IdFecha) BETWEEN YEAR(@Anio) AND YEAR(CURRENT_TIMESTAMP)
         GROUP BY YEAR(C.IdFecha)
         ORDER BY YEAR(C.IdFecha) DESC;
     END;
	--sp_CO_ConsultaAniosPorContrato 10007

