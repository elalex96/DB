-- p_IN_AL_ConsultaAlmacen 3
CREATE Proc p_IN_AL_ConsultaAlmacen
@pIdContrato int
as

	select al.IdAlmacen,
			al.Nombre,
			al.Clave,
			al.Telefono,
			--al.Domicilio,
			al.Email,
			al.UEPS,
			al.Activo,
			al.CreadoPor,
			al.CreadoEl,
			al.ModificadoPor,
			al.ModificadoEl,
			al.IdLineaPresupuestoMes ,
			dom.Calle,
			dom.pais,
			dom.Estado,
			dom.Municipio,
			dom.Colonia,
			dom.NoExterior,
			dom.NoInterior,
			dom.CodigoPostal
	from Petrovendor.DBO.IN_ALMACEN al
	inner join  Petrovendor.DBO.[IN_ContratoAlmacen] ca on ca.IdAlmacen = al.IdAlmacen
	left JOIN pETROVENDOR.DBO.[IN_AL_Domicilio] ad on ad.IdAlmacen = al.IdAlmacen
	LEFT join Petrovendor.DBO.DG_Domicilio dom on dom.IdDomicilio = ad.IdDomicilio

