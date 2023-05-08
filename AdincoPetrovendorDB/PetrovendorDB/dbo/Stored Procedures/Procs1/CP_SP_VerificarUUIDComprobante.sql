-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <04-07-2019>
-- Description:	<Se agrega que revise en las dos BD ya que anteriormente solo revisaba en petrovendor>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 11/01/2023
-- Description: Se agrega nolocks 
-- =============================================
CREATE PROCEDURE [dbo].[CP_SP_VerificarUUIDComprobante]
    @UUID          NVARCHAR (MAX),
    /*--------------------parametros contrato  --------------------*/
    @IdContrato    INT      = NULL,
    @IdUsuario     INT      = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
    BEGIN
        DECLARE @TablaFactura TABLE ( IdFactura INT )


        INSERT INTO
            @TablaFactura ( IdFactura )
        SELECT IdFactura FROM dbo.FI_Factura  (NOLOCK) WHERE UUID = @UUID


        INSERT INTO
            @TablaFactura ( IdFactura )
        SELECT IdFactura FROM Adinco.dbo.FI_Factura (NOLOCK) WHERE UUID = @UUID

		SELECT * FROM @TablaFactura
    END
