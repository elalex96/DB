IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FACTURAS_INFORMACIONMODIFICAR'
)
    DROP PROCEDURE SP_FACTURAS_INFORMACIONMODIFICAR;
GO

--CREATED BY: LUIS DAVID DE LA CRUZ BAUTISTA
--CREATED FOR: MODIFY 'REFACTURAS'
--CREATED AT: 09/ABRIL/2018

ALTER PROCEDURE [dbo].[SP_FACTURAS_INFORMACIONMODIFICAR]
    @IDCONTRATO INT,
    @IDFACTURAPADRE INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    SELECT ISNULL(LTRIM(RTRIM(PV_Subcontratista.IdSubcontratista)), '') IdSubcontratista,
           ISNULL(LTRIM(RTRIM(PV_Subcontratista.RazonSocial)), '') RazonSocial,
           FI_RELACIONREFACTURAS.idFacturaPadre,
           FI_RELACIONREFACTURAS.idFacturaHijo
    FROM FI_RELACIONREFACTURAS (NOLOCK)
        INNER JOIN FI_Factura (NOLOCK)
            ON FI_RELACIONREFACTURAS.IdfacturaPadre = @IDFACTURAPADRE
               AND FI_RELACIONREFACTURAS.IdFacturaHijo = FI_Factura.IdFactura
               AND FI_Factura.IdContrato = @IDCONTRATO
        INNER JOIN PV_Subcontratista (NOLOCK)
            ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
    GROUP BY ISNULL(LTRIM(RTRIM(PV_Subcontratista.IdSubcontratista)), ''),
             ISNULL(LTRIM(RTRIM(PV_Subcontratista.RazonSocial)), ''),
             FI_RELACIONREFACTURAS.idFacturaPadre,
             FI_RELACIONREFACTURAS.idFacturaHijo
    ORDER BY RazonSocial ASC;
END