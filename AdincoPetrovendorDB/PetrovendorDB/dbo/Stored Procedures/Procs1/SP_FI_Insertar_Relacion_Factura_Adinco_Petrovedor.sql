
-- =============================================
-- Author:		Daniel  AC
-- Create date: 18-08-2017
-- Description:	Anexar relación de factura aprobade de petrovendor y adinco 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_Insertar_Relacion_Factura_Adinco_Petrovedor] 
-- Add the parameters for the stored procedure here

@IdFacturaPetrovendor INT,
@IdFacturaAdinco INT
 

AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
		   
		 INSERT INTO FI_FacturaAdincoPetrovendor(IdFacturaPetrovendor, IdFacturaAdinco, FechaIntercambio, Activo)
		 VALUES(@IdFacturaPetrovendor, @IdFacturaAdinco, GETDATE(), 1)
		 
		 SELECT 'SUCCESS'

     END



	  

