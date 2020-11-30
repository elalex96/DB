-- =============================================
-- Author:		Manuel Cruz
-- Create date: 17-05-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ComprobanteReciboPago] 
-- Add the parameters for the stored procedure here
@IdsCompReciboPago VARCHAR(MAX), 
@IdContrato        INT, 
@IdUsuario         INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here
         DECLARE @UUIDSFaltantes NVARCHAR(MAX);
         --
         SELECT @UUIDSFaltantes = SUBSTRING(
         (
             SELECT ','+CPDR.IdDocumento AS 'data()'
             FROM dbo.FI_CPDocRelacionado AS CPDR
                  LEFT JOIN dbo.FI_ComplementoDePago CP ON CPDR.IdComplementoDePago = CP.IdComplementoDePago --AND CP.IdFactura IN (52391)
                  LEFT JOIN dbo.FI_Factura F ON CPDR.IdDocumento = F.UUID --AND F.IdFactura IS NULL 

             WHERE CP.IdFactura IN
             (
                 SELECT *
                 FROM [fn_FI_StringList2Table](@IdsCompReciboPago)
             )
                  AND F.IdFactura IS NULL FOR XML PATH('')
         ), 2, 9999);
         --

         SELECT MAX(CAST(CP.FechaDePago AS DATE)) AS FechaP, 
                ISNULL(SUM(CP.Monto), 0) AS Monto, 
                ISNULL(MP.IdMetodoPago, 0) AS IdMetodoPago, 
                @UUIDSFaltantes AS UUIDSFaltantes
         FROM dbo.FI_ComplementoDePago CP
              LEFT JOIN dbo.PV_MetodoPago MP ON CP.FormaDePagoP = MP.C_FormaPago
         WHERE CP.IdFactura IN
         (
             SELECT *
             FROM [fn_FI_StringList2Table](@IdsCompReciboPago)
         )
         GROUP BY ISNULL(MP.IdMetodoPago, 0);
     END;