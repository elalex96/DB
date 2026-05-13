
CREATE PROCEDURE [dbo].[SP_ConsultaProveedorRFC]

@RFC nvarchar(MAX)

AS
BEGIN
	DECLARE @IsRegistrado INT,
			@Usuarios int 

	select RazonSocial, RegimenCapital, FechaConstitucion, FechaOperacion, SituacionContribuyente, FechaCambioSituacion, Entidad, Municipio, Colonia, TipoVialidad, NombreVialidad, NumExterior, NumInterior, CodigoPostal
		from S_Proveedor
		where RFC = @RFC

END

