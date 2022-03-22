CREATE PROC [dbo].[SP_FI_PedimentoComprobanteHASHNoProcesado]
AS
SELECT TOP 10 
	PC.IdPedimentoComprobante,
	PC.HashSHA256, 
	FD.DocumentoByte,
	FD.IdTipoDocumento
FROM FI_PedimentoComprobante PC  
	INNER JOIN dbo.FI_Documento FD ON  
		PC.CreadoEn BETWEEN '2019-01-01' AND '2020-12-31' AND 
		ISNULL(PC.ProcesadoHash, 0) = 0 AND 
		FD.IdTipoDocumento IN(4, 5) AND 
		PC.IdPedimentoComprobante = FD.IdPedimentoComprobante 