IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_RelacionesContratos'
)
    DROP PROCEDURE SP_FI_RelacionesContratos;
GO

-- =============================================
-- Author:		Marcos Garcia
-- Create date: 09-12-2019
-- Description:	Selección de Contratos de la Factura 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_RelacionesContratos]
    @IdFactura INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    SELECT IdContrato,
           IdFactura
    FROM FI_FacturaContrato (NOLOCK)
    WHERE IdFactura = @IdFactura;
END;