-- =============================================
-- Author:		Manuel Cruz
-- Create date: 17-05-2018
-- Description:	
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, eliminado de codigo comentado 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ComprobanteReciboPago] 
    @IdsCompReciboPago VARCHAR(MAX),
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    -- 
    DECLARE @UUIDSFaltantes NVARCHAR(MAX);
    --
    SELECT @UUIDSFaltantes
        = SUBSTRING(
          (
              SELECT ',' + dbo.FI_CPDocRelacionado.IdDocumento AS 'data()'
              FROM dbo.FI_CPDocRelacionado (NOLOCK)
                  LEFT JOIN dbo.FI_ComplementoDePago (NOLOCK)
                      ON dbo.FI_CPDocRelacionado.IdComplementoDePago = dbo.FI_ComplementoDePago.IdComplementoDePago
                  LEFT JOIN dbo.FI_Factura (NOLOCK)
                      ON dbo.FI_CPDocRelacionado.IdDocumento = dbo.FI_Factura.UUID
              WHERE dbo.FI_ComplementoDePago.IdFactura IN (
                                                              SELECT * FROM [fn_FI_StringList2Table](@IdsCompReciboPago)
                                                          )
                    AND dbo.FI_Factura.IdFactura IS NULL
              FOR XML PATH('')
          ),
          2,
          9999
                   );
    --
    SELECT MAX(CAST(dbo.FI_ComplementoDePago.FechaDePago AS DATE)) AS FechaP,
           ISNULL(SUM(dbo.FI_ComplementoDePago.Monto), 0) AS Monto,
           ISNULL(dbo.PV_MetodoPago.IdMetodoPago, 0) AS IdMetodoPago,
           @UUIDSFaltantes AS UUIDSFaltantes
    FROM dbo.FI_ComplementoDePago (NOLOCK)
        LEFT JOIN dbo.PV_MetodoPago (NOLOCK)
            ON dbo.FI_ComplementoDePago.FormaDePagoP = dbo.PV_MetodoPago.C_FormaPago
    WHERE dbo.FI_ComplementoDePago.IdFactura IN (
                                                    SELECT * FROM [fn_FI_StringList2Table](@IdsCompReciboPago)
                                                )
    GROUP BY ISNULL(dbo.PV_MetodoPago.IdMetodoPago, 0);
END;