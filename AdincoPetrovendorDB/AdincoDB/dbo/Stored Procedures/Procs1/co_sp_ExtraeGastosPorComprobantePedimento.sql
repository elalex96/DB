CREATE PROCEDURE [dbo].[co_sp_ExtraeGastosPorComprobantePedimento]--1,2,3
    @IdUsuario INT,
    @IdContrato INT,
	@IdPedimento INT
AS
BEGIN
     SELECT  
	IdRegistro,IdInstalacion,IdPrograma,G.IdPedimentoComprobante,ISNULL( MontoRegistro,0) AS MontoRegistro,InicioEjecucion,FinEjecucion,IdGastoRubro 
	FROM
		CO_Registro G
			WHERE  G.IdPedimentoComprobante = @IdPedimento
		order by IdRegistro desc
 
END;
