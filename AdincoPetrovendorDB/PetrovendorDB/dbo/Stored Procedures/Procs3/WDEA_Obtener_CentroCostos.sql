CREATE PROCEDURE WDEA_Obtener_CentroCostos
@IdProveedor int
AS
begin
	SELECT * FROM CC_CentroCosto 
	WHERE IdProveedor = @IdProveedor
	AND
	IsActivo = 1
end