CREATE PROCEDURE WDEA_Obtener_Relacion_CentroCostos
@IdProveedor INT,
@IdUsuario Int,
@IdContrato Int = null
AS
BEGIN
	SELECT WDCC.ID, WDCC.AcronimoSAP,CC.CentroCosto,WDCC.CreadoEl,WDCC.ModificadoEl 
	FROM WDEA_SAP_CentroCostos WDCC
	JOIN CC_CentroCosto AS CC
	ON WDCC.IdCentroCostosADINCO = CC.IdCentroCosto
	WHERE 
	WDCC.Activo = 1
	AND 
	CC.IsActivo = 1
	AND
	WDCC.IdProveedor = @IdProveedor
END

