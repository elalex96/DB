CREATE PROCEDURE [dbo].[co_sp_ExtraeGastosPorFactura]--1,2,3
    @IdUsuario INT,
    @IdContrato INT,
	@IdFactura INT
AS
BEGIN
     SELECT  
	IdRegistro,IdInstalacion,IdPrograma,IdFactura, ISNULL(MontoRegistro,0) AS MontoRegistro,InicioEjecucion,FinEjecucion,IdGastoRubro 
	FROM
		CO_Registro G	(NOLOCK)
			WHERE G.IdFactura = @IdFactura
		order by IdRegistro desc
 
END;

