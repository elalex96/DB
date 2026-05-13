-- =============================================
-- Author:		 Marcos Garcia
-- Create date:  06-12-2019
-- Description:	 Activa el BIT VarTransfer para 
--				 Señalar que esta Disponible para
--				 Varias Transferencias
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_AsociarComplementoVarTransfer] 
-- [SP_FI_ConsultaComprobantesPorProveedor] 10002,3,10002
@IdFactura  INT, 
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         --================= Inserción a Tabla ==================
         UPDATE Adinco.dbo.FI_Factura
           SET 
               VarTransfer = 1
         WHERE IdFactura = @IdFactura;
         --================= Mensaje de Error ==================
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;