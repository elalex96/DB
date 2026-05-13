CREATE PROCEDURE GridCentroCostoAx @IdProveedor INT
AS
BEGIN
	SELECT c.IdCentroCosto, ax.IdCentroCostoAx, c.CentroCosto 
	FROM dbo.AX_CENTROCOSTO ax INNER JOIN dbo.CC_CentroCosto c ON ax.IdCentroCostoPetrov = c.IdCentroCosto
	WHERE c.IdProveedor = @IdProveedor AND c.IsActivo = 1
END







