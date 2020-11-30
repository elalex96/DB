CREATE procedure AD_SP_ConsultaProveedores

AS
BEGIN
	SELECT  IdProveedor,
			RFC,
			IdNacionalidad,
			RazonSocial,
			IdTipoRegimen,
			IsEliminado,
			Activo
		FROM dbo.S_Proveedor
END