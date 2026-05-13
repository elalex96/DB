-- =============================================
-- Author:		 Marcos Garcia
-- Create date:  06-12-2019
-- Description:	 Update a VarTransfer de FI_Factura a "0" 
-- =============================================

CREATE PROCEDURE [dbo].[SP_FI_EliminarComplemenetosVarTransfer]
--
@IdComplemento INT, 
@IdContrato    INT, 
@IdUsuario     INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;		
         --================= Update a Tabla ==================
         UPDATE Adinco.dbo.FI_Factura
           SET 
               VarTransfer = 0
         WHERE IdFactura = @IdComplemento;
     END;