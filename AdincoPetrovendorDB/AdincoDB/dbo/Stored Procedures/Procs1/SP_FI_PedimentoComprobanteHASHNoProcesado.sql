--=======================================
-- Modificador: Neri del Angel
-- Fecha: 13 de Septiembre del 2022
-- Detalle: Se ajusta los ON join, se agrega (NOLOCK)
----=======================================
CREATE PROC [dbo].[SP_FI_PedimentoComprobanteHASHNoProcesado]
AS
SELECT TOP 10
    FI_PedimentoComprobante.IdPedimentoComprobante,
    FI_PedimentoComprobante.HashSHA256,
    FI_Documento.DocumentoByte,
    FI_Documento.IdTipoDocumento
FROM FI_PedimentoComprobante (NOLOCK)
    INNER JOIN FI_Documento (NOLOCK)
        ON FI_PedimentoComprobante.CreadoEn
           BETWEEN '2019-01-01' AND '2020-12-31'
           AND ISNULL(FI_PedimentoComprobante.ProcesadoHash, 0) = 0
           AND FI_Documento.IdTipoDocumento IN ( 4, 5 )
           AND FI_PedimentoComprobante.IdPedimentoComprobante = FI_Documento.IdPedimentoComprobante