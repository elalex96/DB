
CREATE VIEW [dbo].[Reporte_DEA_Proveedores] AS

	SELECT
	PS.RazonSocial,--Razon social
	TR.TipoRegimen,
	(SELECT TOP 1 CONCAT(APaterno,' ',AMaterno,' ',Nombre) FROM DG_RepresentanteLegal WHERE IdProveedor = PS.IdProveedor AND IsActivo = 1 AND ISNULL(IsEliminado,0) = 0 ORDER BY CreadoEn DESC) AS NombreRepresentanteLegal,--Nombre representante legal
	CONCAT( 
		ISNULL('C.' + DF.Calle + ',',''), 
		ISNULL('#.' + DF.NoExterior + ',','') , 
		ISNULL('Int.' + DF.Calle + ',','') ,
		ISNULL('Col.' + DF.Colonia + ',',''),
		ISNULL('CP.' + DF.CodigoPostal + ',',''),
		ISNULL(DF.Municipio + ',',''),
		ISNULL(DF.Estado + ',','')
	) AS DomicilioFiscal,--Domicilio Fiscal de la empresa
	(SELECT TOP 1 US.Correo
		FROM S_UsuarioProveedor AS UP
			JOIN S_Usuario AS US ON UP.IdUsuario =US.IdUsuario
		WHERE IdProveedor = PS.IdProveedor
		AND US.Activo = 1
		AND US.IdTipoUsuario = 3
	ORDER BY US.FechaRegistro ASC
	) AS CorreoProveedor,--Correo electrónico
	PS.Telefono,--Teléfono
	AC.NoActaConstitutiva,--Número de acta constitutiva
	AC.Fecha AS FechaActaConstitutiva,--Fecha de acta constitutiva
	AC.NombreNotarioPublico,--Nombre notario
	AC.NoNotario,--Número de notario
	AC.LugarNotarioPublico AS DireccionNotario,--Dirección notario
	AC.RPPC,--Número RPPC
	CASE
		WHEN TR.IdTipoRegimen = 1 AND AC.IdActaConstitutiva IS NOT NULL THEN 'SI'
		WHEN TR.IdTipoRegimen = 1 AND AC.IdActaConstitutiva IS NULL THEN 'NO'
		ELSE '' 
	END AS '¿Tiene documento acta constitutiva?',--¿Tiene documento acta constitutiva?
	CASE
		WHEN TR.IdTipoRegimen = 1 AND PN.IdDocumento IS NOT NULL THEN 'SI'
		WHEN TR.IdTipoRegimen = 1 AND PN.IdDocumento IS NULL THEN 'NO'
		ELSE '' 
	END AS '¿Tiene documento poder notarial?',--¿Tiene documento poder notarial?
	CASE
		WHEN TR.IdTipoRegimen = 1 AND PN.IdDocumento IS NOT NULL THEN 'SI'
		WHEN TR.IdTipoRegimen = 1 AND PN.IdDocumento IS NULL THEN 'NO'
		ELSE '' 
	END AS '¿Tiene Documento representante legal?',--¿Tiene Documento representante legal?
	(SELECT COUNT(IdRepresentanteLegal) FROM DG_RepresentanteLegal WHERE IdProveedor = PS.IdProveedor AND IsActivo = 1 AND ISNULL(IsEliminado,0) = 0) AS '¿Cuantos representantes legales tiene?',--¿Cuantos representantes legales tiene?
	ISNULL(AC.ModificadoEn,AC.CreadoEn) AS FechaUltimaActualizacionActaConstitutiva,--Fecha última actualización Acta constitutiva
	ISNULL(PN.CreadoEl,PN.ModificadoEl) AS FechaUltimaActualizacionPoderNotarial,--Fecha última actualización Poder Notarial
	(SELECT TOP 1 CreadoEn FROM DG_RepresentanteLegal WHERE IdProveedor = PS.IdProveedor AND IsActivo = 1 AND ISNULL(IsEliminado,0) = 0 ORDER BY CreadoEn DESC) AS FechaUltimaActualizacionRepresentanteLegal,--Fecha ultima actualización Representante legal.,
	PS.CURP AS NoInstrumentoPublicoAcredita, --Número de instrumento público que acredita.
	PS.FechaConstitucion AS FechaUltimaActualizacionInstrumentoPublico--Fecha actualización instrumento público que acredita.
FROM MM_Pedido AS P
	JOIN S_Proveedor AS PO ON 
		P.IdProveedorCompras = PO.IdProveedor AND PO.RFC = 'DDE151002QY9'
	LEFT JOIN S_Proveedor AS PS 
		ON P.IdSubcontratista = PS.IdProveedor
		AND PS.RazonSocial IS NOT NULL
	LEFT JOIN S_TipoRegimen AS TR
		ON PS.IdTipoRegimen = TR.IdTipoRegimen
	LEFT JOIN DG_Domicilio AS DF
		ON PS.IdProveedor = DF.IdProveedor
			AND DF.IdTipoDomicilio = 1
			AND DF.Activo = 1
	LEFT JOIN S_Documento_S3 AS PN
		ON PS.IdProveedor = PN.IdProveedor 
		AND PN.IdTipoDocumento = 10
		AND PN.Activo = 1
	LEFT JOIN DG_ActaConstitutiva AS AC
		ON PS.IdProveedor = AC.IdActaConstitutiva
		AND AC.IsActivo = 1
		AND ISNULL(AC.IsEliminado,0) = 0
GROUP BY PS.RazonSocial,
		DF.Calle,
		DF.NoExterior,
		DF.Calle,
		DF.Colonia,
		DF.CodigoPostal,
		DF.Municipio,
		DF.Estado,--Domicilio Fiscal de la empresa
		PS.CorreoProveedor,--Correo electrónico
		PS.Telefono,--Teléfono
		AC.NoActaConstitutiva,--Número de acta constitutiva
		AC.Fecha,--Fecha de acta constitutiva
		AC.NombreNotarioPublico,--Nombre notario
		AC.NoNotario,--Número de notario
		AC.LugarNotarioPublico,--Dirección notario
		AC.RPPC,--Número RPPC
		TR.IdTipoRegimen,
		AC.IdActaConstitutiva,
		PN.IdDocumento,
		PS.CURP,
		PS.FechaCambioSituacion,
		PS.IdProveedor,
		AC.ModificadoEn,
		AC.CreadoEn,
		PN.CreadoEl,
		PN.ModificadoEl,
		TR.TipoRegimen,
		PS.FechaConstitucion,
		P.IdSubcontratista;

