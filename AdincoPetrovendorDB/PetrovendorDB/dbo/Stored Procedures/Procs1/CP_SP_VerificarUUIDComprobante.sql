

-- =============================================
-- Author:		<Jose Roman>
-- Create date: <11-06-2018>
-- Description:	<Se verifica que el comprobante no ha sido registrado anteriormente>
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <04-07-2019>
-- Description:	<Se agrega que revise en las dos BD ya que anteriormente solo revisaba en petrovendor>
-- =============================================

CREATE PROCEDURE CP_SP_VerificarUUIDComprobante
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
        SELECT IdFactura FROM dbo.FI_Factura WHERE UUID = @UUID


        INSERT INTO
            @TablaFactura ( IdFactura )
        SELECT IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID

		SELECT * FROM @TablaFactura
    END
