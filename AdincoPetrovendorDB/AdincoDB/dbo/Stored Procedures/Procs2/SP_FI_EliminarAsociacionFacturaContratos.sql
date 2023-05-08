-- =============================================
-- Author:		 Marcos Garcia
-- Create date:  06-12-2019
-- Description:	 Elimina la Relacion de las Factura 
--				 con los Contratos
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarAsociacionFacturaContratos]
@IdFactura  INT, 
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;		
         --================= Delete a Tabla ==================
         DELETE Adinco.dbo.FI_FacturaContrato
         WHERE IdFactura = @IdFactura;        
     END;