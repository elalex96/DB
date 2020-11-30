-- =============================================
-- Author:		Marcos Garcia
-- Create date: 09-12-2019
-- Description:	Seleccionde Contratos de la Factura 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_RelacionesContratos]
-- Add the parameters for the stored procedure here
@IdFactura  INT, 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT IdContrato, 
                IdFactura
         FROM dbo.FI_FacturaContrato
         WHERE IdFactura = @IdFactura;
     END;