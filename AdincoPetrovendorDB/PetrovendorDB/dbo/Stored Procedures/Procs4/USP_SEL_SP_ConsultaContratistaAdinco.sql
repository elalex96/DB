use Petrovendor
go
drop proc if exists USP_SEL_SP_ConsultaContratistaAdinco
go
-- ============================================
-- Author:		<Daniel>
-- Create date: <13-04-2026>
-- Description:	Consultar contratista vs tabla de proveedores de petrovendor
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_SP_ConsultaContratistaAdinco]
	@RFC NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	SET @RFC = UPPER(LTRIM(RTRIM(ISNULL(@RFC, N''))));

	IF EXISTS
	(
		SELECT 1
		FROM dbo.S_Proveedor
		WHERE UPPER(LTRIM(RTRIM(ISNULL(RFC, '')))) = @RFC
	)
	BEGIN
		SELECT Estado = 'YA_REGISTRADO';
		RETURN;
	END;

	SELECT TOP 1
		Estado = 'OK',
		RFC = CONVERT(NVARCHAR(50), LTRIM(RTRIM(ISNULL(C.RFC, N'')))),
		RazonSocial = C.RazonSocial,
		NombreComercial = ISNULL(NULLIF(C.NombreContratista, N''), C.RazonSocial),
		Entidad = C.Entidad,
		Municipio = C.Municipio,
		Colonia = C.Colonia,
		NumeroExterior = C.Numero,
		CodigoPostal = C.CodigoPostal,
		Pais = ISNULL(NULLIF(C.Pais, N''), N'México'),
		Calle = C.Calle,
		Telefono = C.Telefono
	FROM Adinco.dbo.CO_Contratista C
	WHERE UPPER(LTRIM(RTRIM(ISNULL(C.RFC, N'')))) COLLATE DATABASE_DEFAULT = @RFC COLLATE DATABASE_DEFAULT

END
