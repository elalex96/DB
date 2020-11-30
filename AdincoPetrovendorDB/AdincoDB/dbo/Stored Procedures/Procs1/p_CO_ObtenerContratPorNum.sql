CREATE PROC p_CO_ObtenerContratPorNum
@pNombreContrato varchar(100),
@pIdContrato INT = 0
as

	select c.IdContrato,
		c.NumeroContrato,
		c.DescripcionContrato,
		c.IdContratista,
		c.IdAreaContractual,
		c.IDRegFiducidiario,
		c.Duracion,
		c.FechaFirma,
		c.InicioVigencia,
		c.FinVigencia,
		c.IdTipoContrato,
		c.ValorRegaliaAdicional,
		c.IncrementoProgramaMinimo,
		c.Activo,
		c.PorcentajeRecuperacion,
		c.GasNoAsociado,
		c.IsPC,
		c.IdUbicacionGeografica,
		c.MesPresentacionCGI,
		c.IdRonda,
		c.IsConsorcio,
		con.IdContratista,
		con.NombreContratista,
		con.Representante,
		con.PuestoRepresentante,
		con.RazonSocial,
		con.Calle,
		con.Numero,
		con.Colonia,
		con.Municipio,
		con.Entidad,
		con.CodigoPostal,
		con.Pais,
		con.RFC,
		con.CorreoElectronico,
		con.Telefono,
		con.PaginaWeb,
		con.DocumentoLegal,
		con.IDSIPAC,
		con.CreadoPor,
		con.LogoHTML,
		con.IdProveedor,
		con.Logo
	from CO_Contrato c
	inner join CO_Contratista con on con.IdContratista = c.IdContratista
	where (c.NumeroContrato = @pNombreContrato
		or
		c.idContrato = @pIdContrato
		OR
		replace(c.NumeroContrato,'Á','A') = @pNombreContrato
	)
