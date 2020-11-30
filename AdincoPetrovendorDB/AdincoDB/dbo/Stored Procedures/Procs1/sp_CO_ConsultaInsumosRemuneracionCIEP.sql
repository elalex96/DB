-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaInsumosRemuneracionCIEP] 
-- Add the parameters for the stored procedure here
@IdContrato INT  = 0, 
@Mes        DATE
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT 'Todos los Insumos están capturados' AS Mensaje, 
                IdContrato, 
                Anio, 
                ConstanteST240kbls, 
                IPPj, 
                IPP0, 
                Tarifa, 
                0 AS TasaDescuento, 
                ConstanteST
         FROM CO_ConstantesRemuneracionCIEP
         WHERE(IdContrato = @IdContrato)
              AND (Anio = YEAR(@Mes));
     END;