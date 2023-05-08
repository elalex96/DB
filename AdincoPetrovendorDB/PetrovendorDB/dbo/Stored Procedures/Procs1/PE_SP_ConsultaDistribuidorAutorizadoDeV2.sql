
CREATE procedure [dbo].[PE_SP_ConsultaDistribuidorAutorizadoDeV2] --420
	@IdProveedor INT

AS
BEGIN
	SELECT IdDistribuidorAutorizado,
		 NombreEmpresa,
		 RFC, 
		 FechaInicioDistribucion,
		 Descripcion,
		 Nombre,
		 Correo,
		 Telefono,
		 DA.IdDocumento
		FROM [dbo].[PV_DistribuidorAutorizado] AS DA
		WHERE DA.IdProveedor= @IdProveedor AND Activo=1
END